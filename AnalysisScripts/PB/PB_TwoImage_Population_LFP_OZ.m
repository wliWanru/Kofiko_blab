function finalresult = PB_TwoImage_Population
dd = {'141220','141222','150125','150127','150128','150130','150201'}; 
Unitlist{1} = [2 10 11 13 14 15 16 18];
Unitlist{2}= [2 4 5 7 8 9 10 11 14 17 18 19 20 21];
Unitlist{3} = [12 13 15 16 17 18 19 24];
Unitlist{4} = [3 10 15 16 20 21 26];
Unitlist{5} = [1 3 4 5 10 11];
Unitlist{6} = [1 3 10 11];
Unitlist{7} = [1 2 4 5 8 11 13 14 15 17];
Subject = 'OZomatli';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['C:\PB\EphysData\' Subject '\' ExpDate '\Processed\SingleUnitDataEntries\'];
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
    [junk LFP] = PB_TwoImage_LFP(Subject,[],ExpDate,unitstr)
    if ~isnan(LFP)
        rr(:,:,k) = LFP;
        dataentry_date{k} = dd{i};
        dataentry_unitnumber{k} = unitstr;
        k = k + 1;
    end
    end
end

finalresult.data = rr;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;

save('C:\PB\TwoImageResult\OZ_population_LFP.mat', 'finalresult');

return;

figure;
load('C:\PB\TwoImageResult\OZ_population_LFP.mat');
pr = finalresult.data;
for i = 1:3
    for j = 1:5
        subplot(5,3,(j-1)*3 + i);
        cr = pr((i-1)*15+10+j,:,:); cr = squeeze(cr); cr = mean(cr,2);
        fr = pr((i-1)*15+0+j,:,:); fr = squeeze(fr); fr = mean(fr,2);
        or = pr((i-1)*15+5+j,:,:); or = squeeze(or); or = mean(or,2);
        plot(-100:1000,fr,'r-','linewidth',2);
        hold on;
        plot(-100:1000,or,'b-','linewidth',2);
        hold on;
        plot(-100:1000,cr,'k-','linewidth',2);
        box off;
        set(gca,'linewidth',2);
        axis([0 500 -600 500]);
    end
end

figure;
cc = {'r','g','b','c','k'}
for i = 1:3
    for j = 1:5
        subplot(2,3,i)
        fr = pr((i-1)*15+0+j,:,:); fr = squeeze(fr); fr = mean(fr,2);
        plot(-100:1000,fr,'Color',cc{j},'linewidth',2);
        hold on;
        subplot(2,3,i+3);
        or = pr((i-1)*15+5+j,:,:); or = squeeze(or); or = mean(or,2);
        plot(-100:1000,or,'Color',cc{j},'linewidth',2);
        hold on;
    end
end

figure;
cc = {'r','b','k','c','k'}
for i = 1:3
    
    subplot(1,2,1)
    fr = pr((i-1)*15+0+(1:5),:,:); fr = squeeze(fr); fr = mean(fr,3);fr = mean(fr,1); fr = squeeze(fr);
    plot(-100:1000,fr,'Color',cc{i},'linewidth',2);
    hold on;
        axis([0 500 -600 1000]);
    
    subplot(1,2,2);
    or = pr((i-1)*15+5+(1:5),:,:); or = squeeze(or); or = mean(or,3);or = mean(or,1); or = squeeze(or);
    if i > 1
        j = 5 - i;
    else
        j = i;
    end
    plot(-100:1000,or,'Color',cc{j},'linewidth',2);
    hold on;
    axis([0 500 -600 1000]);

end


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

        
