function finalresult = PB_TwoImage_Population_TimeCourse;
dd = {'141220','141222','150125'}; 
Unitlist{1} = [2 10 11 13 14 15 16 18];
Unitlist{2}= [2 4 5 7 8 9 10 11 14 17 18 19 20 21];
Unitlist{3} = [12 13 15 16 17 18 19 24];
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
        output = PB_TwoImage_SingleUnit_TimeCourse('Ozomatli',[],ExpDate,unitstr,24)
        if ~isnan(output)
            populationresult(:,:,:,:,k) = output;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;

save('D:\PB\TwoImageResult\OZ_population_timecourse.mat', 'finalresult');


return;
figure;
load('D:\PB\TwoImageResult\Rocco_population_timecourse.mat');
populationresult = finalresult.populationresult;

pr = populationresult;
normpr = pr;
for i = 1:size(pr,5);
    tt = pr(:,:,:,:,i);
    normpr(:,:,:,:,i) = tt/(max(tt(:)));
end

for i = 1:3
    for j = 1:5
        subplot(5,3,(j-1)*3 + i);
        cr = normpr(i,1,j,:,:); cr = squeeze(cr); cr = mean(cr,2);
        fr = normpr(i,2,j,:,:); fr = squeeze(fr); fr = mean(fr,2);
        or = normpr(i,3,j,:,:); or = squeeze(or); or = mean(or,2);
        plot(fr,'r-','linewidth',2);
        hold on;
        plot(or,'b-','linewidth',2);
        hold on;
        plot(cr,'k-','linewidth',2);
        box off;
        set(gca,'linewidth',2);
        axis([0 250 0 0.6]);
    end
end

figure;
frc = normpr(1,2,:,:,:); frc = squeeze(frc); frc = mean(frc,3); frc = mean(frc,1); frc = squeeze(frc);
frl = normpr(2,2,:,:,:); frl = squeeze(frl); frl = mean(frl,3); frl = mean(frl,1); frl = squeeze(frl);
frr = normpr(3,2,:,:,:); frr = squeeze(frr); frr = mean(frr,3); frr = mean(frr,1); frr = squeeze(frr);
subplot(1,2,1);
plot(frc,'b-','linewidth',2); hold on; plot(frl,'r-','linewidth',2); plot(frr,'k-','linewidth',2);
box off;
setgca;
subplot(1,2,2);
orc = normpr(1,3,:,:,:); orc = squeeze(orc); orc = mean(orc,3); orc = mean(orc,1); orc = squeeze(orc);
orl = normpr(3,3,:,:,:); orl = squeeze(orl); orl = mean(orl,3); orl = mean(orl,1); orl = squeeze(orl);
orr = normpr(2,3,:,:,:); orr = squeeze(orr); orr = mean(orr,3); orr = mean(orr,1); orr = squeeze(orr);
plot(orc,'b-','linewidth',2); hold on; plot(orl,'r-','linewidth',2); plot(orr,'k-','linewidth',2);
box off;
setgca;







%
% for i = 1:size(populationresult,4);
%     tt = populationresult(:,:,:,i);
%     tt = tt/max(tt(:));
%     response(:,:,:,i) = tt;
% end
%
% response = mean(response,4);
% cc = {'ko--','ro-','bo-'};
%
% for i = 1:3
%     subplot(1,3,i);
%     for j = 1:3;
%         plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
%         hold on;
%     end
%     box off
% end
%
%
