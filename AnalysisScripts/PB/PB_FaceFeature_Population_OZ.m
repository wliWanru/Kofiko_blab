function finalresult = PB_TwoImage_Population
dd = {'150216'};
Unitlist{1} = [4:8 12 13 14 15 16 17 19 20 21 22 29];

Subject = 'Ozomatli';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' Subject '\' ExpDate '\Processed\SingleUnitDataEntries\'];
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
        [xx fr] = PB_FaceFeature)_SingleUnit(Subject,[],ExpDate,unitstr)
        if ~isnan(fr)
            populationresult(:,:,k) = fr;
            pop_response(:,:,:,k) = xx;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.pop_response = pop_response;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\FaceFeatureResult\Ozomatli_population.mat', 'finalresult');

return;

load('D:\PB\FaceFeatureResult\Ozomatli_population.mat');
tt = finalresult.pop_response;

for i = 1:size(tt,4)
xx = tt(:,:,:,i);
tt(:,:,:,i) = tt(:,:,:,i)/max((xx(:)));
end








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
%title('1face-0face-RH');
plot(-200:900,fr(13,:),'k-','linewidth',2.5);
plot(-200:900,fr(1,:),'b-','linewidth',2.5);
plot(-200:900,fr(5,:),'r-','linewidth',2.5);
setgca;
subplot(2,4,2);
hold on;

%title('1face-0face-LH');
plot(-200:900,fr(15,:),'k-','linewidth',2.5);
plot(-200:900,fr(1,:),'b-','linewidth',2.5);
plot(-200:900,fr(7,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,5);
hold on;

%title('0face-1face-RH');
plot(-200:900,fr(17,:),'k-','linewidth',2.5);
plot(-200:900,fr(2,:),'b-','linewidth',2.5);
plot(-200:900,fr(4,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,6);
hold on;

%title('0face-1face-LH');
plot(-200:900,fr(19,:),'k-','linewidth',2.5);
plot(-200:900,fr(3,:),'b-','linewidth',2.5);
plot(-200:900,fr(8,:),'r-','linewidth',2.5);
setgca;


subplot(2,4,3);
hold on;

%title('1face-0obj-RH');
plot(-200:900,fr(14,:),'k-','linewidth',2.5);
plot(-200:900,fr(1,:),'b-','linewidth',2.5);
plot(-200:900,fr(10,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,4);
hold on;

%title('1face-0obj-LH');
plot(-200:900,fr(16,:),'k-','linewidth',2.5);
plot(-200:900,fr(1,:),'b-','linewidth',2.5);
plot(-200:900,fr(12,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,7);
hold on;

%title('0face-1obj-RH');
plot(-200:900,fr(18,:),'k-','linewidth',2.5);
plot(-200:900,fr(2,:),'b-','linewidth',2.5);
plot(-200:900,fr(9,:),'r-','linewidth',2.5);
setgca;

subplot(2,4,8);
hold on;

%title('0face-1obj-LH');
plot(-200:900,fr(20,:),'k-','linewidth',2.5);
plot(-200:900,fr(3,:),'b-','linewidth',2.5);
plot(-200:900,fr(11,:),'r-','linewidth',2.5);
setgca;


