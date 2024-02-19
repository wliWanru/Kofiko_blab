function acUnitsStat = fnCollectPassiveFixationNewUnitStats_AO(Event_file, astrctUnits, strctInterval, strctConfig,strctInputs,strctLFP,iUnitIter)
% Computes various statistics about the recorded units in a given recorded session
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
acUnitsStat = [];

% First, find which lists were loaded during the entire Kofiko recording file
acUniqueLists = unique({Event_file.Dataset});
iNumUniqueLists = length(acUniqueLists);
fnWorkerLog('NumofLists %d',iNumUniqueLists);

% Iterate over all unique lists
fnWorkerLog('Channel %d, Unit %d...',strctInterval.m_iChannel,strctInterval.m_iUniqueID);

for iListIter=1:iNumUniqueLists
    strListName_Ori = acUniqueLists(iListIter);
    % Find all relevant trials: ones that belond to this list AND were
    % recorded during this experiment.
    interval_start = strctInterval.m_fStartTS;
    interval_end = strctInterval.m_fEndTS;
    On_time_array = [Event_file.AO_OnTime];
    Dataset_array = {Event_file.Dataset};
    rel_time_array = find(On_time_array > interval_start & On_time_array < interval_end);
    rel_list_array = find(strcmp(Dataset_array,strListName_Ori));
    aiRelevantTrialsInd = intersect(rel_time_array,rel_list_array);
    
    strSplit = split(strListName_Ori,'\');
    strListName_Split = strSplit{end};
    strMetaFolder = strctConfig.meta_folder;
    strListName = fullfile(strMetaFolder,strListName_Split);
    
    if ~isempty(aiRelevantTrialsInd)
        strctUnit = fnCollectPassiveFixationNewUnitStatsAux_AO(...
            Event_file, astrctUnits, strctInterval, strListName, aiRelevantTrialsInd, strctConfig,strctInputs,strctLFP,iUnitIter);
        if ~isempty(strctUnit)
            acUnitsStat = [acUnitsStat,{strctUnit}];
        end
    end
end % End of List iter

return;


function strctUnit = fnCollectPassiveFixationNewUnitStatsAux_AO(...
    Event_file, astrctUnits, strctInterval, strListName, aiRelevantTrialsInd, strctConfig,strctInputs,strctLFP,iUnitIter)

strctUnit = [];

Meta_stim = readtable(strListName,'FileType','text','Delimiter','\t');
n_stims = length(Meta_stim.FileName);
acConditionNames = unique(Meta_stim.Category); 
a2bStimulusToCondition = false(n_stims,length(acConditionNames));
for i=1:n_stims
    index = find(strcmp(acConditionNames,Meta_stim{i,2}));
    a2bStimulusToCondition(i, index) = 1;
end

% Assume no special analysis, so comment codes concerning it.
% [strSpecialAnalysisFunc, strDisplayFunction,strctSpecialAnalysis] = fnFindSpecialAnalysis(strctConfig,  strListName);
% Assume FlipTime is the sync method.

allStimulusIndex = [Event_file.ImageCode];
aiStimulusIndex = allStimulusIndex(aiRelevantTrialsInd);

Stim_on_array = [Event_file.AO_OnTime];
Stim_off_array = [Event_file.AO_OffTime];
afStimulusON_TS = Stim_on_array(aiRelevantTrialsInd);
afStimulusOFF_TS = Stim_off_array(aiRelevantTrialsInd);

afImageON = strctConfig.onset_time;
afImageOFF = strctConfig.offset_time;

% Find valid trials, in which monkey fixated at the fixation point
Valid_array = [Event_file.IsValid];
abValidTrials = logical(Valid_array(aiRelevantTrialsInd));
% abValidTrials = logical(ones(size(abValidTrials)));
if isempty(a2bStimulusToCondition)
    iNumStimuli = length(unique(aiStimulusIndex));
else
    iNumStimuli = size(a2bStimulusToCondition,1);
end


% iMinimumValidTrialsToAnalyzeThisList = iNumStimuli;

if sum(abValidTrials) < 10
    fnWorkerLog('Less than 10 valid trials. Skipping this interval.');
    strctUnit = [];
    return;
end;


% Find which image list was used and get the categories
aiStimulusIndexValid = aiStimulusIndex(abValidTrials);

% Construct Peristimulus intervals
PSTH_Start_MS = strctConfig.PSTH_Start_MS;
PSTH_End_MS = strctConfig.PSTH_End_MS;
aiPeriStimulusRangeMS = PSTH_Start_MS:PSTH_End_MS;
iStartAvg = find(aiPeriStimulusRangeMS>=60,1,'first');
iEndAvg = find(aiPeriStimulusRangeMS>=220,1,'first');
iStartBaselineAvg = find(aiPeriStimulusRangeMS>=0,1,'first');
iEndBaselineAvg = find(aiPeriStimulusRangeMS>=50,1,'first');


SessionName = strctInputs.m_strSession;
index = find(SessionName == '_');
strctUnit.m_strRecordedTimeDate = SessionName(1:index(2)-1);
strctUnit.m_iChannel = strctInterval.m_iChannel;
strctUnit.m_iUnitID = strctInterval.m_iUniqueID;
strctUnit.m_strParadigm = 'Passive_Fixation_MonkeyLogic';
strctUnit.m_strImageListUsed = strListName;
strctUnit.m_strSubject = SessionName(index(2)+1:end);
[path strImageListDescrip ext] = fileparts(strListName);
strctUnit.m_strParadigmDesc = strImageListDescrip;
% strctUnit.m_iRecordedSession = strctInterval.m_iPlexonFrame;
% strctUnit.m_iChannel = strctInterval.m_iChannel;
% strctUnit.m_iUnitID = strctInterval.m_iUniqueID;
% strctUnit.m_fDurationMin = (fEndTS_PTB_Kofiko - fStartTS_PTB_Kofiko)/60;
% strctUnit.m_strParadigm = 'Passive Fixation New';
% strctUnit.m_strImageListUsed = strListName;
% strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
% strctUnit.m_strParadigmDesc = strImageListDescrip;
% strctUnit.m_strImageListDescrip = strImageListDescrip;

% Read spikes!
% strSpikesFile = strctInterval.m_strSpikeFile;
% [strctSpikes, strctChannelInfo] = fnReadDumpSpikeFile(strSpikesFile, 'SingleUnit',[strctInterval.m_iChannel,strctInterval.m_iUniqueID],'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);

strctSpikes = astrctUnits(iUnitIter);
% Add attributes to unit
strctUnit = fnAddAttribute(strctUnit,'Type','Single Unit Statistics');
strctUnit = fnAddAttribute(strctUnit,'Depth', 0);

strctUnit = fnAddAttribute(strctUnit,'Paradigm','Passive Fixation New');
strctUnit = fnAddAttribute(strctUnit,'List', strImageListDescrip);
strctUnit = fnAddAttribute(strctUnit,'Channel', num2str(strctInterval.m_iChannel),strctInterval.m_iChannel);
strctUnit = fnAddAttribute(strctUnit,'Unit', num2str(strctInterval.m_iUniqueID),strctInterval.m_iUniqueID);
%strctUnit = fnAddAttribute(strctUnit,'Target', strctChannelInfo.m_strChannelName);
strctUnit = fnAddAttribute(strctUnit,'TimeDate', strctUnit.m_strRecordedTimeDate);
strctUnit = fnAddAttribute(strctUnit,'Subject', strctUnit.m_strSubject);
% strctUnit.m_strctChannelInfo = strctChannelInfo;
strctUnit.m_afSpikeTimes = strctSpikes.m_afTimestamps;

DiscardUnitMinimumSpikes = strctConfig.DiscardUnitMinimumSpikes;
if length(strctUnit.m_afSpikeTimes) < DiscardUnitMinimumSpikes
    fnWorkerLog('Skipping. Not enough spikes');
    strctUnit = [];
    return;
end

strctUnit.m_strctStatParams.m_fStartAvgMS = strctConfig.m_fStartAvgMS;
strctUnit.m_strctStatParams.m_fEndAvgMS = strctConfig.m_fEndAvgMS;
strctUnit.m_strctStimulusParams.m_afStimulusON_MS = afImageON;
strctUnit.m_strctStimulusParams.m_afStimulusOFF_MS = afImageOFF;

strctUnit.m_aiPeriStimulusRangeMS = aiPeriStimulusRangeMS;
%strctUnit.m_strctStimulusParams = strctStimulusParams;
strctUnit.m_strctValidTrials = abValidTrials;
strctUnit.m_afISICenter = 0:50;
strctUnit.m_afISIDistribution = hist(diff(strctUnit.m_afSpikeTimes)*1e3,strctUnit.m_afISICenter);

strctTmp.m_a2fWaveforms = strctSpikes.m_a2fWaveforms;
strctTmp.m_afTimestamps = strctSpikes.m_afTimestamps;

[a2bRaster,Tmp,a2fAvgSpikeForm] = fnRaster(strctTmp, ...
    afStimulusON_TS, PSTH_Start_MS,...
    PSTH_End_MS);


strctUnit.m_a2bRaster_Valid = a2bRaster(abValidTrials,:) > 0;
strctUnit.m_afStimulusONTime = afStimulusON_TS(abValidTrials);
strctUnit.m_afStimulusONTimeAll = afStimulusON_TS;

strctUnit.m_aiStimulusIndexValid = aiStimulusIndexValid;
strctUnit.m_aiStimulusIndex = aiStimulusIndex;

strctUnit.m_aiTrialIndex = aiRelevantTrialsInd;
strctUnit.m_aiTrialIndexValid = aiRelevantTrialsInd(abValidTrials);


m_bGaussianSmoothing = strctConfig.m_bGaussianSmoothing;
TimeSmoothingMS = strctConfig.TimeSmoothingMS;


strctUnit.m_a2fAvgFirintRate_Stimulus  = 1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
    aiStimulusIndexValid, diag(1:iNumStimuli)>0,TimeSmoothingMS,...
    m_bGaussianSmoothing);

if ~isempty(a2bStimulusToCondition)
    strctUnit.m_a2fAvgFirintRate_Category = 1e3 *  fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
        aiStimulusIndexValid, a2bStimulusToCondition,TimeSmoothingMS,...
        m_bGaussianSmoothing);
