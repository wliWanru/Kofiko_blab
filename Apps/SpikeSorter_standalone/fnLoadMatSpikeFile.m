function [astrctRawUnits,strctChannelInfo] = fnLoadMatSpikeFile(strInputFile, varargin)

ao = load(strInputFile).('ao');
ao_SEG = ao.SEG; 
n_RawUnits = size(ao_SEG, 2);

for i_RawUnit = 1:n_RawUnits
    astrctRawUnits(i_RawUnit).m_iUnitIndex = ao_SEG(i_RawUnit).unit_index;
    astrctRawUnits(i_RawUnit).m_afTimestamps = (double(ao_SEG(i_RawUnit).waveforms_timestamps) / 44000)';
    astrctRawUnits(i_RawUnit).m_a2fWaveforms = double(ao_SEG(i_RawUnit).waveforms)';
    astrctRawUnits(i_RawUnit).m_afInterval = ao_SEG(i_RawUnit).interval;
end


strctChannelInfo = ao.strctChannelInfo;


return;
