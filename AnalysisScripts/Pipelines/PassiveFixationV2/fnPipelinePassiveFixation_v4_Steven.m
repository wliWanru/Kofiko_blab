function fnPipelinePassiveFixation_v4_Steven(strctInputs)
clear global g_acDesignCache

strDataRootFolder = strctInputs.m_strDataRootFolder;  % 'C:\wanruli\codes\open_codes\tool_data\raw_eph\150924\'
strConfigFolder   = strctInputs.m_strConfigFolder;  % 'C:\wanruli\codes\open_codes\KofikoPB\trunk\Config\'
strSession        = strctInputs.m_strSession;  % '150924_155226_Rocco'

if strDataRootFolder(end) ~= filesep()  % filesep is \
    strDataRootFolder(end+1) = filesep();
end
fnWorkerLog('Starting passive fixation standard analysis pipline...');
fnWorkerLog('Session : %s',strSession);
fnWorkerLog('Data Root : %s',strDataRootFolder);

%% define all RAW data name; assign output path (Processed\SingleUnitDataEntries\)
strRawFolder = [strDataRootFolder,'RAW',filesep()];  
strKofikoFile = fullfile(strRawFolder,[strSession,'.mat']);  % RAW\150924_155226_Rocco.mat'
strAdvancerFile = fullfile(strRawFolder,[strSession,'-Advancers.txt']);
strStatServerFile = fullfile(strRawFolder,[strSession,'-StatServerInfo.mat']);
strStrobeFile = fullfile(strRawFolder,[strSession,'-strobe.raw']);
strAnalogFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);  % any can suffice...
strSyncFile = fullfile(strRawFolder,[strSession,'-sync.mat']);
strConfigFile = [strConfigFolder,'AnalysisPipelines',filesep, 'PipelineNewPassiveFixation.xml'];
strPhotoDiodeFile = fullfile(strRawFolder,[strSession,'-Photodiode.raw']);

strOutputFolder = [strDataRootFolder,'Processed',filesep(),'SingleUnitDataEntries',filesep()];
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end

%% Verify everything is around. (all RAW data name defined above)
fnCheckForFilesExistence({strKofikoFile, strStatServerFile,...
    strStrobeFile,strAnalogFile,strSyncFile,strConfigFile,strPhotoDiodeFile});

% Load needed information to do processing
strctSync = load(strSyncFile).('strctSync');  
strctKofiko = load(strKofikoFile);
strctStatServer = load(strStatServerFile);


%% Detect photodiode events
fnWorkerLog('Detecting photodiode crossing...');

% ~~ afTime: analog file time. could be the event start time
[strctPhotodiode, afTime]= fnReadDumpAnalogFile(strPhotoDiodeFile);  
strctPhotodiode.m_afData=max(strctPhotodiode.m_afData)-strctPhotodiode.m_afData;
% figure; plot(1:length(strctPhotodiode.m_afData),
% strctPhotodiode.m_afData); 

fPhotodiodeThreshold = (max(strctPhotodiode.m_afData)-min(strctPhotodiode.m_afData))/2;
%as(0)=10;
ck=[];
bk=[];
bk=strctPhotodiode.m_afData > fPhotodiodeThreshold;  % ~~ all which above thresh
ck=strctPhotodiode.m_afData > fPhotodiodeThreshold;  % ~~ all which above thresh

% ~~ 
for i=1:length(bk)-1
    if bk(i)==1 && bk(i+1)==0  % ~~ this i is a switching point (from 1 to 0)
        ck(i:i+134)=1;  % ~~ what's 134 here?????? 
    end
end
ck=ck(1:length(bk));
%astrctPhotodiodeEventsWithJitter = fnGetIntervals(strctPhotodiode.m_afData > fPhotodiodeThreshold);
astrctPhotodiodeEventsWithJitter = fnGetIntervals(ck);

