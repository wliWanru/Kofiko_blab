function finalresult = PB_TwoImage_Population
dd = {'150808','150810','150812','150813'};
Unitlist{1} = [5 6 8 11 12];
Unitlist{2} = [6 10 16 17];
Unitlist{3} = [2 3 8 10 13];
Unitlist{4} = [4 5 6 8 11 13];

Subject = 'Fez';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
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
        output = PB_ColorObject_SingleUnit(Subject,'Test',ExpDate,unitstr,0)
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
save('D:\PB\Colorpatch\ColorObject\Fez_ColorObject_population.mat', 'finalresult');

return;

clear all;
load('D:\PB\Colorpatch\ColorObject\Fez_ColorObject_population.mat');
fr = finalresult.populationresult;
for i = 1:size(fr,4)
    ff = fr(:,:,:,i);
    ff = ff/mean(ff(:));
    frnorm(:,:,:,i) = ff;
end

frnorm = reshape(frnorm,640,size(frnorm,4));

[coefs,scores,variances,t2] = princomp(zscore(frnorm));

for i = 1:4
    ss = scores(:,i);
    ss = reshape(ss,4,20,8);
    subplot(4,3,(i-1)*3+1);
    for j = 1:20
        kk = ss(:,j,:);
        r(j) = mean(kk(:));
    end
    plot(1:20,r)
    axis([0 20 -5 5]);
    box off;
    
    subplot(4,3,(i-1)*3+2);
    box off
    resp = squeeze(ss(3,:,:));
    resp = mean(resp,1);
    box off;
    plot(1:8,resp)
    axis([0 9 -5 5]);
    subplot(4,3,(i-1)*3+3);
    resp = reshape(ss,4,160);
    
    plot(1:4,mean(resp,2))
    box off;
    axis([0 5 -5 5]);
    
end



































figure;
for j = 1:size(fr,4);
    frsort = squeeze(fr(:,:,:,j));
    subplot(4,4,j)
    cc = {'r-','b-','g-','m-','r-','b-','g-','m-'}
    xx = frsort;
    tt = mean(xx,3);
    tt = max(tt(:));
    p = polar(linspace(0,2*pi,21),(tt+1)*ones(1,21));
    set(p,'Visible','off');
    hold on
    for i = 1:4
        xx = squeeze(frsort(i,:,:));
        xx = mean(xx,2);
        h = polar(linspace(0,2*pi,21),[xx;xx(1)]',cc{i});
        set(h,'Linewidth',2);
        linecolor(i,:) = get(h,'Color');
        hold on;
    end
end

im = zeros(160,16);
for j = 1:4
    subplot(2,2,j);
    tt = squeeze(fr(j,:,:,:));
    for i = 1:8
        im((i-1)*20+1:i*20,:) = squeeze(tt(:,i,:));
    end
    
    
    cmap = zeros(160,160);
    for i = 1:size(im,1)
        for j = 1:size(im,1);
            cc = corrcoef(im(i,:),im(j,:));
            cmap(i,j) = cc(1,2);
        end
    end
    imshow(1-cmap);
end


im = zeros(8,16);
for j = 1:4
    subplot(2,2,j);
    tt = squeeze(fr(j,:,:,:));
    for i = 1:8
        zz = squeeze(tt(:,i,:));
        im(i,:) = mean(zz,1);
    end
    
    
    cmap = zeros(8,8);
    for i = 1:size(im,1)
        for j = 1:size(im,1);
            cc = corrcoef(im(i,:),im(j,:));
            cmap(i,j) = cc(1,2);
        end
    end
    imshow(1-cmap,[]);
end
set(gca,'clim',[0.5 1])










figure;
fr = finalresult.populationresult;
for i = 1:16
    subplot(4,4,i);
    tt = squeeze(fr(3,:,:,i));
    plot(1:8,mean(tt),'ko-','linewidth',2);
    kk = mean(tt,2);
    [junk index] = max(kk);
    hold on;
    plot(1:8,tt(index,:),'ro-','linewidth',2);
end






