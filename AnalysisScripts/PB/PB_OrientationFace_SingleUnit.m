function fr = PB_Oirientation_SingleUnit(subjID,experiment,day,unitnumber,doplot)

if nargin<5;
    doplot = 1;
end


strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'orientationface');
FOBUnit = fnFindMat(subjID,day,experiment,unitnumber,'FOB');
[fr_FOB, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAverageBy(FOBUnit.m_a2bRaster_Valid, FOBUnit.m_aiStimulusIndexValid, FOBUnit.m_a2bStimulusToCondition, 10,1);
faceResponse = fr_FOB(1,:);
objResponse = mean(fr_FOB(2:end,:));


if isempty(strctUnit)
    fr = nan;
    return;
end

% load('D:\PB\EphysData\Ozomatli\150216\RAW\..\Processed\SingleUnitDataEntries\Ozomatli_2015-02-16_15-33-21_Exp_NaN_Ch_001_Unit_004_Passive_Fixation_New_ClutteredFaceNew.mat');
strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

a2bStimulusToCondition = zeros(length(filename),16);
%1-7 Face (full/Occluded_left/Occluded_Right center left right);
%8- 12 Obj (8:full 9 left full 10 left occluded 11 right full right
%occluded)

%13 1face 1face nothing
%14 nothing 1face 1obj
%15 1face 1face nothing
%16 1obj 1face nothing
%17 nothing 0Face 0 face
%18 nothng 0face 0 obj
%19 0face 0face nothing
%20 0obj 0face nothing

for i = 1:length(filename);
    fn = filename{i};
    cond = (str2double(fn(1))-1)*4 + str2double(fn(3));
    a2bStimulusToCondition(i,cond) = 1;
    cc(i) = cond;
end
[fr, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAverageBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, a2bStimulusToCondition, 10,1);
fr(17,:) = faceResponse;
fr(18,:) = objResponse;
if doplot
    for j = 1:4
        figure;
        for i = 1:4
            subplot(2,4,(i*2)-1);
            hold on;
            plot(-200:900,fr(17,:),'r-','linewidth',2)
            plot(-200:900,fr((j-1)*4+i,:),'k-','linewidth',2);
            plot(-200:900,fr(18,:),'b-','linewidth',2);
            subplot(2,4,i*2);
            imshow(imread(strctDesign.m_astrctMedia((j-1)*4+i).m_acFileNames{1}));
        end
        set(gcf,'Position',[ 415         432        1131         550]);
    end
end


