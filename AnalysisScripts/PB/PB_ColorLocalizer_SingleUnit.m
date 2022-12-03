
function output = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'Colorpatchlocalizer');
strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
 xx = size(strctDesign.m_a2bStimulusToCondition,1);
[strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 80, 200);
figure;
plot(strctUnit.m_afAvgFirintRate_Stimulus(151:168),strctUnit.m_afAvgFirintRate_Stimulus(1:18),'ro','Linewidth',2);
hold on;
plot(strctUnit.m_afAvgFirintRate_Stimulus(150+(19:38)),strctUnit.m_afAvgFirintRate_Stimulus(0+(19:38)),'bo','Linewidth',2);
plot(strctUnit.m_afAvgFirintRate_Stimulus(150+(39:58)),strctUnit.m_afAvgFirintRate_Stimulus(0+(39:58)),'mo','Linewidth',2);
plot(strctUnit.m_afAvgFirintRate_Stimulus(150+(59:78)),strctUnit.m_afAvgFirintRate_Stimulus(0+(59:78)),'co','Linewidth',2);
plot(0:max(strctUnit.m_afAvgFirintRate_Stimulus),0:max(strctUnit.m_afAvgFirintRate_Stimulus),'k--');
axis square
tt = max(strctUnit.m_afAvgFirintRate_Stimulus);

yy = strctUnit.m_afAvgFirintRate_Stimulus(1:78) - strctUnit.m_afAvgFirintRate_Stimulus(150+(1:78));
[junk kk] = sort(yy);


% for i = 1:length(kk);
%     
% im = imread(strctDesign.m_astrctMedia(kk(end-i+1)).m_acFileNames{1});
% subplot(2,2,1);
% imshow(im);
% im = imread(strctDesign.m_astrctMedia(150+kk(end-i+1)).m_acFileNames{1});
% subplot(2,2,2);
% imshow(im);
% subplot(2,1,2);
%  plot(-200:450,strctUnit.m_a2fAvgFirintRate_Stimulus(kk(end-i+1),1:651),'r-','linewidth',2);
%         hold on;
%         plot(-200:450,strctUnit.m_a2fAvgFirintRate_Stimulus(150+kk(end-i+1),1:651),'k-','linewidth',2);pause;
%         hold off;
% end

figure;
for i = 1:5
    subplot(2,3,i);
    if i < 5
        plot(-200:800,strctUnit.m_a2fAvgLFPCategory(i,1:1001),'r-','linewidth',2);
        hold on;
        plot(-200:800,strctUnit.m_a2fAvgLFPCategory(i+8,1:1001),'k-','linewidth',2);
        Titlename = strctUnit.m_acConditionNames{i};
        h = title(Titlename(6:end));
        set(h,'fontsize',14);
    else
        plot(-200:800,strctUnit.m_a2fAvgLFPCategory(5,1:1001),'k-','linewidth',2);
        hold on
        plot(-200:800,strctUnit.m_a2fAvgLFPCategory(8,1:1001),'-','Color',[0.7 0.7 0.7],'linewidth',2);
        plot(-200:800,strctUnit.m_a2fAvgLFPCategory(6,1:1001),'r-','linewidth',2);
        plot(-200:800,strctUnit.m_a2fAvgLFPCategory(7,1:1001),'b-','linewidth',2);
        h = title('Grating');        
        set(h,'fontsize',14);

    end
    box off
set(gca,'linewidth',2);
end


figure;
for i = 1:5
    subplot(2,3,i);
    if i < 5
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(i,1:651),'r-','linewidth',2);
        hold on;
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(i+8,1:651),'k-','linewidth',2);
        Titlename = strctUnit.m_acConditionNames{i};
        h = title(Titlename(6:end));
        set(h,'fontsize',14);
    else
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(5,1:651),'k-','linewidth',2);
        hold on
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(8,1:651),'-','Color',[0.7 0.7 0.7],'linewidth',2);
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(6,1:651),'r-','linewidth',2);
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(7,1:651),'b-','linewidth',2);
        h = title('Grating');        
        set(h,'fontsize',14);

    end
    box off
set(gca,'linewidth',2);
end

return;

