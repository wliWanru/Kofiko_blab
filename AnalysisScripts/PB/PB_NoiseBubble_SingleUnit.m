function output = PB_NoiseBubble_SingleUnit(subjID,experiment,foldername,unitnumber,imall);
if nargin < 5
    load imall;
end
matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];

mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_NoiseBubble_*.mat']);
[matpath '*_Unit_' unitnumber '_Passive_Fixation_New_.mat']
if ~isempty(mat)
    strctUnit = load([matpath mat(1).name]);
    strctUnit = strctUnit.strctUnit;
            strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);

else
    return;
end
[strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 200);

% fn = fn{1};
% im = imread(fn);
% imall = zeros(length(strctDesign.m_astrctMedia),size(im,1),size(im,2));
% sigmalist = zeros(2000,1);
%
for i = 1:length( strctDesign.m_astrctMedia);
    fn = strctDesign.m_astrctMedia(i).m_acFileNames;
    fn = fn{1};
    sigmalist(i) = str2num(strctDesign.m_astrctMedia(i).m_acAttributes{1}(end));
end

im_sigma1 = imall((sigmalist==1),:,:);
im_sigma2 = imall((sigmalist==2),:,:);

weight_sigma1 = strctUnit.m_afAvgFirintRate_Stimulus((sigmalist==1));
weight_sigma2 = strctUnit.m_afAvgFirintRate_Stimulus((sigmalist==2));


[im11] = staimage(weight_sigma1,im_sigma1);
[im22] = staimage(weight_sigma2,im_sigma2);

figure;
subplot(2,2,1)
imshow(im11(:,1:196),[]);
colorbar;
subplot(2,2,2)

imshow(im22(:,1:196),[]);
colorbar;


for i = 1:100
    tic
    ws1 = weight_sigma1(randperm(length(weight_sigma1)));
    ws2 = weight_sigma2(randperm(length(weight_sigma2)));
    im1_base(:,:,i) = staimage(ws1,im_sigma1);
    im2_base(:,:,i) = staimage(ws2,im_sigma2);
    toc
end

dprimemap1 = dprime(im1_base,im11);
dprimemap2 = dprime(im2_base,im22);
subplot(2,2,3)
imshow(dprimemap1(:,1:196),[]);
colorbar;
subplot(2,2,4)
imshow(dprimemap2(:,1:196),[]);
colorbar;
colormap('default');
output.im1 = im11;
output.im2 = im22;
output.dmap1 = dprimemap1;
output.dmap2 = dprimemap2;
output.base1 = im1_base;
output.base2 = im2_base;

function dmap = dprime(im_base,im);
meanmap = mean(im_base,3);
stdmap = std(im_base,0,3);
dmap = abs(im-meanmap)./stdmap;


% weight_sigma1 = weight_sigma1 - mean(weight_sigma1);
% weight_sigma2 = weight_sigma2 - mean(weight_sigma2);
%
%
% [junk,im1] = staimage(weight_sigma1,im_sigma1);
% [junk,im2] = staimage(weight_sigma2,im_sigma2);
%
% subplot(2,2,3);
% imshow(im1(:,1:192),[])
% subplot(2,2,4);
% imshow(im2(:,1:192),[]);
%
% colormap('default');
