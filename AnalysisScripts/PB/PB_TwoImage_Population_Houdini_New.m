function finalresult = PB_TwoImage_Population
dd = {'150319','150322','150402','150420','150423','150515'}
Unitlist{1} = [1];
Unitlist{2} = [2 3 25];
Unitlist{3} = [5:10 17 18 20];
Unitlist{4} = [6 8];
Unitlist{5} = [2 5 8 9 14 15];
Unitlist{6} = [4 5 7 15];

Subject = 'Houdini';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
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
        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]
    
            output = PB_TwoImage_SingleUnit(Subject,'test',ExpDate,unitstr,[60 220])
        
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
save('D:\PB\TwoImageResult\Houdini_AL_population.mat', 'finalresult');

return;

clear all;
figure;
load('D:\PB\TwoImageResult\Houdini_AL_population.mat');
populationresult = finalresult.populationresult;
for i = 1:size(populationresult,4);
    tt = populationresult(:,:,:,i);
    tt = tt/mean(tt(:));
    response(:,:,:,i) = tt;
end

response = mean(response,4);
cc = {'ko--','ro-','bo-'};

for i = 2:3
    subplot(1,2,i-1);
    for j = 1:3;
        plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
        hold on;
    end
    box off
end
%set(gcf,'Position',[ 680         673        1161         305]);

