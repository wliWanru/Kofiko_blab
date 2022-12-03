function [rr rr2 rr3] = PB_BOSface_SingleUnit(foldername,unitnumber);

BOSFaceName = dir(['D:\PB\EphysData\Rocco\Test\' foldername '\RAW\..\Processed\SingleUnitDataEntries\*Unit_' unitnumber '*BOSFace.mat']);
matpath = ['D:\PB\EphysData\Rocco\Test\' foldername '\RAW\..\Processed\SingleUnitDataEntries\'];
mat = load([matpath BOSFaceName(1).name]);
strctUnit = mat.strctUnit;
orientation =  strctUnit.m_strctStimulusParams.m_afRotationAngle;
[ori count] = unique(orientation);
[junk,ii] = max(count);
ori = ori(ii);
ori
ContrastBOS = dir(['D:\PB\EphysData\Rocco\Test\' foldername '\RAW\..\Processed\SingleUnitDataEntries\*Unit_' unitnumber '*ContrastBorderOwner.mat']);

mat = load([matpath ContrastBOS(1).name]);
strctUnit = mat.strctUnit;
figure;
cond = [1 4
    3 2];

imall = BOSImage(0);
imnew{1} = imall{3};
imnew{2} = imall{4};
imnew{3} = imall{1};
imnew{4} = imall{2};
for i = 1:2
    subplot(3,5,i)
    if ori<180
        index1 = cond(i,1)
        index2 = cond(i,2)
    else
        index1 = cond(i,2);
        index2 = cond(i,1);
    end
    plot(-200:400,(strctUnit.m_a2fAvgFirintRate_Stimulus(index1,1:601)),'r-','LineWidth',2);
    hold on;
    plot(-200:400,(strctUnit.m_a2fAvgFirintRate_Stimulus(index2,1:601)),'b-','LineWidth',2);
    subplot(3,5,i+5);
    im1 = imnew{index1}*255;
    im2 = imnew{index2}*255;
    im1 = imresize(im1,[400 400]);
    im2 = imresize(im2,[400 400]);
    im_color= drawoutline(im2,im1);
    imshow(im_color);
    rr2(i,1,:) = (strctUnit.m_a2fAvgFirintRate_Stimulus(index1,1:601));
    rr2(i,2,:) = (strctUnit.m_a2fAvgFirintRate_Stimulus(index2,1:601));
end

TransparentBOS = dir(['D:\PB\EphysData\Rocco\Test\' foldername '\RAW\..\Processed\SingleUnitDataEntries\*Unit_' unitnumber '*TransparentImage.mat']);
if ~isempty(TransparentBOS)
    mat = load([matpath TransparentBOS(1).name]);
    strctUnit = mat.strctUnit;
    strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    for i = 1:length(strctDesign.m_astrctMedia);
        filename{i} = strctDesign.m_astrctMedia(i).m_strName;
        imagename{i} = strctDesign.m_astrctMedia(i).m_acFileNames{1};
    end
    for i = 1:3
        index1 = i; index2 = i + 3;
        subplot(3,5,i+2);
        plot(-200:400,(strctUnit.m_a2fAvgFirintRate_Stimulus(index1,1:601)),'b-','LineWidth',2);
        hold on;
        plot(-200:400,(strctUnit.m_a2fAvgFirintRate_Stimulus(index2,1:601)),'r-','LineWidth',2);
        box off
        set(gca,'Linewidth',2);
        set(gca,'FontSize',12);
        subplot(3,5,i+7);
        im1 = imread(imagename{index1(1)});
        im1new = ones(440,440)*double(im1(1,1));
        im1new(:,51:390) = im1;
        im1new = imresize(uint8(im1new),[400,400],'nearest');
        im2 = imread(imagename{index2(1)});
        im2new = ones(440,440)*double(im2(1,1));
        im2new(:,51:390) = im2;
        im2new = imresize(uint8(im2new),[400,400],'nearest');
        im_color= drawoutline(im1new,im2new);
        imshow(im_color);
        rr3(i,1,:) = (strctUnit.m_a2fAvgFirintRate_Stimulus(index1,1:601));
        rr3(i,2,:) = (strctUnit.m_a2fAvgFirintRate_Stimulus(index2,1:601));
    end
else
    rr3 = nan;
end



mat = load([matpath BOSFaceName(1).name]);
strctUnit = mat.strctUnit;
orientation =  strctUnit.m_strctStimulusParams.m_afRotationAngle;
[ori count] = unique(orientation);
[junk,ii] = max(count);
ori = ori(ii);

strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    imagename{i} = strctDesign.m_astrctMedia(i).m_acFileNames{1};
end

k = 1;



for i = 1:length(filename)
    fn = filename{i};
    xx = find(fn == '_');
    condname = fn(xx(1)+1:end);
    for j = (i+1):length(filename)
        fn = filename{j};
        xx = find(fn == '_');
        cc = fn(xx(1)+1:end);
        if strcmpi(condname,cc);
            pair(k,1:2) = [i j];
            k = k + 1;
        end
    end
end

tt = [1 3 5 7 10 12 14 16 18 21 23 25];
kk = [1 3];
for i = 1:5
    kk(end+1,:) = [tt(i+2) tt(i+7)];
end
kk = kk([1 2 6 5 3 4],:);
numofcond = size(kk,1);
figure;
for i = 1:numofcond
    
    index1 = pair(kk(i,:),1)
    index2 = pair(kk(i,:),2)
    subplot(3,numofcond,i);
    plot(-200:400,mean(strctUnit.m_a2fAvgFirintRate_Stimulus(index1,1:601)),'b-','LineWidth',2);
    hold on;
    plot(-200:400,mean(strctUnit.m_a2fAvgFirintRate_Stimulus(index2,1:601)),'r-','LineWidth',2);
    rr(i,1,:) = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(index1,1:601));
    rr(i,2,:) = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(index2,1:601));
    box off
    set(gca,'Linewidth',2);
    set(gca,'FontSize',12);
    subplot(3,numofcond,i+numofcond);
    im1 = imread(imagename{index1(1)});
    im2 = imread(imagename{index2(1)});
    im_color= drawoutline(im1,im2);
    %     im1 = imrotate(im1,ori);
    %     im2 = imrotate(im2,ori);
    %     im1 = drawelipse(im1);
    %     im2 = drawelipse(im2);
    %     imall = [im2;127*ones(20,size(im1,2));im1];
    %     d = 20;
    %     imd = size(im1,1);
    %     im_color(:,:,1) = imall;
    %     im_color(:,:,2) = imall;
    %     im_color(:,:,3) = imall;
    %     im_color(1:d,:,1) = 255;
    %     im_color(1:d,:,2:3) = 0;
    %     im_color(imd-d+1:imd,:,1) = 255;
    %     im_color(imd-d+1:imd,:,2:3) = 0;
    %     im_color(1:imd,1:d,1) = 255;
    %     im_color(1:imd,1:d,2:3) = 0;
    %     im_color(1:imd,imd-d+1:imd,1) = 255;
    %     im_color(1:imd,imd-d+1:imd,2:3) = 0;
    %
    %     im_color(1:d,:,1) = 255;
    %     im_color(1:d,:,2:3) = 0;
    %     im_color(imd-d+1:imd,:,1) = 255;
    %     im_color(imd-d+1:imd,:,2:3) = 0;
    %     im_color(1:imd,1:d,1) = 255;
    %     im_color(1:imd,1:d,2:3) = 0;
    %     im_color(1:imd,imd-d+1:imd,1) = 255;
    %     im_color(1:imd,imd-d+1:imd,2:3) = 0;
    %
    %
    %     im_color(imd+20+1:imd+20+d,:,3) = 255;
    %     im_color(imd+20+1:imd+20+d,:,1:2) = 0;
    %     im_color(end-d+1:end,:,3) = 255;
    %     im_color(end-d+1:end,:,1:2) = 0;
    %     im_color(imd+20+1:end,1:d,3) = 255;
    %     im_color(imd+20+1:end,1:d,1:2) = 0;
    %     im_color(imd+20+1:end,imd-d+1:imd,3) = 255;
    %     im_color(imd+20+1:end,imd-d+1:imd,1:2) = 0;
    imshow(im_color);
end

function im1 = drawelipse(im1);

a=30;
b=15;
x0= round(size(im1,1)/2); % x0,y0 ellipse centre coordinates
y0= round(size(im1,2)/2);
[xx yy] = meshgrid(1:size(im1,1),1:size(im1,2));
r = (xx-x0).^2/a^2+(yy-y0).^2/b^2;
im1(r>0.8&r<1.2) = 255;

function im_color = drawoutline(im1,im2);
im1 = drawelipse(im1);
im2 = drawelipse(im2);
imall = [im2;127*ones(20,size(im1,2));im1];
d = 20;
imd1 = size(im1,1);
imd2 = size(im1,2);
im_color(:,:,1) = imall;
im_color(:,:,2) = imall;
im_color(:,:,3) = imall;
im_color(1:d,:,1) = 255;
im_color(1:d,:,2:3) = 0;
im_color(imd1-d+1:imd1,:,1) = 255;
im_color(imd1-d+1:imd1,:,2:3) = 0;
im_color(1:imd1,1:d,1) = 255;
im_color(1:imd1,1:d,2:3) = 0;
im_color(1:imd1,imd2-d+1:imd2,1) = 255;
im_color(1:imd1,imd2-d+1:imd2,2:3) = 0;

im_color(1:d,:,1) = 255;
im_color(1:d,:,2:3) = 0;
im_color(imd1-d+1:imd1,:,1) = 255;
im_color(imd1-d+1:imd1,:,2:3) = 0;
im_color(1:imd1,1:d,1) = 255;
im_color(1:imd1,1:d,2:3) = 0;
im_color(1:imd1,imd2-d+1:imd2,1) = 255;
im_color(1:imd1,imd2-d+1:imd2,2:3) = 0;


im_color(imd1+20+1:imd1+20+d,:,3) = 255;
im_color(imd1+20+1:imd1+20+d,:,1:2) = 0;
im_color(end-d+1:end,:,3) = 255;
im_color(end-d+1:end,:,1:2) = 0;
im_color(imd1+20+1:end,1:d,3) = 255;
im_color(imd1+20+1:end,1:d,1:2) = 0;
im_color(imd1+20+1:end,imd2-d+1:imd2,3) = 255;
im_color(imd1+20+1:end,imd2-d+1:imd2,1:2) = 0;


