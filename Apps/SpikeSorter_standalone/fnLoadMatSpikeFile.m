function [astrctRawUnits,strctChannelInfo, astrctAnnotatedIntervals] = fnLoadMatSpikeFile(strInputFile, rawSpikeFlag)
strInputFile
ao = load(strInputFile);
ao = ao.ao;
ao_SEG = ao.SEG;
n_RawUnits = size(ao_SEG, 2);

for i_RawUnit = 1:n_RawUnits
    astrctRawUnits(i_RawUnit).m_iUnitIndex = ao_SEG(i_RawUnit).unit_index;
    astrctRawUnits(i_RawUnit).m_afTimestamps = (double(ao_SEG(i_RawUnit).waveforms_timestamps) / 44000)'- ao.t_TimeBegin;
    astrctRawUnits(i_RawUnit).m_a2fWaveforms =  ao_SEG(i_RawUnit).waveforms;
    astrctRawUnits(i_RawUnit).m_afInterval = ao_SEG(i_RawUnit).interval;
end

strctChannelInfo = ao.strctChannelInfo;
astrctAnnotatedIntervals = ao.active_unit_info;

return;
