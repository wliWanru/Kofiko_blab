%load('C:\PB\EphysData\Alfie\Test\161123\RAW\..\Processed\SingleUnitDataEntries\Alfie_2016-11-23_16-21-12_Exp_NaN_Ch_001_Unit_012_Passive_Fixation_New_PBSS.mat');
function output = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,stimarea,drawplot,X)
if nargin < 6
    drawplot = 1;
end

if nargin < 7
    load('C:\Users\tsaolab\Documents\MATLAB\matconvnet-1.0-beta18\response_PBSS');
    X = r2{16}; X = X';
end

close all;
strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'PBSS_new');
if isempty(strctUnit)
    strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'PBSS_new_1');
end

doplot = 1;


xx = 2896;
[fr fr_half consistency]  = fnAveragePB_splitharf(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:2896)>0, strctUnit.m_aiPeriStimulusRangeMS, stimarea(1),stimarea(2));
fr(isnan(fr)) = 0;
consistency

iir = 1:2000;
[xl,yl,xs,ys,beta,pctvar,mse] = plsregress(X(iir,:),fr(iir),11);
allpredict = [ones(size(X,1),1) X]*beta;


output.fr = fr;
output.fr_half = fr_half;
output.allpredict = allpredict;
output.beta = beta;




if drawplot
    figure;
    
    plot(fr_half(:,1),fr_half(:,2));
    index = ~isnan(fr_half(:,1));
    plot(fr_half(index,1),fr_half(index,2),'o');
    t1 = corrcoef(fr_half(index,1),fr_half(index,2));
    title(sprintf('Consistency check (All Correlation: %2.2f',t1(1,2)));
    % Ressidual = (fr_half(index,1) - fr_half(index,2));
    % RessidualR2 = norm(Ressidual - mean(Ressidual))^2;
    % ExplainedV = 1 - RessidualR2/norm(fr_half(index,2)-mean(fr_half(index,2)))^2;
    
    
    load('C:\Users\tsaolab\Documents\MATLAB\matconvnet-1.0-beta18\response_PBSS');
    X = r2{16}; X = X';
    iir = 1:2000;
    [xl,yl,xs,ys,beta,pctvar,mse] = plsregress(X(iir,:),fr(iir),11);
    allpredict = [ones(size(X,1),1) X]*beta;
    allrandom = [ones(size(X,1),1) X]*beta([1 randperm(length(beta)-1)+1]);
    figure;
    subplot(1,2,1);
    plot(allpredict(1:2000),fr(1:2000),'o');
    t1 = corrcoef(allpredict(1:2000),fr(1:2000));
    title(sprintf('CC: %2.2f',t1(1,2)));
    subplot(1,2,2);
    plot(allrandom(1:2000),fr(1:2000),'o');
    
    
    
    figure;
    
    io = [(2001:2080) 2161:2160+46*8];
    is = [2081:2160 2160+46*8+1:2896];
    rr = [fr(io) fr(is) allpredict(io) allpredict(is) allrandom(io) allrandom(is)];
    im = corrcoef(rr);
    imshow(imresize(im,100,'nearest'));
    set(gca,'Clim',[0 1]);
    colorbar;
    
    for i = 1:6
        for j = i+1:6
            h = text((i-1)*100 + 25, (j-1)*100+50,sprintf('%2.2f',im(i,j)));
            set(h,'FontSize',20);
            set(h,'Color',[1 0 0]);
        end
    end
    axis on;
    
    figure;
    for i = 1:3
        for j = i:3
            subplot(3,3,(j-1)*3 + i);
            t1 = rr(:,i); t2 = rr(:,j+1);
            plot(t1,t2,'o');
            hold on;
            plot(0:max([t1;t2]), 0:max([t1;t2]),'r-');
            axis equal;
            axis square;
            axis([0 max([t1;t2]) 0 max([t1;t2])]);
            
        end
    end
    
    figure;
    for i = 1:3
        for j = i:3
            subplot(3,3,(j-1)*3 + i);
            t1 = rr(:,i); t2 = rr(:,j+1);
            plot(zscore(t1),zscore(t2),'o');
            hold on;
            %         plot(0:max([t1;t2]), 0:max([t1;t2]),'r-');
            %         axis equal;
            %         axis square;
            %                 axis([0 max([t1;t2]) 0 max([t1;t2])]);
            
        end
    end
    
    
    figure;
    for i = 1:4
        if i > 2
            ss = 'Predict';
        else
            ss = 'Real';
        end
        
        if mod(i,2) == 1;
            tt = 'obj';
        else
            tt = 'silouette';
        end
        tn = [ss ' ' tt];
        
        subplot(2,2,i);
        response = rr(1:end,i);
        im = reshape(response,8,size(rr,1)/8);
        im = imresize(im,10,'nearest');
        imshow(im,[]);
        set(gca,'Clim',[0 max(rr(:))]);
        colormap('jet');
        title(tn);
    end
    
end













return;






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
