function finalresult = PB_OnlineImage_Population(subj,region);


[dd Unitlist session] = OnlineData(subj,region);


Unitlist
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    serialno = session{i};
    
    for j = 1:length(unitnumber)
        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]
        [fr fr_rb] = PB_onlineImage_SingleUnit(subj,'Test',ExpDate,unitstr,serialno(j));
        if ~isnan(fr)
            frall(:,k) = fr;
            fr_rball(:,k) = fr_rb;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.fr = frall;
finalresult.fr_rb = fr_rball;

finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save(['C:\PB\RotationImages\' subj '_RotationImage_population_' region '.mat'], 'finalresult');


return;

clear all;
subj = 'Alfie';
region = 'AMO';
load(['C:\PB\RotationImages\' subj '_RotationImage_population_' region '.mat']);
fr = finalresult.fr_rb;
for i = 1:size(fr,2);
    ff = zscore(fr(:,i));
    fr_n(:,i) = ff;
end

figure;
hold on;

for i = 1:size(fr_n,2);
    subplot(3,4,i)
    ff = reshape(fr_n(:,i),12,12);
    tc1(:,i) = mean(ff,1);
    tc2(:,i) = mean(ff,2);
    plot(mean(ff,1),'Color',[0 0 0]);
    plot(mean(ff,2),'Color',[1 0 0]);
    
end


figure;
fr = finalresult.fr;
fz = fr;
for i = 1:11;
    subplot(3,4,i)
    hold on;
    fr = fz(:,i);
    fr = reshape(fr,12,12);
    f1 = mean(fr(:))-3*std(fr(:));
    f2 = mean(fr(:))+3*std(fr(:));
    
    f1 = min(fr(:));
    f2 = max(fr(:));
    
    ff = (fr-f1)/(f2-f1);
    ff(ff<0) = 0;
    ff(ff>1) = 1;
    
    
    for i=1:12
        for j = 1:12
            scatter(i,13- j,100,[ff(i,j) 0 1-ff(i,j)],'filled');
        end
    end
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
