function finalresult = PB_TwoImage_Population
% dd = {'150214','150216'};
% Unitlist{1} = [1 2 3 4 5 8 12 14 15];
% Unitlist{2}= [3:26 28:30];

dd = {'150413'};
Unitlist{1} = [1:6 9 10 14 16 17:20 22 23];
Unitlist{3} = [6 7 8 10 11 12 13 14 24 25];



Subject = 'Rocco';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
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
        close all;
        
        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]
        output = PB_StevenUpDown_SingleUnit(Subject,'Test',ExpDate,unitstr)
        populationresult{k} = output;
        dataentry_date{k} = dd{i};
        dataentry_unitnumber{k} = unitstr;
        k = k + 1;
        pause;
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\StevenUpDown\Rocco_population.mat', 'finalresult');

return;

load('D:\PB\StevenUpDown\Rocco_population.mat');
populationresult = finalresult.populationresult;


for i = 1:size(populationresult,3);
    tt = populationresult(:,:,i);
    tt = tt/max(tt(:));
    response(:,:,i) = tt;
end

fr = mean(response,3);
figure;
for i = 1:4
    subplot(4,2,(i-1)*2+1);
    hold on;
    plot(-200:900,fr((i-1)*4+1,:),'linewidth',2);
    plot(-200:900,fr((i-1)*4+2,:),'r','linewidth',2);
    axis([-200 900 0 0.7]);
    
    subplot(4,2,(i-1)*2+2);
    
    hold on;
    plot(-200:900,fr((i-1)*4+3,:),'linewidth',2);
    plot(-200:900,fr((i-1)*4+4,:),'r','linewidth',2);
    axis([-200 900 0 0.7]);
    
end