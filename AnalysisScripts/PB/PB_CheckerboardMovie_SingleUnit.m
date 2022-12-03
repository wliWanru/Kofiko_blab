function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)

if nargin<5;
    doplot = 1;
end


strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'CheckerboardMovie');

% load('D:\PB\EphysData\Ozomatli\150216\RAW\..\Processed\SingleUnitDataEntries\Ozomatli_2015-02-16_15-33-21_Exp_NaN_Ch_001_Unit_004_Passive_Fixation_New_ClutteredFaceNew.mat');
% strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
% for i = 1:length(strctDesign.m_astrctMedia);
%     filename{i} = strctDesign.m_astrctMedia(i).m_strName;
% end
fr = strctUnit.m_a2fAvgFirintRate_Stimulus;
tt = fr(13:16,:);
fr(13:16,:) = [];
fr = [tt;fr];

if doplot
    figure;
    for i = 1:4
        subplot(4,2,(i-1)*2+1);
        hold on;
        plot(fr((i-1)*4+1,:),'linewidth',2);
        plot(fr((i-1)*4+2,:),'r','linewidth',2);
         subplot(4,2,(i-1)*2+2);
        hold on;
        plot(fr((i-1)*4+3,:),'linewidth',2);
        plot(fr((i-1)*4+4,:),'r','linewidth',2);
    end
        
end


