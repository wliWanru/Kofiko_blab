function [fr fr_rb tc] = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot,tz)
if nargin < 6
    tz = [60 220];
end

if nargin < 5
    doplot = 1;
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'wholerotationimages');
if isempty(strctUnit)
    strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'wholeroatationimages_sil');
end


xx = 1224;

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, tz(1), tz(2));
fr_rb = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, tz(1), tz(2),-50,25);

k = 1;
for i = -100:20:400
    if ~doplot
        tc(:,k) = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, i, i+50);
        k = k + 1
    else
        tc(:,k) = 0;
    end
end





if doplot == 1;
    
    fr(isnan(fr)) = 0;
fr_rb(isnan(fr_rb)) = 0;
tc(isnan(tc)) = 0;

fr = fr(1:51*24);
fr_rb = fr_rb(1:51*24);
if ~doplot;
    tc = tc(1:51*24,:,:);
end
    
    close all;
    rr = reshape(fr,24,51);
    figure;
    subplot(2,1,1);
    imshow(imresize(rr,[240,510],'nearest'),[]);
    colormap('default');
    subplot(2,1,2);
    ro = mean(rr,1);
    bar(mean(rr));
    axis([0 52 min(ro)-1 max(ro)+1]);
    [junk index] = sort(ro);
    load('C:\PB\RotationImages\image.mat');
    ii = reshape(imgall,200,200,24,51);
    ii = squeeze(ii(:,:,1,:));
    figure
    subplot(2,1,1);
    index(end:-1:end-9)
    imshow(moscicimage(ii,index(end:-1:end-9),255,1,10),[]);
    subplot(2,1,2);
    imshow(moscicimage(ii,index(1:10),255,1,10),[]);
end

%     figure;
%
%     [junk index] = sort(ro);
%     load('C:\PB\RotationImages\image.mat');
%     ii = reshape(imgall,200,200,24,51);
%     for i = 1:length(index);
%         subplot(7,8,i);
%         imshow(ii(:,:,1,index(i)));
%     end
end