else
    strctUnit.m_a2fAvgFirintRate_Category = [];
end
strctUnit.m_afAvgFirintRate_Stimulus = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(:, iStartAvg:iEndAvg),2);
strctUnit.m_afBaseline = mean(strctUnit.m_a2fAvgFirintRate_Stimulus (:, iStartBaselineAvg:iEndBaselineAvg),2);
strctUnit.m_fAvgBaseline = mean(strctUnit.m_afBaseline);

strctUnit.m_iNumStimuli = iNumStimuli;
strctUnit.m_iNumCategories = size(a2bStimulusToCondition,2);

strctUnit.m_acConditionNames = acConditionNames;
strctUnit.m_a2bStimulusToCondition = a2bStimulusToCondition;

m_bSubtractBaseline = strctConfig.m_bSubtractBaseline;
if m_bSubtractBaseline
    afSmoothingKernelMS = fspecial('gaussian',[1 7*TimeSmoothingMS],TimeSmoothingMS);
    a2fSmoothRaster = conv2(double(strctUnit.m_a2bRaster_Valid),afSmoothingKernelMS ,'same');
    afResponse = mean(a2fSmoothRaster(:,iStartAvg:iEndAvg),2);
    strctUnit.m_afBaselineRes = mean(a2fSmoothRaster(:,iStartBaselineAvg:iEndBaselineAvg),2);
    strctUnit.m_afStimulusResponseMinusBaseline = afResponse-strctUnit.m_afBaselineRes;
    % Now average according to stimulus !
    strctUnit.m_afAvgStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
    strctUnit.m_afStdStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
    strctUnit.m_afStdErrStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
    for iStimulusIter=1:iNumStimuli
        aiIndex = find(strctUnit.m_aiStimulusIndexValid == iStimulusIter);
        if ~isempty(aiIndex)
            [strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusIter),strctUnit.m_afStdStimulusResponseMinusBaseline(iStimulusIter),...
                strctUnit.m_afStdErrStimulusResponseMinusBaseline(iStimulusIter)] = fnMyMean(strctUnit.m_afStimulusResponseMinusBaseline(aiIndex));
        end
    end
    strctUnit.m_afAvgFiringRateCategory = ones(1,strctUnit.m_iNumCategories)*NaN;
    for iCatIter=1:strctUnit.m_iNumCategories
        abSamplesCat = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusToCondition(:, iCatIter)));
        if sum(abSamplesCat) > 0
            strctUnit.m_afAvgFiringRateCategory(iCatIter) = fnMyMean(strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat));
        end
    end
    
    
