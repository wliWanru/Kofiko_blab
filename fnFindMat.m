function [strctUnit rawfolder] = fnFindMat(subjID,foldername,experiment,unitnumber,xmlname,time);

if nargin < 6
    time = [];
end

if ~isempty(experiment)
    matpath = ['C:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
else
    matpath = ['C:\PB\EphysData\' subjID '\' foldername '\Processed\SingleUnitDataEntries\'];
end
if ~isempty(time)
    mat = dir([matpath '*' time '*_Unit_' unitnumber '_Passive_Fixation_New_' xmlname '*.mat']);
else
    mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_' xmlname '*.mat']);
end

if isempty(mat)
    strctUnit = [];
    matfnname = [];
else
    strctUnit = load([matpath mat(1).name]);
    matfnname = [matpath mat(1).name];
    mat(1).name
    strctUnit = strctUnit.strctUnit;
end


