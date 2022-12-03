function finalresult = PB_TwoImage_Population(subj,region);


%[dd Unitlist] = ppdata('Alfie',region);

if strcmp(subj,'Alfie');
    if strcmp(region,'ALO');
        dd = {'170728','170726','170723','170719','170712','170710'};
        Unitlist{1} = [5 6 17 20 21];
        Unitlist{2} = [2 3 7 9 10 14 15 16 17];
        Unitlist{3} = [1 3 8 11 12 15 18 19];
        Unitlist{4} = [5 6];
        Unitlist{5} = [3 10 12 13 14];
        Unitlist{6} = [8 11 12];
    elseif strcmp(region,'AMO');
        dd = {'170810','170811','170813','170815','170817','170819','170821'};
        Unitlist{1} = [3 4 8 16 17 19 20 21];
        Unitlist{2} = [3 5 11];
        Unitlist{3} = [4 10 11 15:17 21 26 30 31];
        Unitlist{4} = [6 9 10 12 13 15 17 18 21];
        Unitlist{5} = [19];
        Unitlist{6} = [1 3];
        Unitlist{7} = [3 4 5 9 10 12 17 18];
        
        
    end
    
elseif strcmp(subj,'Fez');
    if strcmp(region,'AMO');
        dd = {'170708','170710','170712','170714'};
        Unitlist{1} = [8];
        Unitlist{2} = [2 4 8 9 10 14];
        Unitlist{3} = [4];
        Unitlist{4} = [27 32];
    end
end





k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' subj '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
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
        [fr fr_rb ss] = PB_Civall_half_singleUnit(subj,'Test',ExpDate,unitstr,[60 220]);
        if ~isnan(fr)
            frall(:,k) = fr;
            fr_rball(:,k) = fr_rb;
            cc(k) = ss;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.fr = frall;
finalresult.fr_rb = fr_rball;
finalresult.cc = cc;

finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save(['C:\PB\RotationImages\' subj '_civall_population_' region '.mat'], 'finalresult');

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



