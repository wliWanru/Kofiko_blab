function finalresult = PB_TwoImage_Population
dd = {'140904','140827','140814','140809','140909','140911','140914','140915'}
Unitlist{1} = 0;
Unitlist{2}= [6 8 10];
Unitlist{3} = [6 9];
Unitlist{4} = [7 10];
Unitlist{5} = 0;
Unitlist{6} = 0; % 63 neurons
Unitlist{7} = [16 18 33 34 35];
Unitlist{8} = [8 10 17 28 26 27 28 29];
Subject = 'Rocco';
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
        close all;
        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]
        output = PB_TwoImage_SingleObject_SingleUnit('Rocco','test',ExpDate,unitstr)
        if ~isnan(output)
            populationresult(:,:,:,:,:,k) = output;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\TwoImageResult\Rocco_TwoImage_SingleObject_population.mat', 'finalresult');

return;
figure;
cc = {'ro-','bo-','ko--'};
load('D:\PB\TwoImageResult\Rocco_TwoImage_SingleObject_population.mat');
fr = finalresult.populationresult;
for i = 1:size(fr,6)
    tt = fr(:,:,:,:,:,i);
    tt = tt/mean(tt(:));
    frn(:,:,:,:,:,i) = tt;
end
ff = mean(frn,6);
for k = 1:3
    for j = 1:4
        subplot(3,4,(k-1)*4+j);
        rr = ff(:,j,:,:,k);
        rr = mean(rr,1);
        rr = squeeze(rr);
        for m = 1:3
            plot(10:20:90,rr(:,m),cc{m},'linewidth',2);
            hold on;
        end
    end
end



load('D:\PB\TwoImageResult\Rocco_population.mat');
populationresult = finalresult.populationresult;
for i = 1:size(populationresult,4);
    tt = populationresult(:,:,:,i);
    tt = tt/mean(tt(:));
    response(:,:,:,i) = tt;
end

response = mean(response,4);

for i = 2:3
    subplot(1,2,i-1);
    for j = 1:3;
        plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
        hold on;
    end
    box off
    set(gca,'Linewidth',2);
    set(gca,'FontSize',12);
end

set(gcf,'Position',[457         645        1109         330]);




