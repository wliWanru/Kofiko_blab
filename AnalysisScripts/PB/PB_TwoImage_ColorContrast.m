function finalresult = PB_TwoImage_Population
dd = {'150821','151001','151003'}
Unitlist{1} = [4 5 11 13:16];
Unitlist{2}= [4 5 8 10];
Unitlist{3} = [15];
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
    fr = PB_TwoImage_SingleUnit('Fez','test',ExpDate,unitstr)
    if ~isnan(output)
        populationresult(:,:,:,k) = output;
        dataentry_date{k} = dd{i};
        dataentry_unitnumber{k} = unitstr;
        k = k + 1;
    end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\TwoImageResult\Rocco_population.mat', 'finalresult');

return;
cc = {'ko--','ro-','bo-'};

load('D:\PB\TwoImageResult\Rocco_population.mat');
tt = finalresult.populationresult;
for cn = 1:size(tt,4);
    figure;

    response = tt(:,:,:,cn);
    for i = 2:3
    subplot(1,2,i-1);
    for j = 1:3;
        plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
        hold on;
    end
    box off
    set(gca,'Linewidth',1);
    set(gca,'FontSize',14);
    end
pause;
set(gcf,'Position', [625   550   671   388]);
close all;

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



        
