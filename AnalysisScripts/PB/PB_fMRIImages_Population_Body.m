function finalresult = PB_FBO_Population(Subject)

if strcmp(Subject,'Alfie');
    dd = {'160901','160902','160905','161209','161220'};
    Unitlist{1} = [1 2 19 40 42];
    Unitlist{2} = [4 5 13];
    Unitlist{3} = [14 15];
    Unitlist{4} = [7 8];
    Unitlist{5} = 19;
elseif strcmp(Subject,'Fez');
    dd = {'170409','170407','170406','170404','170326','170324','170323'}
    Unitlist{1} = [3 9];
    Unitlist{2} = [11];
    Unitlist{3} = [8];
    Unitlist{4} = [1 19 20 23];
    Unitlist{5} = [2 9 11];
    Unitlist{6} = [3 12];
    Unitlist{7} = [6 8 9];
end


k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['C:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
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
        [fr frmb] = PB_fMRI72Image_Object_SingleUnit(Subject,'Test',ExpDate,unitstr)
        if ~isnan(fr)
            populationresult(:,k) = frmb;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save(['C:\PB\TwoImageResult\' Subject '_fMRI72Image_MLB.mat'], 'finalresult');

return;
clear all;
close all;
figure;

load('C:\PB\TwoImageResult\Fez_fMRI72Image_MLB.mat');
fr1 = finalresult.populationresult;
load('C:\PB\TwoImageResult\Alfie_fMRI72Image_MLB.mat');
fr2 = finalresult.populationresult;

fr = cat(2,fr1,fr2);
fr = fr(:,1:24);


size(fr,2)
for i = 1:size(fr,2);
    tt = fr(:,i);
    tt = tt/max(tt);
    fr_n(:,i) = tt;
end

[coefs,scores,variances,t2] = princomp(zscore(fr_n));
[junk index] = sort(coefs(:,1));

kk = [1:11 24:37 38:42 50:68 43:49 69:72 73:82];
fr_n = fr_n(kk,index)';
imshow(imresize(fr_n,10,'nearest'),[]);
set(gca,'Clim',[-1 1]);
it  = wd_compit4_1;
colormap(it);