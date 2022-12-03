function finalresult = PB_TwoImage_Population
% dd = {'150214','150216'};
% Unitlist{1} = [1 2 3 4 5 8 12 14 15];
% Unitlist{2}= [3:26 28:30];
 
dd = {'150306','150310','150312'};
Unitlist{1} = [1 2 4 5 6 7 8 10 11:15 19:25 39 40];
Unitlist{2} = [10 11 12 13 14 16 17 18 19 20 21];
Unitlist{3} = [1 2 6 10 12:17 24 25];



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
        
        [ExpDate unitstr]
        fr = PB_Occlusion_SingleUnit(Subject,'test',ExpDate,unitstr,0)
        if ~isnan(fr)
            populationresult(:,:,k) = fr;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\OcclusionResult\Rocco_population.mat', 'finalresult');

return;

load('D:\PB\OcclusionResult\Rocco_population.mat');
populationresult = finalresult.populationresult;


for i = 1:size(populationresult,3);
    tt = populationresult(:,:,i);
    tt = tt/max(tt(:));
    response(:,:,i) = tt;
end

fr = mean(response,3);
figure;
subplot(2,4,1);
hold on;
title('1face-0face-RH');
plot(-200:900,fr(13,:),'k-','linewidth',2.5);
plot(-200:900,fr(1,:),'b-','linewidth',2.5);
plot(-200:900,fr(5,:),'r-','linewidth',2.5);
setgca;
subplot(2,4,2);
hold on;

title('1face-0face-LH');
plot(-200:900,fr(15,:),'k-','linewidth',2.5);
plot(-200:900,fr(1,:),'b-','linewidth',2.5);
plot(-200:900,fr(7,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,5);
hold on;

title('0face-1face-RH');
plot(-200:900,fr(17,:),'k-','linewidth',2.5);
plot(-200:900,fr(2,:),'b-','linewidth',2.5);
plot(-200:900,fr(4,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,6);
hold on;

title('0face-1face-LH');
plot(-200:900,fr(19,:),'k-','linewidth',2.5);
plot(-200:900,fr(3,:),'b-','linewidth',2.5);
plot(-200:900,fr(8,:),'r-','linewidth',2.5);
setgca;


subplot(2,4,3);
hold on;

title('1face-0obj-RH');
plot(-200:900,fr(14,:),'k-','linewidth',2.5);
plot(-200:900,fr(1,:),'b-','linewidth',2.5);
plot(-200:900,fr(10,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,4);
hold on;

title('1face-0obj-LH');
plot(-200:900,fr(16,:),'k-','linewidth',2.5);
plot(-200:900,fr(1,:),'b-','linewidth',2.5);
plot(-200:900,fr(12,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,7);
hold on;

title('0face-1obj-RH');
plot(-200:900,fr(18,:),'k-','linewidth',2.5);
plot(-200:900,fr(2,:),'b-','linewidth',2.5);
plot(-200:900,fr(9,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,8);
hold on;

title('0face-1obj-LH');
plot(-200:900,fr(20,:),'k-','linewidth',2.5);
plot(-200:900,fr(3,:),'b-','linewidth',2.5);
plot(-200:900,fr(11,:),'r-','linewidth',2.5);
setgca;


