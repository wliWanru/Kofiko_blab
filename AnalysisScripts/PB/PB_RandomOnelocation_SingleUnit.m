function [rf ro] = OcclusionAnalysis(subjID,experiment,foldername,unitnumber)

matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_OneImageRandomPosition_*.mat']);
if length(mat)>1
    for j = 1:length(mat)
        mat(j).name
        fprintf('\n');
    end
    selectedindex = input('Which?\n');
else
    selectedindex = 1;
end

if ~isempty(mat)
    strctUnit = load([matpath mat(selectedindex).name]);
    strctUnit = strctUnit.strctUnit;
    %[strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
    strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    for i = 1:length(strctDesign.m_astrctMedia);
        filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    end
else
    output = nan;
    return;
end

for i = 1:length(filename)
    fn = filename{i};
    tt = find(fn == '_');
    [junk fnwithoutextension ext] = fileparts(fn);
    attrname = fn(1:tt(1)-1);
    if strcmpi(attrname,'obj');
        cond(i,1) = 2;
        cond(i,2) = str2num(fnwithoutextension(end));
        cond(i,3) = 0;
    elseif strcmpi(attrname,'face');
        cond(i,1) = 1;
        cond(i,2) = 0;
        cond(i,3) = str2num(fnwithoutextension(end-3:end));      
    elseif strcmpi(attrname,'comb');
        cond(i,1) = 3;
        cond(i,2) = str2num(fnwithoutextension(end));
        cond(i,3) = str2num(fn(tt(2)-4:tt(2)-1));
    end
end

[strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);

pathname = '\\192.168.50.15\StimulusSet\OneImagesOneNoiseRandomLocation';
position = load([pathname '\position.mat']);
position = position.position;
position = position/2;


for i = 1:500
    for j = 1:3
         index = find(cond(:,3) == i & cond(:,2) == j-1);
         rf(j,i) = strctUnit.m_afAvgFirintRate_Stimulus(index);
    end
end

for i = 1:2
    index = find(cond(:,3)==0 & cond(:,2) == i);
    ro(i) =  mean(strctUnit.m_afAvgFirintRate_Stimulus(index));
end

         

xf = position(1:500,1);
yf = position(1:500,2);

opleft = [376  265]/2;
opright = [376 487]/2;

% if usePB
%     [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
% end

figure;


[xx yy] = meshgrid(1:375,1:375);
H = fspecial('Gaussian',[20 20],4);
for i = 1:3
fmap = griddata(xf,yf,rf(i,:),xx,yy,'linear');
subplot(2,3,i);
imshow(imfilter(fmap,H,'replicate'),[]);
colormap('default');
colorbar;
end

for j = 2:3
fmap = griddata(xf,yf,rf(j,:)-rf(1,:),xx,yy,'linear');
subplot(2,3,j+3);
imshow(imfilter(fmap,H,'replicate'),[]);
colormap('default');
colorbar;
end
% subplot(3,2,2);
% imshow(imfilter(omap,H,'replicate'),[]);
% colormap('default');
% colorbar;
% set(gca,'clim',[0 100]);
% 
% % w = (rc-ro)./(rf-ro);
% % deleteindex = find(abs(rf-ro)<10);
% % w(deleteindex) = [];
% % xf(deleteindex) = [];
% % yf(deleteindex) = [];
% % xo(deleteindex) = [];
% % yo(deleteindex) = [];
% % [junk tt] = sort(w);
% % for i = 21:40;
% %     hold on;
% %     index = tt(i);
% %     plot(xf(index),yf(index),'ro');
% %     plot(xo(index),yo(index),'bo');
% % end
% 
% 
% fweightmap = griddata(xf,yf,rc,xx,yy,'linear');
% oweightmap = griddata(xo,yo,rc,xx,yy,'linear');
% subplot(3,2,3);
% imshow(fweightmap,[]);
% % imshow(imfilter(fweightmap,H,'replicate'),[]);
% colormap('default');
% colorbar;
% subplot(3,2,4);
% imshow(oweightmap,[]);
% 
% % imshow(imfilter(oweightmap,H,'replicate'),[]);
% colormap('default');
% colorbar;
% 
% 
% 
% fweightmap = griddata(xf,yf,rf-rc,xx,yy,'linear');
% oweightmap = griddata(xo,yo,rf-rc,xx,yy,'linear');
% subplot(3,2,5);
% %imshow(fweightmap,[]);
% imshow(imfilter(fweightmap,H,'replicate'),[]);
% colormap('default');
% colorbar;
% subplot(3,2,6);
% %imshow(oweightmap,[]);
% imshow(imfilter(oweightmap,H,'replicate'),[]);
% colormap('default');
% colorbar;
% 
