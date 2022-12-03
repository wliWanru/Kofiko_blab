function finalresult = PB_TwoImage_Population
% dd = {'150214','150216'};
% Unitlist{1} = [1 2 3 4 5 8 12 14 15];
% Unitlist{2}= [3:26 28:30];

dd = {'151124'};
Unitlist{1} = [6 7 8 9 10 11 12 14 16 17 18];


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
        [fr ff] = PB_hand_SingleUnit(Subject,'Test',ExpDate,unitstr)
        if ~isnan(fr)
            populationresult(:,:,k) = fr*1000;
            populationresult_ff(:,:,k) = ff*1000;
            
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.populationresult_ff = populationresult_ff;

finalresult.dataentry_date = dataentry_date;
%finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\ALO\Fez_handregion_population.mat', 'finalresult');

return;

clear all;
load('D:\PB\ALO\Fez_handregion_population.mat');
figure;
fr = finalresult.populationresult_ff;
fr(isnan(fr)) = 0;
for i = 1:size(fr,3);
    f1 = fr(:,:,i);
    f1 = f1./(mean(f1(:)));
    fr(:,:,i)  = f1;
end

fr = mean(fr,3);

category = {'face','fruit','mammal','bird','buttlefly','blank','cubic'}
 for i = 1:7
subplot(2,4,i);
plot(-99:400,fr(1,101:600)','b-', 'linewidth',2)
hold on;
plot(-99:400,fr(i+1,101:600)','r-','linewidth',2)
title(category{i})
 end

figure;
fr = finalresult.populationresult_ff;
for i = 1:size(fr,3);
    f1 = fr(:,:,i);
    f1 = f1./(mean(f1(:)));
    fr(:,:,i)  = f1;
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

dissimilarities = pdist(ff);
[Y,stress,disparities] = mdscale(dissimilarities,2);

figure;
distances = pdist(Y);
[dum,ord] = sortrows([disparities(:) dissimilarities(:)]);
plot(dissimilarities,distances,'bo', ...
    dissimilarities(ord),disparities(ord),'r.-');
xlabel('Dissimilarities'); ylabel('Distances/Disparities')
legend({'Distances' 'Disparities'},'Location','NW');

index = 1:107;
for j = 1:length(index);
    ss{j} = int2str(index(j));
end




showmds(Y,ss,1);



