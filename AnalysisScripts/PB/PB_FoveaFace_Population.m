function finalresult = PB_TwoImage_Population
dd = {'161005'};
Unitlist{1} = [01 03 04 07 09 19 20];

Subject = 'Alfie';
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
        [resp]= PB_FaceFovea_SingleUnit(Subject,'test',ExpDate,unitstr,0)
        if ~isnan(resp)
            fr(:,k) = resp;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.fr = fr;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('C:\PB\TwoImageResult\Alfie_FoveaFace_Population.mat', 'finalresult');

return;

load('C:\PB\TwoImageResult\Alfie_FoveaFace_Population.mat');

fr = finalresult.fr;

for i = 1:size(fr,2);
    ff = fr(:,i);
    ff = ff/mean(ff);
    fr(:,i) = ff;
end

fr = mean(fr,2);
figure;
for i = 1:4
    subplot(2,2,i);
    hold on;
    plot(10:20:90,fr(1:5),'ro-','linewidth',1.5);
    plot(10:20:90,fr(i*5+1:i*5+5),'bo-','linewidth',1.5);
    plot(10:20:90,fr(i*5+21:i*5+25),'ko-','linewidth',1.5);
    set(gca,'XTick',10:20:90);
    box off;
    set(gca,'FontSize',10);
    axis([0 100 0 1.55]);
end




% im1 = zeros(5,5);
% fr = mean(response,3);
% for i = 1:3:63
%     [m n] = find(sc == (i+2)/3);
%     xx = fr(i:i+2,251:350);
%     xx = mean(xx,2);
%     for j = 1:3
%         im(m,n,j) = xx(j);
%     end
% end
%
% for i = 1:3
%     subplot(1,3,i);
%     imn = im(:,:,i)*1000;
%     imn = imresize(imn,[200 200],'nearest');
%     imshow(imn);
%     set(gca,'clim',[min(im(~(im==0)))-0.001 max(im(:))]*1000)
% end
% colormap(mm);


fr = mean(response,3);
figure;
for i = 1:3:63
    [m n] = find(sc == (i+2)/3);
    pn = (m-1) * 5 + n;
    subplot(5,5,pn);
    plot(-200:900,fr(i,:),'b-','linewidth',1);
    hold on;
    plot(-200:900,fr(i+1,:),'r-','linewidth',1);
    plot(-200:900,fr(i+2,:),'k-','linewidth',1);
    axis([-200 500 0 max(fr(:))]);
    box off;
    %setgca;
end

subplot(5,5,25);
plot(-200:900,fr(64,:),'k-','linewidth',2);
hold on;
plot(-200:900,fr(65,:),'r-','linewidth',2);
axis([-200 500 0 max(fr(:))]);
