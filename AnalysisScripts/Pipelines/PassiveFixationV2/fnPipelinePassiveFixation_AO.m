function fnPipelinePassiveFixation_AO(strctInputs)
clear global g_acDesignCache

strDataRootFolder = strctInputs.m_strDataRootFolder;
% strAoFile = strctInputs.m_strAoFile;
% strMonkeyLogic = strctInputs.m_strMonkeyLogic;
strSession = strctInputs.m_strSession;

fnWorkerLog('Starting passive fixation standard analysis pipline...');
fnWorkerLog('Session : %d',strSession);
fnWorkerLog('Data Root : %s',strDataRootFolder);

% [tmp_fname, tmp_fpath]= uigetfile(strRawFolder);
% strRawFile = fullfile(tmp_fpath, tmp_fname);
%
% strConfigFile = [strConfigFolder,'AnalysisPipelines',filesep, 'PipelineNewPassiveFixation.xml'];


strOutputFolder = fullfile(strDataRootFolder,'Processed','SingleUnitDataEntries');
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end

%% Load and reorganize data.
% Re-organize the format of ao Trigger data
% strAoFile = "D:\kofiko_wanru\20240120_tutu\Processed\SortedUnits\240120_111111_TuTu_sorted.mat";
xx = dir(fullfile(strctInputs.m_strDataRootFolder,'raw','*_AO.mat'));
strAoFile = fullfile(xx(1).folder,xx(1).name);
AoData = load(strAoFile);
AoData = AoData.ao;
ao_Trigger = AoData.Trigger;
N_events = length(ao_Trigger.events);
AOEvents(1,N_events) = struct('Trial',[],'ImageCode',[],'AO_OnTime',[],'AO_OffTime',[]);
element = 1;
ptr = 1;
Trial_now = 0;

while ptr < N_events
    if ao_Trigger.events(ptr) == 9
        Trial_now = ao_Trigger.events(ptr+1) - 100;
        ptr = ptr+4;
        continue
    elseif ao_Trigger.events(ptr) == 18
        ptr = find(ao_Trigger.events(ptr:end)==9,1) + ptr - 1;
        continue
    elseif ao_Trigger.events(ptr) < 10000
        ptr = ptr + 1;
    elseif ao_Trigger.events(ptr) > 10000 && ao_Trigger.events(ptr) < 20000
        AOEvents(element).Trial = Trial_now;
        AOEvents(element).ImageCode = ao_Trigger.events(ptr) - 10000;
        AOEvents(element).AO_OnTime = ao_Trigger.indices_44k_origin(ptr)/ao_Trigger.att_SampleRate;
        ptr = ptr + 1;
    elseif ao_Trigger.events(ptr) > 20000
        if ao_Trigger.events(ptr) == AOEvents(element).ImageCode + 20000
            AOEvents(element).AO_OffTime = ao_Trigger.indices_44k_origin(ptr)/ao_Trigger.att_SampleRate;
            ptr = ptr + 1;
            element = element + 1;
        else
            ptr = ptr + 1;
            continue
        end
    end
end

% Filter
notEmptyIndices = arrayfun(@(x) ~isempty(x.ImageCode), AOEvents);
AOEventsFiltered = AOEvents(notEmptyIndices);

% Re-organize the format of monkeylogic data
% strMonkeyLogic = 'D:\kofiko_wanru\20240120_tutu\ml_result.mat';
tic
xx = dir(fullfile(strctInputs.m_strDataRootFolder,'raw','*_ML.mat'));
strMonkeyLogic = fullfile(xx(1).folder,xx(1).name);
MLFile = load(strMonkeyLogic).bhvmat;
Percent_Threshold = 0.9;
N_events = 0;

for i=1:length(MLFile)
    N_events = N_events + length(MLFile(i).BehavioralCodes.CodeTimes);
end

MLEvents(1,N_events) = struct('Trial',[],'ImageCode',[],'Dataset',[],'ML_OnTime',[],'ML_OffTime',[],'Eye',[],'Eye2',[],'ValidPer',[],'IsValid',[]);
element = 1;

