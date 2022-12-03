
function [fr fr_rb im_ fr_half frss] = PB_OnlineImage_SingleUnit(subjID,experiment,day,unitnumber,serialno,tz,doplot);
if nargin < 8
    para =[];
    ev = [];
end



if nargin < 7
    doplot = 0;
end


if nargin < 6
    tz(1) = 60;
    tz(2) = 220;
end


if nargin < 5
    serialno = [];
end

if ~isempty(serialno)
    [strctUnit fn] = fnFindMat(subjID,day,experiment,unitnumber,[day '_' subjID '_' sprintf('%3.3d',serialno)]);
else
    [strctUnit fn] = fnFindMat(subjID,day,experiment,unitnumber,[day '_' subjID '_*' ]);
end






xx = max(strctUnit.m_aiStimulusIndex);
fr_rb = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, tz(1),tz(2),-50,25);

[fr fr_half consistency]  = fnAveragePB_splitharf(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid,...
    diag(1:144)>0, strctUnit.m_aiPeriStimulusRangeMS, tz(1),tz(2));

[su ] = fnFindMat(subjID,day,experiment,unitnumber,'selectimage2');
if ~isempty(su)
    frss = fnAveragePB(su.m_a2bRaster_Valid,  su.m_aiStimulusIndexValid, diag(1:1593)>0, su.m_aiPeriStimulusRangeMS, tz(1),tz(2));
else
    frss = [];
end



xx = find(fn == '_'); yy = find(fn == '.');
foldername = fn(xx(end-2)+1:yy(end)-1);
imgfoldername = ['D:\PB2\Stimuli\OnlineImage\' foldername '\'];
tt = dir([imgfoldername '*.tif']);

for i = 1:length(tt)
    im_(:,:,i) = imread([imgfoldername tt(i).name]);
end

im2 = moscicimage(im_,1:144,255);

if doplot
    
    xx = find(fn == '_'); yy = find(fn == '.');
    foldername = fn(xx(end-2)+1:yy(end)-1);
    fr = reshape(fr,12,12);
    
    figure;
    
    subplot(1,2,1);
    hold on;
    f1 = mean(fr(:))-3*std(fr(:));
    f2 = mean(fr(:))+3*std(fr(:));
    f2 = mean(fr(12,:));
    f1 = mean(fr(1,:));
    
    ff = (fr-f1)/(f2-f1);
    ff(ff<0) = 0;
    ff(ff>1) = 1;
    
    
    for i=1:12
        for j = 1:12
            scatter(i,13- j,100,[ff(i,j) 0 1-ff(i,j)],'filled');
        end
    end
    
    axis equal
    axis square;
    axis([0 13 0 13]);
    
%     subplot(1,3,2);
%     
%     plot(mean(fr,1),'bo-');
%     hold on;
%     plot(mean(fr,2),'ro-');
%     
%     legend('Othogonal','STA');
%     axis square;
    
    subplot(1,2,2);
    
    imgfoldername = ['D:\PB2\Stimuli\OnlineImage\' foldername '\'];
    tt = dir([imgfoldername '*.tif']);
    
    for i = 1:length(tt)
        im_(:,:,i) = imread([imgfoldername tt(i).name]);
    end
    
    im2 = moscicimage(im_,1:144,255);
    imshow(im2,[]);
    set(gcf,'Position',[418   648   766   330]);
    
%     figure;
%     tt = strctUnit.m_a2fAvgFirintRate_Category;
%     figure;
%     subplot(1,2,1);
%     plot(tt(7:12,200:600)','linewidth',2)
%     legend('STA1','STA2','STA3','STA4','STA5','STA6');
%     subplot(1,2,2);
%     plot(tt(1:6,200:600)','linewidth',2);
%     legend('Otho1','Otho2','Otho3','Otho4','Otho5','Otho6');
%     
%     
%     tt = strctUnit.m_a2fAvgLFPCategory
%     figure;
%     subplot(1,2,1);
%     plot(tt(7:12,200:800)','linewidth',2)
%     legend('STA1','STA2','STA3','STA4','STA5','STA6');
%     subplot(1,2,2);
%     plot(tt(1:6,200:800)','linewidth',2);
%     legend('Otho1','Otho2','Otho3','Otho4','Otho5','Otho6');
    
end

% if ~isempty(para)
%     pp = para.pp;
%     r_p_50 = para.r_p_50;
%     resp_select = para.resp_select;
%     resp_left = para.resp_left;
%
%     resp_select = resp_select';
%
%
%     if isempty(su)
%         ev = ones(1,3)*nan;
%         return;
%     end
%
%
% %
% %     mask = ~(isnan(frss));
% %     ff = frss(mask);
% %     p1 = pp(mask,:);
% %
% %
% %     sta = lscov(p1,ff);
% %
% %
% %
% %     [xl,yl,xs,ys,beta,pctvar,mse] = plsregress(resp_select(mask,:),ff,11);
% %
% %
% %
% %     if exist([imgfoldername '\parameter.mat','file']
% %         load([imgfoldername '\parameter']);
% %         for k = 1:144
% %             i = ceil(k/12);
% %             j = mod(k,12); if j == 0; j = 12;end;
% %
% %             % pred_r(k) = sta * (r_p_50(selectIndex(i,j),:))';
% %             pred_r(k) = r_p_50(selectIndex(i,j),:) * sta;
% %             X = resp_left(selectIndex(i,j),:);
% %             pls_r(k)  = [ones(size(X,1),1) X]*beta;
% %
% %         end
% %     else
% %         imglist = dir([imgfoldername '*.tif']);
% %         for i = 1:length(imglist)
% %             imgall = imread(imglist(i).name);
% %             resp =
% %
% %
% %
% %     end
% %     rm = corrcoef(fr_half(:,1),pred_r); rpca = rm(1,2);
% %     rp = corrcoef(fr_half(:,1),pls_r);  rpls = rp(1,2);
% %     ev(1) = consistency; ev(2) = rpca; ev(3) = rpls;
% end


