function finalresult = PB_TwoImage_Population(region)
% dd = {'150214','150216'};
% Unitlist{1} = [1 2 3 4 5 8 12 14 15];
% Unitlist{2}= [3:26 28:30];

switch region
    case 'ALThreed';
        dd = {'160710','160713'}; % ALThreed... but not true.
        Unitlist{1} = [1:4 10 11 13 15 16 18];
        Unitlist{2} = [1 6 7 8 15 16 18 20];
    case 'ABody';
        dd = {'160730','160805'};
        Unitlist{1} = [1 2 3 4 9 12 13];
        Unitlist{2} = [2 9 10 13 14 18 19 22];
    case 'ML';
        dd = {'160922','160925','160927','160929','160930'};
        Unitlist{1} = [1 4 9 10];
        Unitlist{2} = [2];
        Unitlist{3} = [1 11];
        Unitlist{4} = [2 3 4 9 12:14];
        Unitlist{5} = [2 3 6 9 10 12];
end

Subject = 'Alfie';
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
        
        [ExpDate unitstr];
        [fr frmb tcs tcc] = PB_FOB_object_SingleUnit(Subject,'Test',ExpDate,unitstr,0);
        if ~isnan(fr)
            populationresult(:,k) = frmb;
                        fob(:,k) = tcs;

            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.fob = fob;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save(['C:\PB\RotationImages\Alfie_' region '_population.mat'], 'finalresult');

return;

figure
load(['C:\PB\RotationImages\Alfie_ABody_population.mat'])

fr = finalresult.populationresult;
fr(isnan(fr)) = 0;
for i = 1:size(fr,2);
    tt = fr(:,i);
    tt = tt/max(tt);
    fr_n(:,i) = tt;
end

[coefs,scores,variances,t2] = princomp(zscore(fr_n));
[junk index] = sort(coefs(:,1));
imshow(fr_n');
it  = wd_compit4_1;
colormap(it);