%as=[

% Photodiode amplifier sometimes jitters the signal and goes low when it shouldn't.
% So we merge nearby intervals that are shroter than refresh rate (or
% two..., since we usually don't display things that fast).

% ~~ 0.5 ms between 2 analog signal? 
% ~~ could be sampling rate.. 1000 / 0.5 = 2000 Hz;
% ~~ is consistent with strctPhotodiode.m_fSamplingFreq  
iDistanceBetweenSamplesMS = 1e3*(afTime(2)-afTime(1));  

% ~~ strctKofiko.g_strctStimulusServer.m_fRefreshRateMS is 10 ms refershRate
% ~~ iMergeInterval is 40 = ( 2 * 10 / 0.5) ; why 2 * ???? 
% ~~ 2 maybe just because they want some relatively suitable threshold number
% ~~ as the author says "we merge nearby intervals that are shroter than refresh rate or two"
iMergeInterval = ceil(2*strctKofiko.g_strctStimulusServer.m_fRefreshRateMS / iDistanceBetweenSamplesMS);
astrctPhotodiodeEvents = fnMergeIntervals(astrctPhotodiodeEventsWithJitter,iMergeInterval);

% M = length(strctPhotodiode.m_afData);
% 
% abNotFixed = fnIntervalsToBinary(astrctPhotodiodeEventsWithJitter,M);
% abFixed = fnIntervalsToBinary(astrctPhotodiodeEvents,M);

% figure(11);
% clf;
% plot(abFixed*1,'r');
% hold on;
% plot(0.2+abNotFixed*0.6,'b');
% set(gca,'xlim',[-5000 5000]+189955*ones(1,2));
% set(gca,'ylim',[-0.2 1.3]);

% ~~ after sorted, these data should be arranged like
% ~~ start1, end1, start2, end2 ....
% ~~ could be visualize using figure; a = diff(afActualFlipTime_PLX);figure; plot(1:length(a), a)
% ~~ most are 0.02 (20 ms) to 0.09 (90 ms) s
afActualFlipTime_PLX = sort(afTime([cat(1,astrctPhotodiodeEvents.m_iStart);cat(1,astrctPhotodiodeEvents.m_iEnd)]));

fnWorkerLog('Detected %d photodiode switching events', length(afActualFlipTime_PLX));


%% ~~ load all configs
strctConfig = fnMyXMLToStruct(strConfigFile);

% ~~ ???? TimeStamp: [3.0243e+06 3.0243e+06 3.0243e+06 3.0243e+06]
afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
% ~~ Buffer: {''  'Default'  'Five Dot Eye Calibration'  'Passive Fixation New'}
acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;

if ~ismember('Passive Fixation New',acstrParadigmNames)  %% judge if pipeline chosen was matched 
    fnWorkerLog('Session : %s does not contain force choice. Aborting!',strSession);
    return;
end;


%% Read advancer file for electrode position during the experiments...
% a2fTemp = textread(strAdvancerFile);
a2fTemp = [2 27.000000 NaN NaN 0.000000 107752.152035];  %% ~~same as the -Advanced file
afDepthRelativeToGridTop = a2fTemp(:,2);  % ~~ afDepthRelativeToGridTop is 27
aiAdvancerUniqueID = a2fTemp(:,1);  % 2
afAdvancerChangeTS_StatServer = a2fTemp(:,6);  % ~~ change time stamp?? 107752.152035
% ~~ maybe time stamp is the absolute system time? like GetSecs()

% ~~ ????? change time according to system time???? 
afAdvancerChangeTS_Plexon = fnTimeZoneChange(afAdvancerChangeTS_StatServer,strctSync,'StatServer','Plexon');


%% Analyze sorted data only (!)
strSortedUnitsFolder = [strDataRootFolder,'Processed',filesep,'SortedUnits',filesep];
astrctSortedChannels = dir([strSortedUnitsFolder,'*spikes_ch*_sorted.raw']);  % the sorted chann

if isempty(astrctSortedChannels)
    fnWorkerLog('No sorted channels found for session %s. Aborting.',strSession);
    return;
end
%acNewDataEntries = {[]};
fnResetWaitbarGlobal(2,3);  % ~~ ????????? what's this for
iNumSortedChannels = length(astrctSortedChannels);
fnWorkerLog('%d Sorted channel files found',iNumSortedChannels);



for iChannelIter=1:iNumSortedChannels
    fnSetWaitbarGlobal(iChannelIter/length(astrctSortedChannels),2, 3);  % ~~ ??????
    % Only read the intervals and find out whether there is something to analyze....
    
    %% ~~ load all spike sorted units' spikes
    % ~~ the sorted ch file 150924_155226_Rocco-spikes_ch1_sorted.raw
    strSpikeFile = [strSortedUnitsFolder,astrctSortedChannels(iChannelIter).name];
    [astrctAllUnits,strctChannelInfo] = fnReadDumpSpikeFile(strSpikeFile);
    % ~~ astrctAllUnits: 1* 10 struct, because I assigned 10 units when
    %                    spike sorting
    %                    astrctAllUnits.m_a2fWaveforms is n*32 matrix; why 32?? 
    % ~~ strctChannelInfo: channel names and so on


    %% ~~ calculate SNR for all units
    astrctAllUnits = fnComputeUnitSNR(astrctAllUnits);
    fnWorkerLog('Analyzing channel %d (%s)',strctChannelInfo.m_iChannelID,strctChannelInfo.m_strChannelName);
    
    %    Do we have an LFP channel for this spike channel ?
    % ~~ ???? whats below? all NaNs
    iAdvancerUniqueID = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(strctChannelInfo.m_iChannelID,3);

    
    %% ~~ for sorted units
    % ~~ get all kinds of channel info
    iChannelIdx = find(strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels == strctChannelInfo.m_iChannelID);
    iTempIndex = strctStatServer.g_strctNeuralServer.m_aiSpikeToAnalogMapping(iChannelIdx);
    iCorrespondingAnalogChannel = strctStatServer.g_strctNeuralServer.m_aiEnabledChannels(iTempIndex);
    strAnalogChannelFile = [strRawFolder,strSession,'-',strctStatServer.g_strctNeuralServer.m_acAnalogChannelNames{iCorrespondingAnalogChannel},'.raw'];
    
    % Skip unsorted units.... 
    aiSortedUnits = find(cat(1,astrctAllUnits.m_iUnitIndex) ~= 0);  % delete those m_iUnitIndex == 0
    astrctUnits = astrctAllUnits(aiSortedUnits);
    
    
    
    % For each sorted unit, find out whether passive fixation paradgm was
    % active during that time...
    
    iNumSortedUnits = length(astrctUnits);
    fnWorkerLog('%d sorted unit intervals found',iNumSortedUnits);
    fnResetWaitbarGlobal(3,3);

    for iUnitIter=1:iNumSortedUnits  % from 1 to 9 sorted units
        fnSetWaitbarGlobal(iUnitIter/iNumSortedUnits,3, 3);
        
        % ~~ ??? why change time zone? stored as absolute time??  
        fStartTS_PTB_Kofiko = fnTimeZoneChange( ...
            astrctUnits(iUnitIter).m_afInterval(1) ,strctSync,'Plexon','Kofiko');
        fEndTS_PTB_Kofiko = fnTimeZoneChange( ...
            astrctUnits(iUnitIter).m_afInterval(2),strctSync,'Plexon','Kofiko');
        
        % Find out which paradigms were run while this unit was alive...
        % ~~ ??? may have multiple tasks within one recording session for
        %        one cell?? 
        % ~~ need to see how to generate fStartTS_PTB_Kofiko
        % ~~ seems relevant to strctSync.m_strctStimulusServerToKofiko;
        % ~~ time sync between different PCs

        iStartIndex = find(afParadigmSwitchTS_Kofiko <= fStartTS_PTB_Kofiko,1,'last');
        iEndIndex = find(afParadigmSwitchTS_Kofiko <= fEndTS_PTB_Kofiko,1,'last');
        acParadigmsRecorded = unique(acstrParadigmNames(iStartIndex:iEndIndex));
        
        % Find depths this unit was recorded at (relative to grid top)
        % Store this in a2fAdvancerPositionTS_Plexon
        % a2fAdvancerPositionTS_Plexon(1,:) is Plexon TS when advancer was
        % modified
        % a2fAdvancerPositionTS_Plexon(2,:) are the depth values.

        % ~~ what is advancer?????????? what is 51 ????????????
        % ~~ is it times of plugging in the electrode? 
        afSampleAdvancerTimes = [astrctUnits(iUnitIter).m_afInterval(1):1:astrctUnits(iUnitIter).m_afInterval(2)]; % every second...

        % ~~ should this be all zero? 
        afIntervalDepthMM= fnMyInterp1( ...
            afAdvancerChangeTS_Plexon(aiAdvancerUniqueID == iAdvancerUniqueID), ...
            afDepthRelativeToGridTop(aiAdvancerUniqueID == iAdvancerUniqueID), ...
            afSampleAdvancerTimes);

        a2fAdvancerPositionTS_Plexon = [       afSampleAdvancerTimes;afIntervalDepthMM];
         
        if ismember('Passive Fixation New',acParadigmsRecorded)
            strctInterval.m_iChannel = strctChannelInfo.m_iChannelID;
            strctInterval.m_iUniqueID    =astrctUnits(iUnitIter).m_iUnitIndex;
            strctInterval.m_fStartTS_Plexon = astrctUnits(iUnitIter).m_afInterval(1);
            strctInterval.m_fEndTS_Plexon = astrctUnits(iUnitIter).m_afInterval(2);
            strctInterval.m_strRawFolder = strRawFolder;
            strctInterval.m_strSession    = strSession;
            strctInterval.m_iPlexonFrame  = NaN;
            strctInterval.m_strSpikeFile = strSpikeFile;
            strctInterval.m_strAnalogChannelFile = strAnalogChannelFile;
            strctInterval.m_a2fAdvancerPositionTS_Plexon = a2fAdvancerPositionTS_Plexon;

            %% apply unit stats
            acUnitsStat = fnCollectPassiveFixationNewUnitStats2( ...
                strctKofiko, strctSync, strctConfig, strctInterval, afActualFlipTime_PLX);

            %% store unit stats results
            if ~isempty(acUnitsStat)
                % Save the statistics to disk
                iNumDataEntries = length(acUnitsStat);
                for iEntryIter=1:iNumDataEntries
                    strctUnit = acUnitsStat{iEntryIter};
                    
                    strTimeDate = datestr(datenum(strctUnit.m_strRecordedTimeDate),31);
                    strTimeDate(strTimeDate == ':') = '-';
                    strTimeDate(strTimeDate == ' ') = '_';
                    
                    strParadigm = strctUnit.m_strParadigm;
                    strParadigm(strParadigm == ' ') = '_';
                    strDesr = strctUnit.m_strParadigmDesc;
                    strDesr(strDesr == ' ') = '_';
                    strUnitName = sprintf('%s_%s_Exp_%02d_Ch_%03d_Unit_%03d_%s_%s_%d',...
                        strctUnit.m_strSubject, strTimeDate,strctUnit.m_iRecordedSession,...
                        strctUnit.m_iChannel(1),strctUnit.m_iUnitID(1), strParadigm, strDesr,iEntryIter);
                    
                    strOutputFilename = fullfile(strOutputFolder, [strUnitName,'.mat']);
                    %acNewDataEntries = [acNewDataEntries,strOutputFilename];
                    save(strOutputFilename,  'strctUnit');
                end
            end
        end
    end
end
return;

function fnCheckForFilesExistence(acFileList)
for k=1:length(acFileList)
    if ~exist(acFileList{k},'file')
        fprintf('File is missing : %s\n',acFileList{k});
        error('FileMissing');
    end
end

