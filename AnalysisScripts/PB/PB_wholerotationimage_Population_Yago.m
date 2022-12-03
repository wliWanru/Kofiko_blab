function finalresult = PB_TwoImage_Population(region);


[dd Unitlist] = ppdata('Yago',region);

% switch region
%     case 'ALThreed'
%         dd = {'160710','160713','160714','160715'};
%         Unitlist{1} = [1:4 10 11 13 15 16 18];
%         Unitlist{2} = [1 6 7 8 15 16 18 20];
%         Unitlist{3} = [1 2 7 14 16 18 19 20 21];
%         Unitlist{4} = [7 8 9 11 22 23];
%     case 'ABody';
%         dd = {'160730','160805','160807','160809','160811','160819','160820'};
%         Unitlist{1}  = [1:3 11];
%         Unitlist{2} = [6 7 8 12 13 14 16 ];
%         Unitlist{3} = [ 7 8 11 19 21 22]
%         Unitlist{4} = [2 3  6 8 9 10 14 16 19 21];
%         Unitlist{5} = [8 9 10 11 16 18 19];
%         Unitlist{6} = [21 37 40 41 42 43 44];
%         Unitlist{7} = [2:7 11 14 17 20 21 25];
%     case 'MBody';
%         dd = {'160823','160901','160902','160905','160830'};
%         Unitlist{1} = [6 9 11 18 19 20 22 26 31 33 35 36];
%         Unitlist{2} = [15 19 21 27 34 40:42 44 45 46];
%         Unitlist{3} = [2 4 5 12 13 16:18];
%         Unitlist{4} = [4 6 7 9 11 14 16 17 18 20 21 22 23 24 28 31 32 33];
%         Unitlist{5} = [16 17];
%     case 'AMB';
%         dd = {'160907','160908','160909','160912','160914'};
%         Unitlist{1} = [6 12];
%         Unitlist{2} = [3 6 7 9 14 18];
%         Unitlist{3} = [2 4 5 14 16 18 19];
%         Unitlist{4} = [5 9 12 16 21];
%         Unitlist{5} = [4 5 9 16 22];
%     case 'ML'
%         dd = {'160830'}
%         Unitlist{1} = [1 4 5 9 10 12 13 15 19 21];
%     case 'AMO'
%         dd = {'170105','170106','170109','170112','170113','170202','170203','170205'};
%         Unitlist{1} = [3 9 10 25];
%         Unitlist{2} = [2 13 17 18 19 20];
%         Unitlist{3} = [4 7 12 13];
%         Unitlist{4} = [1:4 13 18 19 20 26];
%         Unitlist{5} = [6 11];
%         Unitlist{6} = [20 21];
%         Unitlist{7} = [12];
%         Unitlist{8} = [4 6 7 8 17:20];
%
%         %     case 'ALO'
%         %         dd = {'170212','170213'};
%         %         Unitlist{1} = [7 8 11 14 16 18 20 21];
%         %         Unitlist{2} = [6 8 10 12];
%         %     case 'ALLO';
%         %         dd = {'170209'};
%         %         Unitlist{1} = [3 4 5 7 9 11 15 17 19 20 21];
%     case 'ALO';
%         %         dd = {'170223','170225'};
%         %         Unitlist{1} = [19 8 22 9 23 16];
%         %         Unitlist{2} = [10 16 18 19 22 25 26];
%         dd = {'170225','170305','170318','170319','170312','170318','170317','170227'};
%         Unitlist{1} = [10 16 18 19 22 25 26];
%         Unitlist{2} = [4:8 11:13 16 17 19:21];
%         Unitlist{3} = [3:7 12 17:20];
%         Unitlist{4} = [1 3:6 7 9 10 12 15 17 18];
%         Unitlist{5} = [9 11];
%         Unitlist{6} = [5 6 7 8 9 19 21];
%         Unitlist{7} = [12 17];
%         Unitlist{8} = [3 10];
%     case 'MLO'
%         dd = {'170321','170322'};
%         Unitlist{1} = [1 2 4 12 13];
%         Unitlist{2} = [1 3 5:8 10 12 13 14 18 19 20 23];
% end

Unitlist
Subject = 'Yago';
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
        frall(:,k) = fr;
        fr_rball(:,k) = fr_rb;
        tcall(:,:,k) = tc;
        dataentry_date{k} = dd{i};
        dataentry_unitnumber{k} = unitstr;
        k = k + 1;
    end
end

finalresult.fr = frall;
finalresult.fr_rb = fr_rball;
finalresult.tcall = tcall;

finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save(['C:\PB\RotationImages\Yago_RotationImage_population_' region '.mat'], 'finalresult');

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



