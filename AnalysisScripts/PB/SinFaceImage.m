global g_acDesignCache

strctUnit = [];

fStartTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fStartTS_Plexon,strctSync,'Plexon','Kofiko');
fEndTS_PTB_Kofiko = fnTimeZoneChange(strctInterval.m_fEndTS_Plexon,strctSync,'Plexon','Kofiko');




% Eye information;
strEyeXfile = [strctInterval.m_strRawFolder,filesep,strctInterval.m_strSession,'-EyeX.raw'];
strEyeYfile = [strctInterval.m_strRawFolder,filesep,strctInterval.m_strSession,'-EyeY.raw'];
if ~exist(strEyeXfile,'file') || ~exist(strEyeYfile,'file') 
    fprintf('Cannot find eye tracking file (%s). Aborting!\n',strEyeXfile);
    assert(false);
end;
[strctEyeX, afPlexonTime] = fnReadDumpAnalogFile(strEyeXfile,'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);
strctEyeY = fnReadDumpAnalogFile(strEyeYfile,'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);
iNumSamplesInInterval = length(afPlexonTime);
fSamplingFreq = strctEyeX.m_fSamplingFreq;
% 1. Eye position in pixel coordinates.
% Eye position is recorded by plexon in mV. This needs to be converted to
% pixel coordinates using the information stored in Kofiko data structure. 

% 1.1 Raw eye signal from Plexon:
afEyeXraw =  strctEyeX.m_afData;
afEyeYraw =  strctEyeY.m_afData;

% Notice, Raw eye signal can also be obtained from Kofiko:
% EyeRaw = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.EyeRaw, afPlexonTime, strctSession);
% However, plexon DAQ and Kofiko DAQ sample values a bit differently.
% Raw Eye signal (represented in kofiko) - 2048 = Raw eye signal (represented in plexon)

% 1.2 Gain, Offset, Fixation Spot and Rect, all obtained from Kofiko and
% aligned to Plexon time frame:
apt2fFixationSpot = fnTimeZoneChangeTS_Resampling(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix, 'Kofiko','Plexon',afPlexonTime, strctSync);

afStimulusSizePix = fnTimeZoneChangeTS_Resampling(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix, 'Kofiko','Plexon',afPlexonTime, strctSync);
afGazeBoxPix = fnTimeZoneChangeTS_Resampling(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.GazeBoxPix, 'Kofiko','Plexon',afPlexonTime, strctSync);
afOffsetX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',afPlexonTime, strctSync);
afOffsetY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',afPlexonTime, strctSync);
afGainX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',afPlexonTime, strctSync);
afGainY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',afPlexonTime, strctSync);

% The way to convert Raw Eye signal from plexon to screen coordinates is:
afEyeXpix = (afEyeXraw+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
afEyeYpix = (afEyeYraw+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;


clear afOffsetX  afOffsetY  afGainX  afGainY afEyeXraw afEyeYraw
 
afDistToFixationSpot = sqrt( (afEyeXpix- apt2fFixationSpot(:,1)          ).^2 +  (afEyeYpix- apt2fFixationSpot(:,2)          ).^2 );


%Spike Information
strSpikesFile = strctInterval.m_strSpikeFile;
[strctSpikes, strctChannelInfo] = fnReadDumpSpikeFile(strSpikesFile, 'SingleUnit',[strctInterval.m_iChannel,strctInterval.m_iUniqueID],'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);
SpikeTimeStamp = strctSpikes.m_afTimestamps;




%LFP Information
[strctAnalog,afPlexonTimeLFP] = fnReadDumpAnalogFile(strctInterval.m_strAnalogChannelFile,'Interval',[strctInterval.m_fStartTS_Plexon,strctInterval.m_fEndTS_Plexon]);
a2fLFPs = strctAnalog.m_afData;

%Stimulus Information
aiTrialIndices = aiRelevantTrialsInd;
aiStimulusIndex = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(1,aiTrialIndices);
afOnset_StimServer_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(2,aiTrialIndices);


