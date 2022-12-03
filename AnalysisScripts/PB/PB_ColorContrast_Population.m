function finalre8sult = PB_TwoImage_Population
dd = {'150821','151001','151003','151005','151007'}
Unitlist{1} = [4 5 11 13:16];
Unitlist{2}= [4 5 8 10];
Unitlist{3} = [15];
Unitlist{4} = [3 11];
Unitlist{5} = 5;
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
        fr = PB_ColorContrast_SingleUnit('Fez','test',ExpDate,unitstr)
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
save('C:\PB\ColorPatch\Fez_ALc_ColorContrast_population.mat', 'finalresult');

return;


load('C:\PB\ColorPatch\Fez_ALc_ColorContrast_population.mat');

populationresult = squeeze(finalresult.populationresult);
for i = 1:size(populationresult,2);
    tt = populationresult(:,i);
    tt = tt/mean(tt(:));
    response(:,i) = tt;
end

[coefs,scores,variances,t2] = princomp(zscore(response));

for i = 1:5
    fr = scores(:,i);
    strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\ColorContrast\ColorContrast.xml', false, false);
    for i = 1:length(strctDesign.m_astrctMedia);
        filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    end
    for i = 1:length(filename)
        nn = filename{i};
        index = find(nn=='_');
        cc(i,1) = str2num(nn(9:10));
        cc(i,2) = str2num(nn(12:13));
        
    end
    cc(cc==21) = - 99;
    dd = cc + 10;
    dd(dd>20) = dd(dd>20)-20;
    
    index = find(cc(:,1) == -99 & cc(:,2) == -99);
    rbase = (fr(index));
    for i = 1:20
        index1 = find(cc(:,1) == i & cc(:,2) == -99);
        index2 = find(cc(:,2) == i & cc(:,1) == -99);
        rw(i) =  (fr(index1) + fr(index2))/2;
    end
    rw2 = [rw(11:20) rw(1:10)];
    for i = 1:20
        for j = 1:20
            index1 = find(cc(:,1)==i & cc(:,2) == j);
            index2 = find(cc(:,1)==j & cc(:,2) == i);
            resp(i,j) =  (fr(index1) + fr(index2))/2;
            pred(i,j) = rw(i) + rw(j);
        end
    end
    
    figure
    plot(1:20,rw2,'o-','linewidth',2,'MarkerSize',5);
    for i = 1:20
        for j = 1:20
            index1 = find(dd(:,1)==i & dd(:,2) == j);
            index2 = find(dd(:,1)==j & dd(:,2) == i);
            resp2(i,j) =  (fr(index1) + fr(index2))/2;
            pred2(i,j) = rw2(i) + rw2(j);
        end
    end
    
    
    figure;
    % subplot(2,2,1);
    % imshow(imresize(resp,[200 200],'nearest'),[]);
    % colormap('default');
    % set(gca,'clim',[0 max(resp(:))]);
    %
    %
    % subplot(2,2,2);
    % imshow(imresize(pred,[200 200],'nearest'),[]);
    % colormap('default');
    % set(gca,'clim',[0 max(resp(:))]);
    
    % subplot(2,2,3);
    subplot(1,3,1);
    imshow(imresize(resp2,[200 200],'nearest'),[]);
    colormap('default');
    set(gca,'clim',[min(resp(:)) max(resp(:))]);
    subplot(1,3,2);
    plot(1:20,rw2,'o-','linewidth',2,'MarkerSize',5);
    subplot(1,3,3);
    imshow(imresize(pred2,[200 200],'nearest'),[]);
    colormap('default');
    set(gca,'clim',[min(resp(:)) max(resp(:))]);
    
    % subplot(2,2,4);
    % imshow(imresize(pred2,[200 200],'nearest'),[]);
    % colormap('default');
    % set(gca,'clim',[0 max(resp(:))]);
    % rr = corrcoef(resp(:),pred(:));
    % r = rr(1,2)
    % beta = lscov(pred(:),resp(:))
    
    figure;
    subplot(1,2,1);
    for i = 1:20
        res_square(i) = resp2(i,i);
    end
    
    plot(1:20,res_square,'b');
    hold on;
    plot(1:20,rw2*2,'r');
    subplot(1,2,2);
    plot(pred(:),resp(:),'.');
    axis equal
    axis square
    axis([min(resp(:)) max([pred(:);resp(:)]) min(resp(:)) max([pred(:);resp(:)])]);
 pause   
end





