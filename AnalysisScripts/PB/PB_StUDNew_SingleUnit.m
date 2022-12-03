function output = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'StUDNew');
xx = max(strctUnit.m_aiStimulusIndex);
fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);
fr(isnan(fr))=0;
tt = fr(1001:2000);
fr(1001:2000)=[];
fr(end+1:end+1000) = tt;

fr = reshape(fr,1000,4);



if flag == 1;
    load('\\192.168.50.15\StimulusSet\StevenUpdown\ee.mat');
    pp = ee;
else
    load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
end

figure;

subplot(1,3,1);
plot(fr(:,1),fr(:,2),'.');
[tt p] = corrcoef(fr(:,1),fr(:,2));
tt = tt(1,2);
xlabel('TwoImage');
ylabel('DownImage');
title(['Coeffiency between TwoImage and DownImage is ' sprintf('%3.3g',tt)]);

subplot(1,3,2);
plot(fr(:,1),fr(:,3),'.');
[tt p] = corrcoef(fr(:,1),fr(:,3));
tt = tt(1,2);
xlabel('TwoImage');
ylabel('UpImage');
title(['Coeffiency between TwoImage and UpImage is ' sprintf('%3.3g',tt)]);

subplot(1,3,3);
plot(fr(:,2),fr(end:-1:1,3),'.');
[tt p] = corrcoef(fr(:,2),fr(end:-1:1,3));
tt = tt(1,2);
xlabel('DownImage');
ylabel('UpImage');
title(['Coeffiency between DownImage and UpImage is ' sprintf('%3.3g',tt)]);

% subplot(2,3,4);
% plot(fr(:,1),fr(:,4),'.');
% [tt p] = corrcoef(fr(:,1),fr(:,4));
% tt = tt(1,2);
% xlabel('TwoImage');
% ylabel('MaxofUpandDown');
% title(['Coeffiency between TwoImage and Max is ' sprintf('%3.3g',tt)]);
% 
% subplot(2,3,5);
% plot(fr(:,1),fr(:,5),'.');
% [tt p] = corrcoef(fr(:,1),fr(:,5));
% tt = tt(1,2);
% xlabel('TwoImage');
% ylabel('AvgUpandDown');
% title(['Coeffiency between TwoImage and Avg is ' sprintf('%3.3g',tt)]);

for i = 1:3
    subplot(1,3,i);
    hold on
    
    plot(1:max(fr(:)),1:max(fr(:)),'r','linewidth',2)
    axis([0 max(fr(:))+1 0 max(fr(:))+1]);
    axis square;
end

figure;
set(gcf,'Position',[   430         419        1114         454]);

% pp = reshape(pp,3000,4);
% qq = sqrt(sum(pp.*pp)/1000);
% pp = pp./repmat(qq,size(pp,1),1);
% pp = reshape(pp,1000,12);

pp = ztrans(pp);

subplot(1,2,1);
for i = 1:size(pp,2)
    for j = 1:4;
        
            sta(i,j) = sum((pp(:,i).*fr(:,j)))/sum(fr(:,j));
        
        
    end
end
plot(1:6,sta(1:6,:),'.-','linewidth',2,'MarkerSize',20)
hold on;
plot(7:12,sta(7:12,:),'.-','linewidth',2,'MarkerSize',20)
%legend('TwoImage','Down','Up');
h1 = xlabel('Feature Dimension');
set(h1,'FontSize',15);
h1 = ylabel('STA');
set(h1,'FontSize',15)
box off;
set(gca,'linewidth',2);
set(gca,'fontsize',12);
subplot(1,2,2);
for i = 1:size(pp,2)
    for j = 1:4
        [tt p]= corrcoef(fr(:,j),pp(:,i));
        cc(i,j) = tt(1,2);
        pvalue(i,j) = p(1,2);
    end
end
plot(1:6,cc(1:6,:),'.-','linewidth',2,'MarkerSize',20)
hold on;
plot(7:12,cc(7:12,:),'.-','linewidth',2,'MarkerSize',20)
legend({'TwoImage','Down','Up','Center'});

% for i = 1:3
%     stavector = sta(:,i);
%     for j = 1:size(pp,1);
%         pv = pp(j,:);
%         pv = pv';
%         vl(i,j) = (dot(pv,stavector)/norm(stavector)^2);
%     end
% end
%
% % linecc = {'b','g','r'};
% % figure;
% % for i = 1:3
% %     subplot(1,3,i)
% %     [junk index] = sort(vl(i,:));
% %     for j = 1:3
% %         tt = fr(index,j);
% %         tt = reshape(tt,50,20);
% %         hold on;
% %         errorbar(1:20,mean(tt),std(tt)/sqrt(50-1),linecc{j},'linewidth',2);
% %     end
% %     hold on;
% % end
% % legend('TwoImage','Down','Up');
%
% % linecc = {'b','g','r'};
% % figure;
% % for i = 1:3
% %     subplot(1,3,i)
% %     [junk index] = sort(vl(i,:));
% %     for j = 1:3
% %         tt = fr(index,j);
% %         tt = reshape(tt,50,20);
% %         hold on;
% %         errorbar(1:20,mean(tt),std(tt)/sqrt(50-1),linecc{j},'linewidth',2);
% %     end
% %     hold on;
% % end
% % legend('TwoImage','Down','Up');
% linecc = {'b.-','g.-','r.-'};
% subplot(1,2,2)
% for i = 1:3
%     [junk index] = sort(vl(i,:));
%     tt = fr(index,i);
%     tt = reshape(tt,50,20);
%     hold on;
%     h = errorbar(1:20,mean(tt),std(tt)/sqrt(50-1),linecc{i},'linewidth',2,'MarkerSize',20);
%     % errorbar_tick(h,3);
% end
% h1 = ylabel('Firing Rate');
%
% set(h1,'FontSize',14);
% h1 = xlabel('Distance along STA dimension');
% set(h1,'FontSize',14)
% box off;
% set(gca,'linewidth',2);
% set(gca,'fontsize',12);


output.sta = sta;
output.fr = fr;
output.cc = cc;
output.pp = pvalue;

