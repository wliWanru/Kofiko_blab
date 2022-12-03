function finalresult = PB_TwoImage_Population
% dd = {'150214','150216'};
% Unitlist{1} = [1 2 3 4 5 8 12 14 15];
% Unitlist{2}= [3:26 28:30];

dd = {'141220','141222','150107','150122','150125'} %'140809','140814','140827','140904','140909','140911','140914','140915','140929','141012','141017','141019','141022'};
Unitlist{1} = [1 10 11 13 14 15 16 18:20];
Unitlist{2} = [2 4 7 8 9 10 11 13 17 20 21];
Unitlist{3} = [1 3 4 5 7 8];
Unitlist{4} = [1 2 5 8 11];
Unitlist{5} = 7:10;
Unitlist{6} = [3 5:10];


Subject = 'Ozomatli';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['C:\PB\EphysData\' Subject  ExpDate '\Processed\SingleUnitDataEntries\'];
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
        [fr frmb ff tcc] = PB_FOB_object_SingleUnit(Subject,'',ExpDate,unitstr,0);
        if ~isnan(fr)
            populationresult(:,k) = frmb;
            fob(:,k) = ff;
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
save('C:\PB\TwoImageResult\Ozomatli_ML_population.mat', 'finalresult');

return;

load(['C:\PB\TwoImageResult\Rocco_ML_population.mat'])

fr = finalresult.populationresult;
fr(isnan(fr)) = 0;
for i = 1:size(fr,2);
    tt = fr(:,i);
    tt = tt/max(tt);
    fr_n1(:,i) = tt;
end


load(['C:\PB\TwoImageResult\Ozomatli_ML_population.mat'])

fr = finalresult.populationresult;
fr(isnan(fr)) = 0;
for i = 1:size(fr,2);
    tt = fr(:,i);
    tt = tt/max(tt);
    fr_n2(:,i) = tt;
end

fr_n = [fr_n1 fr_n2];


figure;
[coefs,scores,variances,t2] = princomp(zscore(fr_n));
[junk index] = sort(coefs(:,1));
imshow(fr_n(:,index(end:-1:1))');
it  = wd_compit4_1;
colormap(it);
