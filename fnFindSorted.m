function [a2fIntervals a2fUnitIndex] = fnFindMat(subjID,foldername,experiment);


if ~isempty(experiment)
    matpath = ['C:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SortedUnits\'];
else
    matpath = ['C:\PB\EphysData\' subjID '\' foldername '\Processed\SingleUnitDataEntries\'];
end


xx = dir([matpath '*_ch1_sorted.raw']);
fn = [matpath xx(1).name];

[astrctRAW] = fnReadDumpSpikeFile(fn,'HeaderOnly');

aiSortedIntervals = find(cat(1,astrctRAW.m_iUnitIndex) >0);
astrctRAWSorted=astrctRAW(aiSortedIntervals);
% aiUnitVertical = fnGetIntervalVerticalValueAux(astrctRAWSorted);
% 
% iNumIntervals = length(aiUnitVertical);
a2fIntervals = cat(1,astrctRAWSorted.m_afInterval);
a2fUnitIndex = cat(1,astrctRAWSorted.m_iUnitIndex);
