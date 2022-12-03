function finalresult = PB_TwoImage_Population
dd = {'161003','160930','160929'}
Unitlist{1} = [1 2 3 4 7 11 14 15];
Unitlist{2} = [2 3 6 7];
Unitlist{3} = [2 3 5 9 13 14];
Subject = 'Alfie';
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
    output = PB_TwoImage_SingleUnit(Subject,'test',ExpDate,unitstr)
    if ~isnan(output)
        populationresult(:,:,:,k) = output;
        dataentry_date{k} = dd{i};
        dataentry_unitnumber{k} = unitstr;
        k = k + 1;
    end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('C:\PB\TwoImageResult\Alfie_population.mat', 'finalresult');

return;
cc = {'ko--','ro-','bo-'};

load('C:\PB\TwoImageResult\Alfie_population.mat');
tt = finalresult.populationresult;
for cn = 1:size(tt,4);
    figure;

    response = tt(:,:,:,cn);
    for i = 2:3
    subplot(1,2,i-1);
    for j = 1:3;
        plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
        hold on;
    end
    box off
    set(gca,'Linewidth',1);
    set(gca,'FontSize',14);
    end
    cn
pause;

set(gcf,'Position', [625   550   671   388]);
close all;

end



figure;

ss = {'OZ','Rocco','Alfie'};
cc = {'ko-','ro-','bo-'};
for sl = 1:length(ss)
    subj = ss{sl};
    
    
    
    load(['C:\PB\TwoImageResult\' subj  '_population.mat']);
    populationresult = finalresult.populationresult;
    for i = 1:size(populationresult,4);
        tt = populationresult(:,:,:,i);
        tt = tt/mean(tt(:));
        response(:,:,:,i) = tt;
    end
    
    response = mean(response,4);
    
    for i = 2:3
        if sl == 3;
            k = 4 - i;
        else
            k = i -1;
        end
        (sl-1)*2 + k
        subplot(3,2,(sl-1)*2 + k);
        for j = 1:3;
            plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
            hold on;
        end
        box off
        set(gca,'Linewidth',1);
        set(gca,'FontSize',10);
    end
end
%set(gcf,'Position',[457         645        1109         330]);



        
