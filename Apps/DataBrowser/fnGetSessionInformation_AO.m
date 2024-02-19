function [bValid,strctInfo] = fnGetSessionInformation_AO(strKofikoFullFilename,strKofikoPath)


acstrParadigmNames = 'Passive Fixation';

index = find(strKofikoFullFilename == '_');
strKofikoFullFilename(index(2)+1:index(3)-1);

strctInfo.m_strKofikoFullFilename = fullfile(strKofikoPath,strKofikoFullFilename);
strctInfo.m_strSubject = strKofikoFullFilename(index(2)+1:index(3)-1);

strctInfo.m_strTimeDate = strKofikoFullFilename(1:index(2)-1);
strctInfo.m_acParadigms{1} = 'Passive Fixation with Monkeylogic';
% Electrophysiology information available?
strctInfo.m_iNumRecordedFrames = 0;

% [strPath,strSession] = fileparts(strKofikoFullFilename);
% astrctChannels = dir([strPath,filesep,strSession,'*spikes_ch*.raw']);
strctInfo.m_iNumRecordedChannels = 1

strctInfo.m_strctRecordingInfo = [];

bValid = 1;

return;


