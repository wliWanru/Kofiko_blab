function finalresult = PB_TwoImage_Population
% dd = {'150214','150216'};
% Unitlist{1} = [1 2 3 4 5 8 12 14 15];
% Unitlist{2}= [3:26 28:30];

dd = {'140710','140726','140809','140814','140827','140904','140909','140911','140914','140915','140929','141012','141017','141019','141022','140729'};
Unitlist{1} = [2 5 4 8];
Unitlist{2} = [1 3 10];
Unitlist{3} = [1 2 4 7 8 10 15 16];
Unitlist{4} = [6 7 8 9 11 12];
Unitlist{5} = [1 6 8 10 12 13 17 18 19];
Unitlist{6} = [ 2 8 15 17 19 20 33 34 35];
Unitlist{7} = [7 9 10 11 13 15 16 21 22];
Unitlist{8} = [4 7 23 27 28 41];
Unitlist{9} = [2 7 11 12 26 28 33 34];
Unitlist{10} = [2 10 17 19 21 26 28 29];
Unitlist{11} = [4 5 9];
Unitlist{12} = [3 4];
Unitlist{13} = [3 4 7 8];
Unitlist{14} =  [2 3 4 6 7];
Unitlist{15} = [7];
Unitlist{16} = [5 7 8 9 10];



Subject = 'Rocco';
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
        [fr frmb ff tcc] = PB_FOB_object_SingleUnit(Subject,'Test',ExpDate,unitstr,0);
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
save('C:\PB\TwoImageResult\Rocco_ML_population.mat', 'finalresult');

return;
figure;
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

load(['C:\PB\RotationImages\Alfie_ML_population.mat'])

fr = finalresult.populationresult;
fr(isnan(fr)) = 0;
for i = 1:size(fr,2);
    tt = fr(:,i);
    tt = tt/max(tt);
    fr_n3(:,i) = tt;
end

fr_n = [fr_n1 fr_n2 fr_n3];


[coefs,scores,variances,t2] = princomp(zscore(fr_n));
    [junk index] = sort(coefs(:,1));
        imshow(fr_n(:,index)');
        it  = wd_compit4_1;
    colormap(it);
    
    
figure;
fsiall = [];
load(['C:\PB\TwoImageResult\Rocco_ML_population.mat'])
fsiall = [fsiall  finalresult.fob];
load(['C:\PB\TwoImageResult\Ozomatli_ML_population.mat'])
fsiall = [fsiall  finalresult.fob];
load(['C:\PB\RotationImages\Alfie_ML_population.mat'])
fsiall = [fsiall  finalresult.fob];



