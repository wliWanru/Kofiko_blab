
function [xx fr] = OcclusionAnalysis(subjID,experiment,day,unit)
usePB = 1;
% xx dim 1:size 2 starting point (left eye? right eye? or nose) 3 


if nargin<5
    doplot = 1;
end

% matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
% mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_FaceFeature_*.mat']);
% if ~isempty(mat)
%     strctUnit = load([matpath mat(1).name]);
%     strctUnit = strctUnit.strctUnit;
%
%     strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
%     for i = 1:length(strctDesign.m_astrctMedia);
%         cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
%         filename{i} = strctDesign.m_astrctMedia(i).m_strName;
%     end
% else
%     output = nan;
%     return;
% end
strctUnit = fnFindMat(subjID,day,experiment,unit,'PB_FaceFeature_0915');
strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

for i = 1:9
    index = (i-1)*10;
    fr(index+1,:) =  strctUnit.m_a2fAvgFirintRate_Stimulus(index+1,:);
    fr(index+2:index+9,:) = strctUnit.m_a2fAvgFirintRate_Stimulus(index+3:index+10,:);
    fr(index+10,:) = strctUnit.m_a2fAvgFirintRate_Stimulus(index+2,:);
end


for i = 1:length(filename)
    fn = filename{i};
    xx = find(fn == '_');
    Name1 = fn(1:xx(1)-1);
    CondMatrix(i,1) = findcond(Name1);
    Name2 = fn(xx(1)+1:xx(2)-1);
    if strcmp(Name2,'c');
        CondMatrix(i,2) = 1;
    elseif strcmp(Name2,'l');
        CondMatrix(i,2) = 2;
    else
        CondMatrix(i,2) = 3;
    end
    Name3 = fn(xx(2)+1:xx(3)-1);
    if strcmp(Name3,'le');
        CondMatrix(i,3) = 1;
    elseif strcmp(Name3,'re');
        CondMatrix(i,3) = 2;
    else
        CondMatrix(i,3) = 3;
    end
    Name4 = fn(xx(3)+1:end);
    CondMatrix(i,4) = str2num(Name4(6:end));
end




if usePB
    [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
    [strctUnit.m_afAvgStimulusResponseMinusBaseline, strctUnit.m_afAvgStimulusResponseMinusBaselineStd, aiCount] = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150,-25,25);
else
    strctUnit.m_afAvgFirintRate_StimulusStd = zeros(size(strctUnit.m_afAvgFirintRate_Stimulus));
    strctUnit.m_afAvgStimulusResponseMinusBaselineStd = zeros(size(strctUnit.m_afAvgFirintRate_Stimulus));
    aiCount = ones(size(strctUnit.m_afAvgFirintRate_StimulusStd));
    strctUnit.m_afAvgStimulusResponseMinusBaseline = strctUnit.m_afAvgStimulusResponseMinusBaseline * 1000;
end

for i = 1:3
    for j = 1:3
        for k = 1:10;
            index = find(CondMatrix(:,2) == i & CondMatrix(:,3) == j & CondMatrix(:,4) == k);
            xx(k,j,i) = strctUnit.m_afAvgFirintRate_Stimulus(index);
        end
    end
   
end

% xx = reshape(xx,10,9);
