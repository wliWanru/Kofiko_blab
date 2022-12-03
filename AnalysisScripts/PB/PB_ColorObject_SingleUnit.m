
function frsort = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'ColorObject');
strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
xx = size(strctDesign.m_a2bStimulusToCondition,1);
[strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 80,230);

fr = strctUnit.m_afAvgFirintRate_Stimulus;
for i = 1:length(strctDesign.m_acMediaName);
    nn = strctDesign.m_acMediaName{i};
    index = find(nn=='_');
    cond(i,1) = str2num(nn(index(1)-1));
    cond(i,2) = str2num(nn(index(1)+6:index(2)-1));
    cond(i,3) = str2num(nn(end));
end

for i = 1:4
    for j = 1:20
        for k = 1:8
            ii = find(cond(:,1) == i & cond(:,2) == j & cond(:,3) == k);
            frsort(i,j,k) = fr(ii);
        end
    end
end

%return;


% tc = strctUnit.m_a2fAvgFirintRate_Stimulus;
% tc = reshape(tc,4,20,8,size(tc,2))
% for i = 1:4
% figure;
% rr = squeeze(tc(i,:,:,:));
%
% subplot(1,2,1);
% plot(strctUnit.m_aiPeriStimulusRangeMS,squeeze(mean(rr,1)),'Linewidth',2);
% axis([0 400 0 100])
%
% subplot(1,2,2);
% plot(strctUnit.m_aiPeriStimulusRangeMS,squeeze(mean(rr,2)),'Linewidth',2);
% axis([0 400 0 100])
% end
% return;
%
%fr = fr(:,4,[11:20 1:10
figure;
cc = {'r-','b-','g-','m-','r-','b-','g-','m-'}
xx = frsort;
p = polar(linspace(0,2*pi,21),(max(xx(:))+1)*ones(1,21));
set(p,'Visible','off');
hold on
for i = 1:4
    xx = squeeze(frsort(i,:,:));
    xx = mean(xx,2);
    h = polar(linspace(0,2*pi,21),[xx;xx(1)]',cc{i});
    set(h,'Linewidth',2);
    linecolor(i,:) = get(h,'Color');
    hold on;
end

% linecolor = uint8(round(linecolor*255));
% width = 10;
% figure;
% for i = 1:4
%     subplot(4,1,i);
%     index = find(cond(:,1) == i & cond(:,2) == 1 & cond(:,3) == 1)
%     tt = imread(strctDesign.m_astrctMedia(index).m_acFileNames{1});
%     for j = 1:3
%         tt(1:width,:,j) = linecolor(i,j);
%         tt(end-width+1:end,:,j) = linecolor(i,j);
%         tt(:,end-width+1:end,j) = linecolor(i,j);
%         tt(:,1:width,j) = linecolor(i,j);
%     end
%     imshow(tt)
% end
% 
% 
% figure;
% for j = 1:4
% for i = 1:8
%     subplot(4,8,(j-1)*8+i);
%     index = find(cond(:,1) == j & cond(:,2) == 1 & cond(:,3) ==i)
%     tt = imread(strctDesign.m_astrctMedia(index).m_acFileNames{1});
%     imshow(tt);
% end
% end
% 
% figure;
% for i = 1:20
%     subplot(1,20,i);
%     index = find(cond(:,1) == 3 & cond(:,2) == i & cond(:,3) == 1)
%     tt = imread(strctDesign.m_astrctMedia(index).m_acFileNames{1});
%     imshow(tt);
% end


(max(frsort(:))+1)*ones(1,21)
hold on
for j = 1:8
    subplot(4,2,j);
    p = polar(linspace(0,2*pi,21),(max(frsort(:))+1)*ones(1,21));
    set(p,'Visible','off');
    for i = 1:4
        xx = squeeze(frsort(i,:,:));
        xx = xx(:,j);
        h = polar(linspace(0,2*pi,21),[xx;xx(1)]',cc{i});
        set(h,'Linewidth',2);
        linecolor(i,:) = get(h,'Color');
        hold on;
    end
end



figure;
for i = 1:4
    subplot(2,2,i);
    for k = 1:8
        xx = squeeze(frsort(i,:,k));
        cc = [linspace(0,0.95,8)' ones(8,1) ones(8,1)];
        cc = hsv2rgb(cc);
        h = polar(linspace(0,2*pi,21),[xx xx(1)]);
        set(h,'Linewidth',2,'Color',cc(k,:));
        hold on;
    end
end
figure;


for j = 1:4
    subplot(2,2,j)
    xx = squeeze(frsort(j,:,:));
    cc = [linspace(0,0.95,20)' ones(20,1) ones(20,1)];
    cc = hsv2rgb(cc);
    for i =1:size(xx,1)
        plot(xx(i,:),'Color',cc(i,:),'linewidth',2);
        hold on;
    end
    hold on;
    plot(mean(xx),'Color',[0 0 0],'Linewidth',2);
end

return;
%  xx = size(strctDesign.m_a2bStimulusToCondition,1);
% [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd,o
% plot(strctUnit.m_afAvgFirintRate_Stimulus(151:168),strctUnit.m_afAvgFirintRate_Stimulus(1:18),'ro','Linewidth',2);
% hold on;
% plot(strctUnit.m_afAvgFirintRate_Stimulus(150+(19:38)),strctUnit.m_afAvgFirintRate_Stimulus(0+(19:38)),'bo','Linewidth',2);
% plot(strctUnit.m_afAvgFirintRate_Stimulus(150+(39:58)),strctUnit.m_afAvgFirintRate_Stimulus(0+(39:58)),'mo','Linewidth',2);
% plot(strctUnit.m_afAvgFirintRate_Stimulus(150+(59:78)),strctUnit.m_afAvgFirintRate_Stimulus(0+(59:78)),'co','Linewidth',2);
% plot(0:max(strctUnit.m_afAvgFirintRate_Stimulus),0:max(strctUnit.m_afAvgFirintRate_Stimulus),'k--');
% axis square
% tt = max(strctUnit.m_afAvgFirintRate_Stimulus);
%
% yy = strctUnit.m_afAvgFirintRate_Stimulus(1:78) - strctUnit.m_afAvgFirintRate_Stimulus(150+(1:78));
% [junk kk] = sort(yy);
%
%
% % for i = 1:length(kk);
% %
% % im = imread(strctDesign.m_astrctMedia(kk(end-i+1)).m_acFileNames{1});
% % subplot(2,2,1);
% % imshow(im);
% % im = imread(strctDesign.m_astrctMedia(150+kk(end-i+1)).m_acFileNames{1});
% % subplot(2,2,2);
% % imshow(im);
% % subplot(2,1,2);
% %  plot(-200:450,strctUnit.m_a2fAvgFirintRate_Stimulus(kk(end-i+1),1:651),'r-','linewidth',2);
% %         hold on;
% %         plot(-200:450,strctUnit.m_a2fAvgFirintRate_Stimulus(150+kk(end-i+1),1:651),'k-','linewidth',2);pause;
% %         hold off;
% % end
%
% figure;
% for i = 1:5
%     subplot(2,3,i);
%     if i < 5
%         plot(-200:800,strctUnit.m_a2fAvgLFPCategory(i,1:1001),'r-','linewidth',2);
%         hold on;
%         plot(-200:800,strctUnit.m_a2fAvgLFPCategory(i+8,1:1001),'k-','linewidth',2);
%         Titlename = strctUnit.m_acConditionNames{i};
%         h = title(Titlename(6:end));
%         set(h,'fontsize',14);
%     else
%         plot(-200:800,strctUnit.m_a2fAvgLFPCategory(5,1:1001),'k-','linewidth',2);
%         hold on
%         plot(-200:800,strctUnit.m_a2fAvgLFPCategory(8,1:1001),'-','Color',[0.7 0.7 0.7],'linewidth',2);
%         plot(-200:800,strctUnit.m_a2fAvgLFPCategory(6,1:1001),'r-','linewidth',2);
%         plot(-200:800,strctUnit.m_a2fAvgLFPCategory(7,1:1001),'b-','linewidth',2);
%         h = title('Grating');
%         set(h,'fontsize',14);
%
%     end
%     box off
% set(gca,'linewidth',2);
% end
%
%
% figure;
% for i = 1:5
%     subplot(2,3,i);
%     if i < 5
%         plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(i,1:651),'r-','linewidth',2);
%         hold on;
%         plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(i+8,1:651),'k-','linewidth',2);
%         Titlename = strctUnit.m_acConditionNames{i};
%         h = title(Titlename(6:end));
%         set(h,'fontsize',14);
%     else
%         plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(5,1:651),'k-','linewidth',2);
%         hold on
%         plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(8,1:651),'-','Color',[0.7 0.7 0.7],'linewidth',2);
%         plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(6,1:651),'r-','linewidth',2);
%         plot(-200:450,strctUnit.m_a2fAvgFirintRate_Category(7,1:651),'b-','linewidth',2);
%         h = title('Grating');
%         set(h,'fontsize',14);
%
%     end
%     box off
% set(gca,'linewidth',2);
% end
%
% return;
%
