%load('C:\PB\EphysData\Alfie\Test\161123\RAW\..\Processed\SingleUnitDataEntries\Alfie_2016-11-23_16-21-12_Exp_NaN_Ch_001_Unit_012_Passive_Fixation_New_PBSS.mat');
function output = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber)

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'PBSS');
flag = 1;
if isempty(strctUnit)
    strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'PBSS16');
    flag = 2;
end

doplot = 1;


xx = 2816;
[fr fr_half consistency]  = fnAveragePB_splitharf(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:2816)>0, strctUnit.m_aiPeriStimulusRangeMS, 60,220);

output.consistency = consistency;
output.fr = fr;
output.fr_half = fr_half;
output.flag = flag;







afr = fr(1:2000);
raw = fr(2001:2000+8*51);
sil = fr(2000 + 8 * 51 + 1:end);

if flag == 1;
    load('C:\PB\RotationImages\artifical2\pp.mat');
else
    load('C:\PB\RotationImages\artifical3\pp.mat');
end


if doplot
figure;
subplot(1,3,1);
im = reshape(raw,8,51);
imshow(imresize(im,[80 510],'nearest'),[]);
colormap('default');
subplot(1,3,2);
im = reshape(sil,8,51);
imshow(imresize(im,[80 510],'nearest'),[]);
colormap('default');
subplot(1,3,3);
plot(raw,sil,'o');
tt = corrcoef(raw,sil);
title(sprintf('Correlation=%2.2f',tt(1,2)));
end

afr(isnan(afr)) = 0;

sc = std(score,0,1);
ts = xx.* repmat(sc(1:30),size(xx,1),1);
for i = 1:size(ts,1);
    vv(i) = norm(ts(i,:));
end

factor = mean(vv);

xx = ts/factor;


% beta = lscov([ts ones(2000,1)],afr - mean(afr));
% 
% residual = (afr - mean(afr)) - [xx ones(2000,1)]*beta;



for i = 1:size(xx,2)
    sta(i) = sum(afr.*xx(:,i))/sum(afr);
    tt = corrcoef(afr,xx(:,i));
    cc(i) = tt(1,2);
end

for rn = 1:1000
    bfr = afr(randperm(length(afr)));
    for i = 1:size(xx,2)
        sta_base(i,rn) = sum(bfr.*xx(:,i))/sum(bfr);
    end
end

figure;
plot(sta,'ko-');
hold on;
errorbar(1:size(sta_base,1),mean(sta_base,2),std(sta_base,0,2));


for i = 1:size(ts,1)
    vl(i) = (dot(xx(i,:),sta)/norm(sta)^2);
end
distance = (max(vl) - min(vl))/50;

gn = ceil((vl - min(vl))/distance);
k = 1;
for i = min(gn):max(gn)
    ii = find(gn == i);
    nn(k) = length(ii);
    mr(k) = mean(afr(ii));
    dr(k) = mean(vl(ii));
    if length(ii)>1
        sr(k) = std(afr(ii))/sqrt(length(ii));
    else
        sr(k) = 0;
    end
    k = k + 1;
end
figure;
mr(nn<10) = [];
sr(nn<10) = [];
dr(nn<10) = [];
errorbar(dr,mr,sr);

ss = reshape(score,24,51,200);
ss = ss(1:8,:,:);
ss = reshape(ss,8*51,200);

ss = ss(:,1:30)/factor;

for i = 1:size(ss,1);
    sl(i) = (dot(ss(i,:),sta)/norm(sta)^2);
end


corrcoef(vl,afr)

figure;
subplot(3,2,1);
im = reshape(raw,8,51); 
imshow(imresize(im,[80 510],'nearest'),[]);
colormap('default');
subplot(3,2,2);
im = reshape(sil,8,51);
imshow(imresize(im,[80 510],'nearest'),[]);
colormap('default');
subplot(3,2,3);
im = reshape(sl,8,51);
imshow(imresize(im,[80 510],'nearest'),[]);
colormap('default');
subplot(3,2,4);