for i=1:length(MLFile)
    n_events = length(MLFile(i).BehavioralCodes.CodeNumbers);
    fixation_window = MLFile(i).VariableChanges.fixation_window;
    iter = 1;

    while iter < n_events
        EventCode = MLFile(i).BehavioralCodes.CodeNumbers(iter);

        if EventCode < 10000
            if EventCode == 18
                break
            else
                iter = iter + 1;
                continue
            end

        elseif EventCode > 10000 && EventCode < 20000
            End_iter = find(MLFile(i).BehavioralCodes.CodeNumbers(iter:end)==EventCode+10000,1)+iter-1;
        end
        MLEvents(element).Trial = i;
        MLEvents(element).Dataset = MLFile(i).UserVars.DatasetName;
        MLEvents(element).ImageCode = MLFile(i).BehavioralCodes.CodeNumbers(iter)-10000;
        MLEvents(element).ML_OnTime = MLFile(i).BehavioralCodes.CodeTimes(iter);
        MLEvents(element).ML_OffTime = MLFile(i).BehavioralCodes.CodeTimes(End_iter);
        Interval = floor(MLEvents(element).ML_OnTime):floor(MLEvents(element).ML_OffTime);
        MLEvents(element).Eye = MLFile(i).AnalogData.Eye(Interval,:);
        MLEvents(element).Eye2 = MLFile(i).AnalogData.Eye2(Interval,:);
        EyeMoves = length(MLEvents(element).Eye);
        Eye_dis = sqrt(MLEvents(element).Eye(:,1).^2 + MLEvents(element).Eye(:,2).^2);
        Eye2_dis = sqrt(MLEvents(element).Eye2(:,1).^2 + MLEvents(element).Eye2(:,2).^2);

        ValidEyeMoves = sum(Eye2_dis<fixation_window | Eye_dis<fixation_window);
        %       Slow Version
        %         for move=1:EyeMoves
        %             Eye_dis = sqrt(MLEvents(element).Eye(move,1)^2+MLEvents(element).Eye(move,2)^2);
        %             Eye2_dis = sqrt(MLEvents(element).Eye2(move,1)^2+MLEvents(element).Eye2(move,2)^2);
        %             if (Eye_dis < fixation_window) && (Eye2_dis < fixation_window)
        %                 ValidEyeMoves = ValidEyeMoves + 1;
        %             end
        %         end
        MLEvents(element).ValidPer = ValidEyeMoves/EyeMoves;
        if MLEvents(element).ValidPer > Percent_Threshold
            MLEvents(element).IsValid = 1;
        else
            MLEvents(element).IsValid = 0;
        end
        element = element + 1;
        iter = End_iter+1;
    end
end

% Filter
notEmptyIndices = arrayfun(@(x) ~isempty(x.ImageCode)&&~isempty(x.ML_OffTime), MLEvents);
MLEventsFiltered = MLEvents(notEmptyIndices);
toc
% Concat AO File and ML File
if ~(length(AOEventsFiltered) == length(MLEventsFiltered))
    fnWorkerLog('Length of processed AO File and ML File unequal, WangkeSheng''s way is not working');
    fnWorkerLog('Let us try Pinglei''s method');
    [MLEventsFiltered AOEventsFiltered] = PB_matchingTrial(AoData,MLFile,fixation_window,Percent_Threshold);

   
end

Event_file = struct();
fields1 = fieldnames(MLEventsFiltered);
fields2 = fieldnames(AOEventsFiltered);

for i = 1:length(MLEventsFiltered)
    for j = 1:length(fields1)
        fieldName = fields1{j};
        Event_file(i).(fieldName) = MLEventsFiltered(i).(fieldName);
    end

    for k = 1:length(fields2)
        fieldName = fields2{k};
        Event_file(i).(fieldName) = AOEventsFiltered(i).(fieldName);
    end
end


%% Analyze sorted data only (!)
% Set num of channels 1 simply

strSortedUnitsFolder = fullfile(strctInputs.m_strDataRootFolder,'Processed','SortedUnits');
Matfilelist_inSortedUnitsFolder = dir(fullfile(strSortedUnitsFolder, '*.mat'));
if length(Matfilelist_inSortedUnitsFolder)>1
    [fn pathname] = uigetfile(fullfile(strSortedUnitsFolder, '*.mat'),'Please Select Sorted Mat file');
    strSortedFileName = fullfile(pathname,fn);
