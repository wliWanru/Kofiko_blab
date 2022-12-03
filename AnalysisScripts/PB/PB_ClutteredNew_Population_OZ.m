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
        [tc resp]= PB_ClutterNew_SingleUnit(Subject,[],ExpDate,unitstr,0)
        if ~isnan(resp)
            populationresult(:,:,k) = tc;
            fr(:,k) = resp;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.fr = fr;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('C:\PB\ClutterNewResult\Ozomatli_population.mat', 'finalresult');

return;

load('D:\PB2\ClutterNewResult\Ozomatli_population.mat');
populationresult = finalresult.populationresult;

for i = 1:size(populationresult,3);
    tt = populationresult(:,:,i);
    tt = tt/mean(tt(:));
    response1(:,:,i) = tt;
end
load('D:\PB2\ClutterNewResult\Rocco_population.mat');
populationresult = finalresult.populationresult;

for i = 1:size(populationresult,3);
    tt = populationresult(:,:,i);
    tt = tt/mean(tt(:));
    response2(:,:,i) = tt;
end

response = cat(3,response1,response2);



k = 1;
for i = 1:5
    for j = 1:5
        if ((i==1) && (j==1)) || ((i==5) && (j==5))|| ((i==1) && (j==5))|| ((i==5) && (j==1))
            sc(i,j) = 0;
        else
            sc(i,j) = k;
            k = k + 1;
            
        end
    end
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
