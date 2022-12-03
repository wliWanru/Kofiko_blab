function PB_FaceobjMicrostim_population

dd = {'150225'};
Unitlist{1} = [7 8 9 12 13];
%Unitlist{1} = [3 4 5 7 8 9 10 11];
Subject = 'Rocco';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' Subject '\test\' ExpDate '\Processed\SingleUnitDataEntries\'];
        xx = dir([Datafolder '*.mat']);
        for j = 1:length(xx)
            fn = xx(j).name;
            tt = find(fn == '_');
            unitnumber(j) = str2num(fn(tt(8)+1:tt(9)-1));
        end
        unitnumber = unique(unitnumber);
    end
    for j = 1:length(unitnumber)
            close all;

        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]
        [fr lfp] = PB_FaceobjMicrostim_SingleUnit(Subject,'test',ExpDate,unitstr,1)
        if ~isnan(fr)
            populationresult(:,:,k) = fr;
            populationlfp(:,:,k) = lfp;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end
finalresult.populationlfp = populationlfp;
finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\faceobjmicrostim\Rocco_population_ver2.mat', 'finalresult');

return;

unitnumber = 'Population'; day = 'Ver2'; subjID = 'Rocco';

load('D:\PB\faceobjmicrostim\Rocco_population_ver2.mat');
populationresult = finalresult.populationresult;
for i = 1:size(populationresult,3);
    tt = populationresult(:,:,i);
    tt = tt/max(tt(:));
    response(:,:,i) = tt;
end
fr = mean(response,3);
strctUnit.m_a2fAvgFirintRate_Category = fr;
LFP = mean(finalresult.populationlfp,3);
strctUnit.m_a2fAvgLFPCategory = LFP;
doplot = 1;
if doplot
    h1 = figure;
    tt = max(strctUnit.m_a2fAvgFirintRate_Category(:));
    subplot(2,2,1);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(2,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(3,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(4,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(5,:)','c-','linewidth',2)
    axis([0 800 -0.1 1]);
    subplot(2,2,2);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(18,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(19,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(20,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(21,:)','c-','linewidth',2)
    axis([0 800 -0.1 1]);
    subplot(2,2,3);
    hold on;
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(7,:)','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(8,:)','r-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(9,:)','k-','linewidth',2)
    plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(10,:)','c-','linewidth',2)
    axis([0 800 -0.1 1]);
    filename = ['D:\PB\faceobjmicrostim\Spike_' unitnumber '_' day '_' subjID '.pdf'];
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
    filename = ['D:\PB\faceobjmicrostim\LFP_' unitnumber '_' day '_' subjID '.pdf'];
    writepdf(h2,filename);
    
    h3 = figure;
    
    
    for i = 1:4
        subplot(2,2,i);
        hold on;
        plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(6+i,:)','k-','linewidth',2)
        
        plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(1+i,:)','b-','linewidth',2)
        plot(-200:2000,strctUnit.m_a2fAvgFirintRate_Category(17+i,:)','r-','linewidth',2)
        filename = ['D:\PB\faceobjmicrostim\Spike_OFG_' unitnumber '_' day '_' subjID '.pdf'];
        
        writepdf(h3,filename);
    end
    
    h4 = figure;
    for i = 1:4
        subplot(2,2,i);
        hold on;
        plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(6+i,:)','k-','linewidth',2)
        
        plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(1+i,:)','b-','linewidth',2)
        plot(-200:2000,strctUnit.m_a2fAvgLFPCategory(17+i,:)','r-','linewidth',2)
        filename = ['D:\PB\faceobjmicrostim\LFP_OFG_' unitnumber '_' day '_' subjID '.pdf'];
        
        writepdf(h4,filename);
        
        
        
    end
end


