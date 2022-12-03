function finalresult = PB_ColorLocalizerwithScramble_Population
dd = {'150810','150812','150813'};
Unitlist{1} = [4 6 11 12 14 15 16 17];
Unitlist{2} = [1 3 8 10 13];
Unitlist{3} = [1 3 6 7 8 11];

Subject = 'Fez';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
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
        [tc fr] = PB_COlorLocalizerWithScramble_SingleUnit(Subject,'Test',ExpDate,unitstr,0)
        if ~isnan(tc)
            populationresult(:,:,k) = tc;
            frresult(:,k) = fr;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.frresult = frresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\Colorpatch\ColorObject\Fez_ColorLocalizerWithScramble_population.mat', 'finalresult');

return;
load('D:\PB\Colorpatch\ColorObject\Fez_ColorLocalizerWithScramble_population.mat');
strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\ColorLocalizer\ColorLocalizerwithScamble.xml', false, false);
for i = 1:length(strctDesign.m_astrctMedia)
    fn = strctDesign.m_astrctMedia(i).m_strName;
    if strcmpi(fn(1:5),'color')
        cc(i,1) = 1
        if strcmpi(fn(6),'a')
            cc(i,2) = 1;
        elseif strcmpi(fn(6),'f');
            cc(i,2) = 2;
        elseif strcmpi(fn(6),'o');
            cc(i,2) = 3;
        elseif strcmpi(fn(6),'s');
            cc(i,2) = 4;
        else
            cc(i,2) = 5;
        end
        if cc(i,2) < 5
            kk = find(fn=='_');
            if strcmpi(fn(kk-1),'d');
                cc(i,3) = 2;
            else
                cc(i,3) = 1;
            end
        else
            cc(i,3) = 0;
        end
    else
        cc(i,1) = 2;
        
        if strcmpi(fn(8),'a')
            cc(i,2) = 1;
        elseif strcmpi(fn(8),'f');
            cc(i,2) = 2;
        elseif strcmpi(fn(8),'o');
            cc(i,2) = 3;
        elseif strcmpi(fn(8),'s');
            cc(i,2) = 4;
        else
            cc(i,2) = 5;
        end
        if cc(i,2) < 5
            kk = find(fn=='_');
            if strcmpi(fn(kk-1),'d');
                cc(i,3) = 2;
            else
                cc(i,3) = 1;
            end
        else
            cc(i,3) = 0;
        end
    end
    cc(i,4) = str2num(fn(end-1:end));
end
figure;
fr = finalresult.frresult;
for j = 1:size(fr,2)
    ff = fr(:,j);
    for i = 1:4
        t1 = find(cc(:,1) == 1 & cc(:,2) == i & cc(:,3) == 1);
        t2 = find(cc(:,1) == 2 & cc(:,2) == i & cc(:,3) == 1);
        subplot(4,4,i)
        plot(ff(t1),ff(t2),'.','MarkerSize',20);
        tt = corrcoefomitnan(ff(t1),ff(t2))
        
        cr(j,i,1) = tt(1,2);
        t1 = find(cc(:,1) == 1 & cc(:,2) == i & cc(:,3) == 2);
        t2 = find(cc(:,1) == 2 & cc(:,2) == i & cc(:,3) == 2);
        subplot(4,4,i+4)
        tt = corrcoefomitnan(ff(t1),ff(t2))
        cr(j,i,2) = tt(1,2);
        
        cr(j,i,2) = tt(1,2);
        plot(ff(t1),ff(t2),'.','MarkerSize',20);
        t1 = find(cc(:,1) == 1 & cc(:,2) == i & cc(:,3) == 1);
        t2 = find(cc(:,1) == 1 & cc(:,2) == i & cc(:,3) == 2);
        tt = corrcoefomitnan(ff(t1),ff(t2))
        cr(j,i,3) = tt(1,2);
        
        t1 = find(cc(:,1) == 2 & cc(:,2) == i & cc(:,3) == 1);
        t2 = find(cc(:,1) == 2 & cc(:,2) == i & cc(:,3) == 2);
        subplot(4,4,i+12)
        plot(ff(t1),ff(t2),'.','MarkerSize',20);
        tt = corrcoefomitnan(ff(t1),ff(t2))
        cr(j,i,4) = tt(1,2);
        
    end
end

figure;

for j = 1:size(fr,2)
    ff = fr(:,j);
    t1 = find(cc(:,1) == 1  & cc(:,3) == 1);
    t2 = find(cc(:,1) == 2  & cc(:,3) == 1);
    subplot(2,2,1)
    plot(ff(t1),ff(t2),'.','MarkerSize',10);
    hold on;
    plot(0:max([ff(t1);ff(t2)]),0:max([ff(t1);ff(t2)]),'r-','linewidth',2);
    hold off;
    
    [tt p q] = corrcoefomitnan(ff(t1),ff(t2));
    ct(j,1) = tt(1,2);
    pt(j,1) = p(1,2);
    
    t1 = find(cc(:,1) == 1  & cc(:,3) == 2);
    t2 = find(cc(:,1) == 2  & cc(:,3) == 2);
    [tt p q] = corrcoefomitnan(ff(t1),ff(t2));
    ct(j,2) = tt(1,2);
    pt(j,2) = p(1,2);
    subplot(2,2,2)
    plot(ff(t1),ff(t2),'.','MarkerSize',10);
    hold on;
    plot(0:max([ff(t1);ff(t2)]),0:max([ff(t1);ff(t2)]),'r-','linewidth',2);
    hold off;
    
    t1 = find(cc(:,1) == 1  & cc(:,3) == 1);
    t2 = find(cc(:,1) == 1  & cc(:,3) == 2);
    [tt p q] = corrcoefomitnan(ff(t1),ff(t2));
    ct(j,3) = tt(1,2);
    pt(j,3) = p(1,2);
    subplot(2,2,3)
    plot(ff(t1),ff(t2),'.','MarkerSize',10);
    hold on;
    plot(0:max([ff(t1);ff(t2)]),0:max([ff(t1);ff(t2)]),'r-','linewidth',2);
    hold off;
    
    t1 = find(cc(:,1) == 2  & cc(:,3) == 1);
    t2 = find(cc(:,1) == 2  & cc(:,3) == 2);
    [tt p q] = corrcoefomitnan(ff(t1),ff(t2));
    ct(j,4) = tt(1,2);
    pt(j,4) = p(1,2);
    subplot(2,2,4)
    plot(ff(t1),ff(t2),'.','MarkerSize',10);
    hold on;
    plot(0:max([ff(t1);ff(t2)]),0:max([ff(t1);ff(t2)]),'r-','linewidth',2);
    hold off;
end











load('D:\PB\Colorpatch\ColorObject\Fez_ColorLocalizerWithScramble_population.mat');
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
            legend('IntactColor','ScrambleColor','IntactBW','ScrableBW');
        end
        h = title(name{i});
        set(h,'FontSize',12);
        
    else
        plot(-200:450,frnorm(9,1:651),'k-','linewidth',2);
        hold on
        plot(-200:450,frnorm(16,1:651),'-','Color',[0.7 0.7 0.7],'linewidth',2);
        plot(-200:450,frnorm(10,1:651),'r-','linewidth',2);
        plot(-200:450,frnorm(11,1:651),'b-','linewidth',2);
    end
    box off
    set(gca,'linewidth',2);
    axis([-200 450 0 5]);
end