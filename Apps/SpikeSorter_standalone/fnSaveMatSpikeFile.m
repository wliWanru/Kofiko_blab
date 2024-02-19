function fnSaveMatSpikeFile(strInputFile, strctChannelInfo, astrctSpikes, strOutFileName)
% Create a new ao struct
ao = load(strInputFile); 
ao = ao.ao;

% Reconstruct ao.SEG from astrctRawUnits
n_RawUnits = length(astrctSpikes);
for i_RawUnit = 1:n_RawUnits
    ao_SEG(i_RawUnit).unit_index = astrctSpikes(i_RawUnit).m_iUnitIndex;
    ao_SEG(i_RawUnit).waveforms_timestamps = round((astrctSpikes(i_RawUnit).m_afTimestamps + ao.t_TimeBegin)* 44000)';
    ao_SEG(i_RawUnit).waveforms = (astrctSpikes(i_RawUnit).m_a2fWaveforms);
    ao_SEG(i_RawUnit).interval = astrctSpikes(i_RawUnit).m_afInterval;
end
ao.SEG = ao_SEG;
ao.astrctAnnotatedIntervals = [];
% Assign strctChannelInfo and astrctAnnotatedIntervals to ao
ao.strctChannelInfo = strctChannelInfo;
ao.active_unit_info = [];

save(strOutFileName, 'ao');
end
