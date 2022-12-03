function [fr fc lfpc lfpr] = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,time,doplot)
if nargin < 6
    doplot = 1;
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'OcclusionMovie',time);

if isempty(strctUnit)
    fr = nan;
    return;
end

% load('D:\PB\EphysData\Ozomatli\150216\RAW\..\Processed\SingleUnitDataEntries\Ozomatli_2015-02-16_15-33-21_Exp_NaN_Ch_001_Unit_004_Passive_Fixation_New_ClutteredFaceNew.mat');
% strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
% for i = 1:length(strctDesign.m_astrctMedia);
%     filename{i} = strctDesign.m_astrctMedia(i).m_strName;
% end
fc = strctUnit.m_a2fAvgFirintRate_Category;
fr = strctUnit.m_a2fAvgFirintRate_Stimulus;
fc = fc(:,1:1101);
fr = fr(:,1:1101);


 lfpc = strctUnit.m_a2fAvgLFPCategory;
 lfpr = fnAverageBy(strctUnit.m_a2fLFP(strctUnit.m_abValidTrials,:), strctUnit.m_aiStimulusIndexValid, diag(1:8)>0,0);

lfpc = lfpc(:,1:1101);
lfpr = lfpr(:,1:1101);



lfp = strctUnit.m_a2fAvgFirintRate_Stimulus
lfp = lfp(:,1100);
    if doplot
        h1=figure;
        subplot(2,1,1)
        hold on;
        plot(-200:900,fc(1,:),'b-','linewidth',2);
        plot(-200:900,fc(2,:),'r-','linewidth',2);
        title('AvgResponse');
        for i = 1:4
            subplot(4,2,4+i);
            hold on;
            plot(-200:900,fr((i-1)*2+1,:),'b-','linewidth',2);
            plot(-200:900,fr((i-1)*2+2,:),'r-','linewidth',2);
            title(['Face-' int2str(i)]);
        end
        writepdf(h1,['D:\PB\OcclusionMovie\' subjID '_' day '_' time '_' unitnumber '.pdf']);
    end





