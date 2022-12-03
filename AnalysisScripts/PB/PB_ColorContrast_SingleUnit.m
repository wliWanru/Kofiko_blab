function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber)

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'ColorContrast');

xx = max(strctUnit.m_aiStimulusIndex);

[fr se] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 70, 220);
strctUnit.m_strImageListUsed

return;

strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end
for i = 1:length(filename)
    nn = filename{i};
    index = find(nn=='_');
    cc(i,1) = str2num(nn(9:10));
    cc(i,2) = str2num(nn(12:13));
    
end
cc(cc==21) = - 99;
dd = cc + 10;
dd(dd>20) = dd(dd>20)-20;

index = find(cc(:,1) == -99 & cc(:,2) == -99);
rbase = (fr(index));
for i = 1:20
    index1 = find(cc(:,1) == i & cc(:,2) == -99);
    index2 = find(cc(:,2) == i & cc(:,1) == -99);
    rw(i) =  (fr(index1) + fr(index2))/2;
end
rw2 = [rw(11:20) rw(1:10)];
for i = 1:20
    for j = 1:20
        index1 = find(cc(:,1)==i & cc(:,2) == j);
        index2 = find(cc(:,1)==j & cc(:,2) == i);
        resp(i,j) =  (fr(index1) + fr(index2))/2;
        pred(i,j) = rw(i) + rw(j);
    end
end

figure
plot(1:20,rw2,'o-','linewidth',2,'MarkerSize',5);
for i = 1:20
    for j = 1:20
        index1 = find(dd(:,1)==i & dd(:,2) == j);
        index2 = find(dd(:,1)==j & dd(:,2) == i);
        resp2(i,j) =  (fr(index1) + fr(index2))/2;
        pred2(i,j) = rw2(i) + rw2(j);
    end
end


figure;
% subplot(2,2,1);
% imshow(imresize(resp,[200 200],'nearest'),[]);
% colormap('default');
% set(gca,'clim',[0 max(resp(:))]);
% 
% 
% subplot(2,2,2);
% imshow(imresize(pred,[200 200],'nearest'),[]);
% colormap('default');
% set(gca,'clim',[0 max(resp(:))]);

% subplot(2,2,3);
subplot(1,3,1);
imshow(imresize(resp2,[200 200],'nearest'),[]);
colormap('default');
set(gca,'clim',[0 max(resp(:))]);
subplot(1,3,2);
plot(1:20,rw2,'o-','linewidth',2,'MarkerSize',5);
subplot(1,3,3);
imshow(imresize(pred2,[200 200],'nearest'),[]);
colormap('default');
set(gca,'clim',[0 max(resp(:))]);

% subplot(2,2,4);
% imshow(imresize(pred2,[200 200],'nearest'),[]);
% colormap('default');
% set(gca,'clim',[0 max(resp(:))]);
% rr = corrcoef(resp(:),pred(:));
% r = rr(1,2)
% beta = lscov(pred(:),resp(:))

figure;
subplot(1,2,1);
for i = 1:20
    res_square(i) = resp2(i,i);
end

plot(1:20,res_square,'b');
hold on;
plot(1:20,rw2*2,'r');
subplot(1,2,2);
plot(pred(:),resp(:),'.');
axis equal
axis square
axis([0 max([pred(:);resp(:)]) 0 max([pred(:);resp(:)])]);

beta = lscov(pred(:),resp(:))


