function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)
if nargin < 5
    doplot = 1;
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'TwoImageUD');
xx = max(strctUnit.m_aiStimulusIndex);

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);

fr = fr([26:30 1:5 21:25 15:-1:11 20:-1:16 10:-1:6]);

for i = 1:2
    for j = 1:3
        ff(i,j,:) = fr((i-1)*15+(j-1)*5+1:(i-1)*15+(j-1)*5+5);
    end
end




if doplot
    figure;
    cc = {'ko--','ro-','bo-'};
    
    for i = 1:2
        subplot(1,2,i);
        jj = ff;
        for j = 1:3;
            plot(10:20:90,squeeze(jj(i,j,:)),cc{j},'linewidth',1);
            hold on;
        end
        hold off
        set(gca,'Linewidth',1);
        set(gca,'FontSize',12);
        set(gca,'XTick',10:20:90);
        % set(gca,'XTickLabel',[]);
        box off
    end
    
    
end

