function output = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';

figure;
strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'ColorSpace_Single');
load('\\192.168.50.15\StimulusSet\ColorSpace\cc.mat');
xx = 2000;
fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);

hsvcc = rgb2hsv(cc1);
hue = hsvcc(:,1);
saturate = 1-min(cc1,[],2);

hh = (0.025:0.05:1-0.025);
ss = (1-1/3)+1/(3*40):1/60:1-1/120;
for i = 1:length(hh);
    for j = 1:length(ss);
        index = find(~(hue < hh(i)-0.025) & (hue<hh(i)+0.025) & ~(saturate < ss(j)-1/120) & (saturate<ss(j)+1/120));
        ff(i,j) = mean(fr(index));
        resp = mean(ff);
    end
end

ff = imresize(ff,[200,200],'nearest');
imshow(ff,[]);
colormap('default');
colorbar;