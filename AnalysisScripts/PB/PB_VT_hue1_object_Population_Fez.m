function finalresult = PB_TwoImage_Population
% dd = {'150214','150216'};
% Unitlist{1} = [1 2 3 4 5 8 12 14 15];
% Unitlist{2}= [3:26 28:30];
 
dd = {'151028','151101'};
Unitlist{1} = [1 3 5 8];
Unitlist{2} = [1 3 4 5 10 11 12 13 14 16 18 20];



Subject = 'Fez';
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
        [fr tcs tcc] = PB_FOB_object_SingleUnit(Subject,'Test',ExpDate,unitstr,0)
        if ~isnan(fr)
            populationresult(:,k) = fr;
            populationresult_tcs(:,:,k) = tcs;
            populationresult_tcc(:,:,k) = tcc;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.populationresult_tcs = populationresult_tcs;
finalresult.populationresult_tcc = populationresult_tcc;

finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\ALO\Fez_population.mat', 'finalresult');

return;

load('D:\PB\ALO\Fez_population.mat');

ff = finalresult.populationresult;
for i = 1:size(ff,2);
    f1 = ff(:,i);
    f1 = f1./(mean(f1));
    ff(:,i)  = f1;
end

fmean = mean(ff,2);
cc ={'g','b','r','c','m','k'}
figure;
for i = 1:6
    bar((i-1)*16+1:i*16,fmean((i-1)*16+1:i*16),cc{i});
    hold on;
end


[coefs,scores,variances,t2] = princomp(zscore(ff));
fmean = scores(:,1);
figure;
for i = 1:6
    bar((i-1)*16+1:i*16,fmean((i-1)*16+1:i*16),cc{i});
    hold on;
end

fmean = scores(:,2);
figure;
for i = 1:6
    bar((i-1)*16+1:i*16,fmean((i-1)*16+1:i*16),cc{i});
    hold on;
end

    