end
if m_bSubtractBaseline
    strctUnit.m_a2fPValueCat = NaN*ones(strctUnit.m_iNumCategories +1,strctUnit.m_iNumCategories +1); % Last one is baseline
    
    for iCat1=1:strctUnit.m_iNumCategories
        
        abSamplesCat1 = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusToCondition(:, iCat1)));
        afSamplesCat1 = strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat1);
        if sum(abSamplesCat1) > 0
            
            for iCat2=iCat1+1:strctUnit.m_iNumCategories
                abSamplesCat2 = ismember(strctUnit.m_aiStimulusIndexValid, find(a2bStimulusToCondition(:, iCat2)));
                if sum(abSamplesCat2) > 0
                    afSamplesCat2 = strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat2);
                    p = ranksum(afSamplesCat1,afSamplesCat2);
                    strctUnit.m_a2fPValueCat(iCat1,iCat2) = p;
                    strctUnit.m_a2fPValueCat(iCat2,iCat1) = p;
                end
            end
        end
        if ~isempty(afSamplesCat1)
            [h,p] = ttest(afSamplesCat1);
            strctUnit.m_a2fPValueCat(iCat1,end) = p;
            strctUnit.m_a2fPValueCat(end,iCat1) = p;
        else
            strctUnit.m_a2fPValueCat(iCat1,end) = NaN;
            strctUnit.m_a2fPValueCat(end,iCat1) = NaN;
        end
    end
    
    
    
    
