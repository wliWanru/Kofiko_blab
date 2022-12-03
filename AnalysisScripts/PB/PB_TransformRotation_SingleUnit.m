function [fr fr_rb tc] = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,doplot)

if nargin < 2
    strctUnit = load(subjID);
    strctUnit = strctUnit.strctUnit;
    doplot = 0;
    
else
    
    if nargin < 5
        doplot = 1;
    end
    
    strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'RotationImage_Transformed');
end
xx = 1224;

[fr] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);
fr_rb = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220,-50,25);
k = 1;
for i = -100:20:400
    if ~doplot
        tc(:,k) = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, i, i+50);
        k = k + 1
    else
        tc = 0;
    end
end

%tc =
% k = 1;
% for i = -100:20:400
%     if ~doplot
%         tc(:,k) = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, i, i+50);
%         k = k + 1
%     else
%         tc = 0;
%     end
% end

fr(isnan(fr)) = 0;
fr_rb(isnan(fr_rb)) = 0;


if doplot == 1;
    close all;
    rr = reshape(fr,408,3);
    figure;
    for i = 1:3
        subplot(3,1,i);
        ff = rr(:,i);
        im = reshape(ff,8,51);
        im = imresize(im,[80 510],'nearest');
        imshow(im,[]); colormap('default');
        set(gca,'Clim',[0 max(fr)]);
        colorbar;
    end
    
    
    figure;
    subplot(1,2,1);
    plot(rr(:,1),rr(:,2),'b.');
    tt = corrcoef(rr(:,1),rr(:,2)); c1 = tt(1,2)
    b1 = rr(:,2)\rr(:,1)
    subplot(1,2,2);
    plot(rr(:,3),rr(:,2),'b.');
    tt = corrcoef(rr(:,3),rr(:,2)); c2 = tt(1,2)
    b2 = rr(:,2)\rr(:,3)
end
