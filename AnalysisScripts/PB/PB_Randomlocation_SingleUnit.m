function result = OcclusionAnalysis(subjID,experiment,foldername,unitnumber,ccc)

if ccc == 1
    tag = 'First';
elseif ccc == 2
    tag = 'Second';
else
    tag = 'all';
    
end

usePB = 1;


matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
if ccc < 3
    mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_RandomPosition_' tag '500*.mat']);
    [matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_RandomPosition_' tag '500*.mat']
    if ~isempty(mat)
        strctUnit = load([matpath mat(1).name]);
        strctUnit = strctUnit.strctUnit;
        [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
        rf = strctUnit.m_afAvgFirintRate_Stimulus(1:500);
        ro = strctUnit.m_afAvgFirintRate_Stimulus(501:1000);
        rc = strctUnit.m_afAvgFirintRate_Stimulus(1001:1500);
        
    else
        output = nan;
        return;
    end
else
    mat1 = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_RandomPosition_First500*.mat']);
    mat2 = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_RandomPosition_Second500*.mat']);
    strctUnit = load([matpath mat1(1).name]);
    strctUnit = strctUnit.strctUnit;
    [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
    rf = strctUnit.m_afAvgFirintRate_Stimulus(1:500);
    ro = strctUnit.m_afAvgFirintRate_Stimulus(501:1000);
    rc = strctUnit.m_afAvgFirintRate_Stimulus(1001:1500);
    strctUnit = load([matpath mat2(1).name]);
    strctUnit = strctUnit.strctUnit;
    [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
    rf(501:1000) = strctUnit.m_afAvgFirintRate_Stimulus(1:500);
    ro(501:1000) = strctUnit.m_afAvgFirintRate_Stimulus(501:1000);
    rc(501:1000) = strctUnit.m_afAvgFirintRate_Stimulus(1001:1500);
end
pathname = '\\192.168.50.15\StimulusSet\TwoImagesRandomLocation';
position = load([pathname '\position.mat']);
position = position.position;
position = position/2;

if ccc == 1
    xf = position(1:500,1);
    yf = position(1:500,2);
    xo = position(1:500,3);
    yo = position(1:500,4);
elseif ccc == 2
    xf = position(501:end,1);
    yf = position(501:end,2);
    xo = position(501:end,3);
    yo = position(501:end,4);
else
    xf = position(:,1);
    yf = position(:,2);
    xo = position(:,3);
    yo = position(:,4);
    
end

if usePB
    [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
end

figure;


[xx yy] = meshgrid(1:375,1:375);
fmap = griddata(xf,yf,rf,xx,yy,'linear');
omap = griddata(xo,yo,ro,xx,yy,'linear');
H = fspecial('Gaussian',[20 20],4);
subplot(3,2,1);
imshow(imfilter(fmap,H,'replicate'),[]);
colormap('default');
colorbar;
set(gca,'clim',[0 100]);
subplot(3,2,2);
imshow(imfilter(omap,H,'replicate'),[]);
colormap('default');
colorbar;
set(gca,'clim',[0 100]);

% w = (rc-ro)./(rf-ro);
% deleteindex = find(abs(rf-ro)<10);
% w(deleteindex) = [];
% xf(deleteindex) = [];
% yf(deleteindex) = [];
% xo(deleteindex) = [];
% yo(deleteindex) = [];
% [junk tt] = sort(w);
% for i = 21:40;
%     hold on;
%     index = tt(i);
%     plot(xf(index),yf(index),'ro');
%     plot(xo(index),yo(index),'bo');
% end


fweightmap = griddata(xf,yf,rc,xx,yy,'linear');
oweightmap = griddata(xo,yo,rc,xx,yy,'linear');
subplot(3,2,3);
imshow(fweightmap,[]);
% imshow(imfilter(fweightmap,H,'replicate'),[]);
colormap('default');
colorbar;
subplot(3,2,4);
imshow(oweightmap,[]);

% imshow(imfilter(oweightmap,H,'replicate'),[]);
colormap('default');
colorbar;



fweightmap = griddata(xf,yf,rf-rc,xx,yy,'linear');
oweightmap = griddata(xo,yo,rf-rc,xx,yy,'linear');
subplot(3,2,5);
%imshow(fweightmap,[]);
imshow(imfilter(fweightmap,H,'replicate'),[]);
colormap('default');
colorbar;
subplot(3,2,6);
%imshow(oweightmap,[]);
imshow(imfilter(oweightmap,H,'replicate'),[]);
colormap('default');
colorbar;

