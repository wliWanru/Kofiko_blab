function finalresult = PB_TwoImage_Population(region);

if nargin < 1
    region = 'ALThreed';
end


switch region
    case 'ALThreed'
        dd = {'160714','160715'};
        Unitlist{1} = [1 2 14 16];
        Unitlist{2} = [7 8 22];
    case 'ABody';
        dd = {'160809','160811'};
        Unitlist{1}  = [2 3 6 7 8 10 14 16 18 21];
        Unitlist{2} = [8 9 10 11 16 19 20 22];
    case 'MBody';
        dd = {'160901','160902'};
        Unitlist{1} = [19];
        Unitlist{2} = [4 12 13 15];
    case 'AMB';
        dd = {'160914'};
        Unitlist{1} = [4 5];
    case 'ML'
        

end
Unitlist
Subject = 'Alfie';
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
        [fr fr_rb tc] = PB_wholerotationimage_SingleUnit(Subject,'Test',ExpDate,unitstr,0);
        if ~isnan(fr)
            frall(:,k) = fr;
            fr_rball(:,k) = fr_rb;
            tcall(:,:,k) = tc;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.fr = frall;
finalresult.fr_rb = fr_rball;
finalresult.tcall = tcall;

finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save(['C:\PB\RotationImages\Alfie_transformRotation_population_' region '.mat'], 'finalresult');

return;

clear all;
load('C:\PB\RotationImages\Alfie_RotationImage_population_ALThreed.mat');
fr = finalresult.fr;
for i = 1:size(fr,2);
    tt = fr(:,i);
    tt = reshape(tt,24,51);
    tt = mean(tt,1);
    tt = tt/max(tt);
    fr_n(:,i) = tt;
end
figure;
[coefs,scores,variances,t2] = princomp(zscore(fr_n));
[junk index] = sort(coefs(:,1));
it  = wd_compit4_1;
imshow(fr_n(:,index)');
colormap(it);



