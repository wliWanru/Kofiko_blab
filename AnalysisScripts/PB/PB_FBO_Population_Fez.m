function finalresult = PB_FBO_Population
dd = {};
dd = {'170402','170404'};
Unitlist{1} = [4 8 13 14 18 19 20 21 22 23];
%Unitlist{2} = [13 15 21 28 29 35 38 39 46:48]; for 1215
Unitlist{2} = [4 5 16 17 27 28 29 30 31 32 34 42:46];
Subject = 'Fez';
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
        output = PB_FBO_SingleUnit(Subject,'Test',ExpDate,unitstr,[60 220])
        if ~isnan(output)
            populationresult(:,:,:,:,:,k) = output;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('C:\PB\TwoImageResult\Fez_FBO_population.mat', 'finalresult');

return;
 