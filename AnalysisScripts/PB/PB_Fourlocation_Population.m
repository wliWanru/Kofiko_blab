function finalresult = PB_TwoImage_Population
dd = {'141012'};
% Unitlist{1} = [1 2 3 4 8];
Unitlist{1} = [0];
% Unitlist{2}= [6 8 10];
% Unitlist{3} = [6 9];
% Unitlist{4} = [7 10];
% Unitlist{5} = 0;
% Unitlist{6} = 0; % 63 neurons
% Unitlist{7} = [16 18 33 34 35];
% Unitlist{8} = [8 10 17 28 26 27 28 29];
Subject = 'Rocco';
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
        rr = PB_Fourlocation_SingleUnit('Rocco','test',ExpDate,unitstr,0)
        if ~isnan(rr)
            populationresult(:,:,:,:,k) = rr;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;




for i = 1:size(populationresult,5);
    tt = populationresult(:,:,:,:,i);
    tt = tt/max(tt(:));
    response(:,:,:,:,i) = tt;
end
figure;
response = mean(response,5);
cc = {'ro-','bo-','ko-'};

for i = 1:4
    for j = 1:4
        
        subplot(4,4,(i-1)*4+j);
        for k = 1:3;
            plot(10:20:90,squeeze(response(k,:,i,j)),cc{k},'linewidth',2);
            hold on;
        end
        box off
    end
end

    
