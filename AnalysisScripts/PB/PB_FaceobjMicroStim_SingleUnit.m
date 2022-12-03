function [fr lfp] = PB_faceobjMicrostim(subjID,experiment,day,unitnumber,doplot)

if nargin<5;
    doplot = 1;
end


% if size(uniquepos,1) == 1
%     if sum(uniquepos) == 0;
%         pos = 'foveal';
%     else
%         pos = 'RF';
%     end
strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'faceobjmicrostim_ver2');
fr = strctUnit.m_a2fAvgFirintRate_Category;
lfp = strctUnit.m_a2fAvgLFPCategory;

stimpos = [strctUnit.m_strctStimulusParams.m_afPosXRelativeToFixationSpot;strctUnit.m_strctStimulusParams.m_afPosYRelativeToFixationSpot];
stimpos = stimpos';
uniquepos = unique(stimpos,'rows')


if doplot
    h1 = figure;
    tt = max(strctUnit.m_a2fAvgFirintRate_Category(:));
    subplot(2,2,1);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(2,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(3,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(4,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(5,:)','c-','linewidth',2)
    axis([0 800 -10 tt]);
    subplot(2,2,2);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(18,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(19,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(20,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(21,:)','c-','linewidth',2)
    axis([0 800 -10 tt]);
    subplot(2,2,3);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(7,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(8,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(9,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(10,:)','c-','linewidth',2)
    axis([0 800 -10 tt]);
    filename = ['D:\PB\faceobjmicrostim\Spike_' unitnumber '_' day '_' subjID '_ver2.pdf'];
    writepdf(h1,filename);
    
    h2 = figure;
    subplot(2,2,1);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(2,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(3,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(4,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(5,:)','c-','linewidth',2)
    subplot(2,2,2);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(18,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(19,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(20,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(21,:)','c-','linewidth',2)
    subplot(2,2,3);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(7,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(8,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(9,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(10,:)','c-','linewidth',2)
    filename = ['D:\PB\faceobjmicrostim\LFP_' unitnumber '_' day '_' subjID '_ver2.pdf'];
    writepdf(h2,filename);
    
    h3 = figure;
    
    
    for i = 1:4
        subplot(2,2,i);
        hold on;
        plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(6+i,:)','k-','linewidth',2)
        
        plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(1+i,:)','b-','linewidth',2)
        plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(17+i,:)','r-','linewidth',2)
        filename = ['D:\PB\faceobjmicrostim\Spike_OFG_' unitnumber '_' day '_' subjID '_ver2.pdf'];
        
        writepdf(h3,filename);
    end
    
    h4 = figure;
    for i = 1:4
        subplot(2,2,i);
        hold on;
        plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(6+i,:)','k-','linewidth',2)
        
        plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(1+i,:)','b-','linewidth',2)
        plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(17+i,:)','r-','linewidth',2)
        filename = ['D:\PB\faceobjmicrostim\LFP_OFG_' unitnumber '_' day '_' subjID '_ver2.pdf'];
        
        writepdf(h4,filename);
        
        
        
    end
end

function writepdf(figurehandle,epsfilename);
set(figurehandle,'Position',[ 210   153   950   827]);
% if exist([matpath '..\figure\'],'dir');
% else
%     mkdir([matpath '..\figure\']);
% end
set(figurehandle, 'PaperPositionMode', 'auto')
print('-dpdf',epsfilename);