p = polyfit(vl',afr,5);
r = polyval(p,sl);

im = reshape(r,8,51);
imshow(imresize(im,[80 510],'nearest'),[]);
colormap('default');

subplot(3,2,5);

m = fitrsvm(xx,fr(1:2000,1),'KernelFunction','linear');
r = predict(m,ss);
im = reshape(r,8,51);
imshow(imresize(im,[80 510],'nearest'),[]);
colormap('default');

subplot(3,2,6);
m = fitrsvm(xx,fr(1:2000,1),'KernelFunction','gaussian');
r = predict(m,ss);
im = reshape(r,8,51);
imshow(imresize(im,[80 510],'nearest'),[]);
colormap('default');


figure;
m = fitrsvm(xx,fr(1:2000,1),'KernelFunction','linear');
k = 0;
ii = 2; jj = 4;

se = std(xx,0,1);


yy =zeros*ones(100*100,30);
s1 = se(ii);
s2 = se(jj);
[x y] = meshgrid(linspace(-1.2*s1,1.2*s1,100),linspace(-1.2*s2,1.2*s2,100));
yy(:,ii) = x(:);
yy(:,jj) = y(:);
rr = predict(m,yy);
figure
subplot(2,3,1)
imc = reshape(rr,100,100);
imshow(imc,[]);
subplot(2,3,2);
plot(imc(1:10:100,:)');

subplot(2,3,3);
plot(imc(:,1:10:100));



m = fitrsvm(xx,fr(1:2000,1),'KernelFunction','gaussian');
k = 0;

se = std(xx,0,1);


yy =zeros*ones(100*100,30);
s1 = se(ii);
s2 = se(jj);
[x y] = meshgrid(linspace(-1.2*s1,1.2*s1,100),linspace(-1.2*s2,1.2*s2,100));
yy(:,ii) = x(:);
yy(:,jj) = y(:);
rr = predict(m,yy);
subplot(2,3,4)
imc = reshape(rr,100,100);
imshow(imc,[]);
subplot(2,3,6);
plot(imc(1:10:100,:)');

subplot(2,3,6);
plot(imc(:,1:10:100));



%
% clear all;
% load('C:\PB\RotationImages\artifical2\pp.mat');
%
% figure;
% sc = std(score,0,1);
% ts = xx.* repmat(sc(1:30),size(xx,1),1);
% score = reshape(score,24,51,200);
% score_obj = score(1:8,:,1:30);
% score_obj = reshape(score_obj,51*8,30);
% for i = 1:size(score_obj,1);
%     so = score_obj(i,:);
%     for j = 1:size(xx,1);
%         dist(i,j) = norm(ts(j,:) - so);
%     end
% end



% for i = 1:24
%     subplot(6,4,i);
%     t1 = i;
%     ii = dist(t1,:);
%     [junk index] = sort(ii);
%     im2 = imread(['C:\PB\RotationImages\artifical3\recon' sprintf('%4.4d',t1) '.tif']);
%     im1 = imread(['C:\PB\RotationImages\artifical2\img' sprintf('%4.4d',index(1)) '.tif']);
%     im12 = [im1 im2];
%     imshow(im12,[]);
% end
%
% num = 5;
% load('C:\PB\EphysData\Alfie\Test\161123\RAW\..\Processed\SingleUnitDataEntries\Alfie_2016-11-23_16-21-12_Exp_NaN_Ch_001_Unit_013_Passive_Fixation_New_PBSS.mat');
%
% xx = 2816;
% fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60,220);
%
% afr = fr(1:2000);
% raw = fr(2001:2000+8*51);
% sil = fr(2000 + 8 * 51 + 1:end)
%
%
%
% for i = 1:size(dist,1);
%     ii = dist(i,1);
%     [junk index] = sort(ii);
%     nn = index(1:num);
%     rep_cc = afr(nn);
%     res(i) = mean(rep_cc);
% end
%
%
% subplot(1,3,1);
% im = reshape(res,8,51);
% imshow(imresize(im,[80 510],'nearest'),[]);
% colormap('default');
% subplot(1,3,2);
% im = reshape(sil,8,51);
% imshow(imresize(im,[80 510],'nearest'),[]);
% colormap('default');
% subplot(1,3,3);
% plot(res,sil,'o');
% tt = corrcoef(raw,sil);
% title(sprintf('Correlation=%2.2f',tt(1,2)));
%
%
%
%
%
%
%
%
%
%
%
