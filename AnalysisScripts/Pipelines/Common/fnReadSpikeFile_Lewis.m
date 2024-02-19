function astrctUnits = fnReadSpikeFile_Lewis(strInputFile)

spikefile = load(strInputFile);
fileshape = size(spikefile);
iNumUnits = fileshape(2);


for k=1:iNumUnits
    astrctUnits(k).m_iChannel = (k);
    astrctUnits(k).m_iUnitIndex = aiUnitIndices(k);
    astrctUnits(k).m_afTimestamps = fread(hFileID,aiNumSpikes(k),'double=>double');
    astrctUnits(k).m_a2fWaveforms = reshape(fread(hFileID,iWaveFormLength*aiNumSpikes(k),'single=>double'),aiNumSpikes(k),iWaveFormLength);
    astrctUnits(k).m_afInterval = a2fIntervals(k,:);
end

return;