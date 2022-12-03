function finalresult = PB_TwoImage_Population
dd = {'141220','141222','150125','150127','150128','150130','150201'}; 
Unitlist{1} = [2 10 11 13 14 15 16 18];
Unitlist{2}= [2 4 5 7 8 9 10 11 14 17 18 19 20 21];
Unitlist{3} = [12 13 15 16 17 18 19 24];
Unitlist{4} = [3 10 15 16 20 21 26];
Unitlist{5} = [1 3 4 5 10 11];
Unitlist{6} = [1 3 10 11];
Unitlist{7} = [1 2 4 5 8 11 13 14 15 17];



% dd = {'150125'};
% Unitlist{1} = [12 13 15 16 17 18 19 24];

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
        output = PB_TwoImage_SingleUnit('Ozomatli',[],ExpDate,unitstr)
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

save('D:\PB\TwoImageResult\OZ_population.mat', 'finalresult');


return;

close all;
figure;
load('D:\PB\TwoImageResult\OZ_population.mat');

populationresult = finalresult.populationresult;

for i = 1:size(populationresult,4);
    tt = populationresult(:,:,:,i);
    tt = tt/max(tt(:));
    response(:,:,:,i) = tt;
end

response = mean(response,4);
cc = {'ko--','ro-','bo-'};

for i = 1:3
    subplot(1,3,i);
    for j = 1:3;
        plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
        hold on;
    end
    box off
end


clear all;
close all;
figure;
load('D:\PB\TwoImageResult\OZ_population.mat');



populationresult = finalresult.populationresult;

for i = 1:size(populationresult,4);
    tt = populationresult(:,:,:,i);
    tt = tt/max(tt(:));
    response(:,:,:,i) = tt;
end

rr = reshape(response,45,size(response,4));
[coefs,scores,variances,t2] = princomp(rr);
pc1 = scores(:,1);
pc1 = reshape(pc1,3,3,5);
cc = {'ko--','ro-','bo-'};

for k = 1:3
    pc1 = scores(:,k);
    pc1 = reshape(pc1,3,3,5);
    for i = 1:3
        subplot(3,3,(k-1)*3+i);
        for j = 1:3;
            plot(10:20:90,squeeze(pc1(i,j,:)),cc{j},'linewidth',2);
            hold on;
        end
        box off
    end
end

    