else
    strSortedFileName = fullfile(Matfilelist_inSortedUnitsFolder(1).folder,Matfilelist_inSortedUnitsFolder(1).name);
end

AO_SortedData = load(strSortedFileName);
AO_SortedData = AO_SortedData.ao;

iNumSortedChannels = length(AO_SortedData.strctChannelInfo);
fnWorkerLog('%d Sorted channel files found',iNumSortedChannels);

for iChannelIter=1:iNumSortedChannels
    % fnSetWaitbarGlobal(iChannelIter/1,2, 3);
    % Only read the intervals and find out whether there is something to analyze....
    SpikeData = AO_SortedData.SEG;
    strctChannelInfo = AO_SortedData.strctChannelInfo;
    % Skip unsorted units
    aiSortedUnits = intersect(find(cat(1,SpikeData.unit_index) ~= 0 ),find(~cellfun('isempty', {SpikeData.waveforms})));
    astrctUnits = SpikeData(aiSortedUnits);
    for i=1:length(astrctUnits)
        astrctUnits(i).m_afTimestamps = astrctUnits(i).waveforms_timestamps.'/ao_Trigger.att_SampleRate;
        astrctUnits(i).m_a2fWaveforms = astrctUnits(i).waveforms;
        astrctUnits(i).m_afInterval(1) = min(astrctUnits(i).m_afTimestamps);
        astrctUnits(i).m_afInterval(2) = max(astrctUnits(i).m_afTimestamps);
        astrctUnits(i).m_iUniqueID = astrctUnits(i).unit_index;
    end
    astrctUnits = fnComputeUnitSNR(astrctUnits);

    % Config Setting
    % Assume config of all trials are same
    MLConfig = MLFile(1).VariableChanges;

    strctConfig.meta_folder = strctInputs.strMetaFolder;
    strctConfig.onset_time = MLConfig.onset_time;
    strctConfig.offset_time = MLConfig.offset_time;
    strctConfig.m_fStartAvgMS = 60;
    strctConfig.m_fEndAvgMS = 220;
    strctConfig.PSTH_Start_MS = -200;
    strctConfig.PSTH_End_MS = 900;
    strctConfig.DiscardUnitMinimumSpikes = 50;
    strctConfig.m_bGaussianSmoothing = true;
    strctConfig.TimeSmoothingMS = 3;
    strctConfig.m_bSubtractBaseline = true;
    % fnWorkerLog('Analyzing channel %d (%s)',strctChannelInfo.m_iChannelID,strctChannelInfo.m_strChannelName);

    strctLFP = AoData.LFP;

    iNumSortedUnits = length(astrctUnits);
    fnWorkerLog('%d sorted unit intervals found',iNumSortedUnits);
    % fnResetWaitbarGlobal(3,3);
    for iUnitIter=1:iNumSortedUnits
        strctInterval.m_iChannel = strctChannelInfo.m_iChannelID;
        strctInterval.m_iUniqueID = astrctUnits(iUnitIter).m_iUniqueID;
        strctInterval.m_fStartTS = astrctUnits(iUnitIter).m_afInterval(1);
        strctInterval.m_fEndTS = astrctUnits(iUnitIter).m_afInterval(2);
        % strctInterval.m_strRawFolder = strRawFolder;
        strctInterval.m_strSession    = strSession;
        acUnitsStat = fnCollectPassiveFixationNewUnitStats_AO(Event_file,astrctUnits,strctInterval,strctConfig,strctInputs,strctLFP,iUnitIter);
        if ~isempty(acUnitsStat)
            % Save the statistics to disk
            iNumDataEntries = length(acUnitsStat);
            for iEntryIter=1:iNumDataEntries
                strctUnit = acUnitsStat{iEntryIter};

          strUnitName = sprintf('%s_%s_Exp_Ch_%03d_Unit_%03d_%s_%s',...
                        strctUnit.m_strSubject, strctUnit.m_strRecordedTimeDate,...
                        strctUnit.m_iChannel(1),strctUnit.m_iUnitID(1), strctUnit.m_strParadigm,strctUnit.m_strParadigmDesc);
                strOutputFilename = fullfile(strOutputFolder, [strUnitName,'.mat']);
                
                save(strOutputFilename,  'strctUnit');
                fnWorkerLog('Filename : %s',strOutputFilename);
            end
        end
    end

end
return;

