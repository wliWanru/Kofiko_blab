function finalresult = PB_ColorLocalizerwithScramble_Population
dd = {'150617'};
Unitlist{1} = [1 2 4 5 10 11 12 13 20 21 25 26 27 28];

Subject = 'Ozomatli';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' Subject '\' ExpDate '\Processed\SingleUnitDataEntries\'];
        xx = dir([Datafolder '*.mat']);
        for j = 1:length(xx)
            fn = xx(j).name;
            tt = find(fn == '_');
            unitnumber(j) = str2num(fn(tt(8)+1:tt(9)-1));
        end
        unitnumber = unique(unitnumber);
    end
    for j = 1:length(unitnumber)
        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]       
       [tc fr] = PB_COlorLocalizerWithScramble_SingleUnit(Subject,[],ExpDate,unitstr,0)
        if ~isnan(tc)
            populationresult(:,:,k) = tc;
            frresult(:,k) = fr;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end
finalresult.frresult = frresult;
finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\Colorpatch\ColorObject\OZ_ColorLocalizerWithScramble_CLc_population.mat', 'finalresult'); 

return;

load('D:\PB\Colorpatch\ColorObject\OZ_ColorLocalizerWithScramble_CLc_population.mat');
fr = finalresult.populationresult;
figure;
for i = 1:size(fr,3)
    tt = fr(:,:,i);
    tt = tt/mean(tt(:));
    frnorm(:,:,i) = tt;
end
frnorm = mean(frnorm,3);
frnorm = squeeze(frnorm);
xx =[1 2 12 17
    3 4 13 18
    5 6 14 19
    7 8 15 20];
name = {'Animal','Face','Object','Scene','SineGrating'};

for i = 1:5
    subplot(2,3,i);
    if i < 5
       
        a = xx(i,1); b = xx(i,2); c = xx(i,3); d = xx(i,4);
        plot(-200:450,frnorm(a,1:651),'r-','linewidth',2);
        hold on;
        plot(-200:450,frnorm(b,1:651),'r--','linewidth',2);
                plot(-200:450,frnorm(d,1:651),'k-','linewidth',2);

        plot(-200:450,frnorm(c,1:651),'k--','linewidth',2);
        if i == 4
            legend('IntactColor','ScrambleColor','IntactBW','ScrambleBW');
        end
         h = title(name{i});
        set(h,'FontSize',12);

    else
        plot(-200:450,frnorm(9,1:651),'k-','linewidth',2);
        hold on
        plot(-200:450,frnorm(16,1:651),'-','Color',[0.7 0.7 0.7],'linewidth',2);
        plot(-200:450,frnorm(10,1:651),'r-','linewidth',2);
        plot(-200:450,frnorm(11,1:651),'b-','linewidth',2);
        h = title(name{i});
        set(h,'FontSize',12);
    end
    box off
set(gca,'linewidth',2);
axis([-200 450 0 5]);
end