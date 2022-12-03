dd = {'141022','141023','141024','141026'}
Unitlist{1} = [11];
Unitlist{2}= [6 7 8];
Unitlist{3} = [1 3 6 7 17];
Unitlist{4} = [1 2 3 4];
k = 1;
Subject = 'Rocco';
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
        [rf ro] = PB_RandomOnelocation_SingleUnit('Rocco','test',ExpDate,unitstr)
        rfall{k} = rf;
        roall{k} = ro;
        k = k + 1;
    end
end
clear xx yy
figure;
for i = 1:length(rfall);
    rr = rfall{i};
    xx(:,:,i) = rr/max(rr(:));
    yy(:,i) = roall{i}/max(rr(:));
end
xx(isnan(xx)) = 0;

rf = mean(xx,3);
ro = mean(yy,2);

objposition = [ 376.0000  266.5000
    376.0000  485.5000]/2;
pathname = '\\192.168.50.15\StimulusSet\OneImagesOneNoiseRandomLocation';
position = load([pathname '\position.mat']);
position = position.position;
position = position/2;
figure;
xf = position(1:500,1);
yf = position(1:500,2);
figure;
for j = 1:3
        %rf = rfall{unitnumber};
        %rf = rf/max(rf(:));
        [xx yy] = meshgrid(1:375,1:375);
        H = fspecial('Gaussian',[20 20],4);
        subplot(2,3,j);
        fmap = griddata(xf,yf,rf(j,:),xx,yy,'linear');
        %subplot(3,4,unitnumber-1);
        imshow(imfilter(fmap,H,'replicate')',[]);
        colormap('default');
        set(gca,'clim',[0.05 0.65]);
        colorbar;
        
        
            for j = 2:3
                fmap = griddata(xf,yf,rf(j,:)-rf(1,:),xx,yy,'linear');
                subplot(2,3,j+3);
                imshow(fmap',[])
               % imshow(imfilter(fmap,H,'replicate')',[]);
                colormap('default');
                colorbar;
            end
            
              for j = 2:3
                fmap = griddata(xf,yf,rf(j,:)-rf(1,:),xx,yy,'linear');
                subplot(2,3,j+3);
                imshow(fmap',[])
               % imshow(imfilter(fmap,H,'replicate')',[]);
                colormap('default');
                colorbar;
            end
%         %
%             for j = 2:3
%                 distance = sqrt((xf-objposition(j-1,1)).^2 + (yf-objposition(j-1,2)).^2);
%                 fmap = griddata(xf,yf,distance,xx,yy,'linear');
%                 subplot(3,3,j+6);
%                 %imshow(imfilter(fmap,H,'replicate'),[]);
%                 imshow(fmap',[]);
%                 colormap('default');
%                 colorbar;
%             end
            ;
    
end