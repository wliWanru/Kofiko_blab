function finalresult = PB_FBO_Population
dd = {'161208','161215','161213'};
Unitlist{1} = [8 9 11 16 23 24 25];
Unitlist{2} = [13 15 21 28 29 35 38 39 46:48]; 
Unitlist{3} = [1 2 3 10 11 14 17 18];

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
        output = PB_FBO_SingleUnit(Subject,'Test',ExpDate,unitstr)
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
save('C:\PB\TwoImageResult\Alfie_FBO_Face_population.mat', 'finalresult');

return;
clear all;
close all;
load('C:\PB\TwoImageResult\Alfie_FBO_Face_population.mat');
populationresult = finalresult.populationresult;

tt = randperm(26);

load kk
for i = kk %size(populationresult,6)
    tt = populationresult(:,:,:,:,:,i);
    tt = tt/mean(tt(:));
    response(:,:,:,:,:,i) = tt;
end


rr = mean(response,6);
se = std(response,0,6);
    

figure;
for bc = 1:2
    for i = 1:3
        switch i
            case 1
                ss = {'Face','Object'}; cc = {'ro-','bo-'};
            case 2
                ss = {'Face','Body'};  cc = {'ro-','mo-'};
            case 3
                ss = {'Body','Object'}; cc = {'mo-','bo-'};
        end
        for j = 1:2
            resp = squeeze(rr(bc,i,j,:,:));
            subplot(3,4,(i-1)*4 + j + (bc-1)*2)
            hold on;
            if bc == 1;
                title(['Ipsi:' ss{j} ' Contra:' ss{3-j}]);
            else
                title(['Top: ' ss{j} ' Bottom:' ss{3-j}]);
            end
            plot(10:20:90,resp(:,1),cc{j},'linewidth',2);
            plot(10:20:90,resp(:,2),cc{3-j},'linewidth',2);
            plot(10:20:90,resp(:,3),'ko-','linewidth',2);
            set(gca,'FontSize',12);
        end
    end
end

set(gcf,'Position',[669         135        1055         843]);