else
    [strctUnit.m_a2fPValueCat] = ...
        fnStatisticalTestBy(strctUnit.m_a2bRaster_Valid, aiStimulusIndexValid, a2bStimulusToCondition,...
        iStartAvg,iEndAvg,iStartBaselineAvg,iEndBaselineAvg);
end


% Unsolved:LFP process
% if strctConfig.m_strctParams.m_bIncludeLFP_PerGroup || strctConfig.m_strctParams.m_bIncludeLFP_PerTrial &&  exist(strctInterval.m_strAnalogChannelFile,'file')
%     % Sample LFPs
%     iNumTrials = length(abValidTrials);
%     a2fSampleTimes = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
%     for iTrialIter = 1:iNumTrials
%         a2fSampleTimes(iTrialIter,:) = afModifiedStimulusON_TS_Plexon(iTrialIter)+ aiPeriStimulusRangeMS/1e3;
%     end;
%     
%     % Try new style file system...
%     %
%     %     X.g_strctNeuralServer.m_aiActiveSpikeChannels
%     %
%     %     X.g_strctNeuralServer.m_aiSpikeToAnalogMapping
%     %
%     %     X.g_strctNeuralServer.m_aiEnabledChannels
%     
%     strctAnalog = fnReadDumpAnalogFile(strctInterval.m_strAnalogChannelFile,'Resample',a2fSampleTimes);
%     
%     
%     a2fLFPs = strctAnalog.m_afData;
%     
%     bDoFrequencyAnalysis = false;
%     
%     strctUnit.m_a2fLFP = a2fLFPs;
%     if ~isempty(a2bStimulusToCondition)
%         strctUnit.m_a2fAvgLFPCategory = fnAverageBy(a2fLFPs(abValidTrials,:), aiStimulusIndexValid, a2bStimulusToCondition,0);
%     else
%         strctUnit.m_a2fAvgLFPCategory = [];
%     end
%     
%     if bDoFrequencyAnalysis
%         % Moving Frequency analysis
%         adfreq = 1000;
%         NW = 3;
%         K = 2*NW-1;
%         params.tapers=[NW K];
%         params.fpass = [0 200];
%         params.Fs = adfreq;
%         params.trialave = 1;
%         params.pad =2;
%         
%         winsize = 0.1; % 0.1 second window (i.e., 100 samples per window)
%         winstep = 0.01; % 0.1 second intervals (i.e., advance window 10 sample points)
%         movingwin = [winsize winstep];
%         [S2,t2,f2] = mtspecgramc( a2fLFPs', movingwin, params );
%         strctUnit.m_strctSpectogram.m_afTime = t2-strctUnit.m_aiPeriStimulusRangeMS(1);
%         strctUnit.m_strctSpectogram.m_afFreq = f2;
%         strctUnit.m_strctSpectogram.m_a2fPower = real(S2);
%         
%         
%         % Estimate the frequency spectrum for the first 30 seconds, and last 30
%         % seconds.
%         
%         afFirst = [strctInterval.m_fStartTS_Plexon, min(strctInterval.m_fStartTS_Plexon+30, strctInterval.m_fEndTS_Plexon)];
%         afLast = [max(strctInterval.m_fStartTS_Plexon, strctInterval.m_fEndTS_Plexon-30) strctInterval.m_fEndTS_Plexon];
%         strctAnalogFirst30 = fnReadDumpAnalogFile(strctInterval.m_strAnalogChannelFile,'Interval',afFirst);
%         strctAnalogLast30 = fnReadDumpAnalogFile(strctInterval.m_strAnalogChannelFile,'Interval',afLast);
%         
%         adfreq = 2000;
%         NW = 3;
%         K = 2*NW-1;
%         params.tapers=[NW K];
%         params.fpass = [0 200];
%         params.Fs = adfreq;
%         params.trialave = 1;
%         params.pad =0;
%         
%         [strctUnit.strctSpectrum.m_afPowerStart,strctUnit.strctSpectrum.m_afFreqStart]=mtspectrumc(strctAnalogFirst30.m_afData,params) ;
%         [strctUnit.strctSpectrum.m_afPowerEnd,strctUnit.strctSpectrum.m_afFreqEnd]=mtspectrumc(strctAnalogLast30.m_afData,params) ;
%     end
% else

iNumTrials = length(abValidTrials);
a2fSampleTimes = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
for iTrialIter = 1:iNumTrials
  a2fSampleTimes(iTrialIter,:) = afStimulusON_TS(iTrialIter)+ aiPeriStimulusRangeMS/1e3;
end;

LFPTime = strctLFP.TimeBegin:1/strctLFP.att_SampleRate:strctLFP.TimeEnd;
index_Start = find(LFPTime>min(a2fSampleTimes(:)),1)-1;
index_End = find(LFPTime<max(a2fSampleTimes(:)),1,'last')+1;
LFP_ReduceTime = LFPTime(index_Start:index_End);
LFP_Data = double(strctLFP.Data(index_Start:index_End));
a2fLFPs= interp1(LFP_ReduceTime,LFP_Data,a2fSampleTimes);
if ~isempty(a2bStimulusToCondition)
  strctUnit.m_a2fAvgLFPCategory = fnAverageBy(a2fLFPs(abValidTrials,:), aiStimulusIndexValid, a2bStimulusToCondition,0);
else
  strctUnit.m_a2fAvgLFPCategory = [];
end
strctUnit.m_a2fLFP = a2fLFPs;




strctUnit.m_iUnitID = strctInterval.m_iUniqueID;

%      Wave form
warning off

strctUnit.m_afAvgWaveForm = mean(a2fAvgSpikeForm(abValidTrials,:), 1);
strctUnit.m_afStdWaveForm = std(a2fAvgSpikeForm(abValidTrials,:), [], 1);
strctUnit.m_iNumValidTrials = sum(abValidTrials);
warning on

strctUnit.m_abValidTrials = abValidTrials;
strctUnit.m_strDisplayFunction = 'fnDisplaySimpleStim';




return;


