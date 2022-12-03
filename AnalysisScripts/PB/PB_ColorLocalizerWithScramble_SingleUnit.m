function [tc fr] = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'ColorLocalizerwithScamble');
xx = max(strctUnit.m_aiStimulusIndex);
fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);


%
xx =[1 2 12 17
    3 4 13 18
    5 6 14 19
    7 8 15 20];
name = {'Animal','Face','Object','Scene','SineGrating'};
tc = strctUnit.m_a2fAvgFirintRate_Category;
%return;
figure;
for i = 1:5
    subplot(2,3,i);
    if i < 5
       
        a = xx(i,1); b = xx(i,2); c = xx(i,3); d = xx(i,4);
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(a,1:651),'r-','linewidth',2);
        hold on;
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(b,1:651),'r--','linewidth',2);
                plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(d,1:651),'k-','linewidth',2);

        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(c,1:651),'k--','linewidth',2);
        if i == 4
            legend('IntactColor','ScrambleColor','IntactBW','ScrableBW');
        end
         h = title(name{i});
        set(h,'FontSize',12);

    else
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(9,1:651),'k-','linewidth',2);
        hold on
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(16,1:651),'-','Color',[0.7 0.7 0.7],'linewidth',2);
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(10,1:651),'r-','linewidth',2);
        plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(11,1:651),'b-','linewidth',2);
    end
    box off
set(gca,'linewidth',2);

end

return;

