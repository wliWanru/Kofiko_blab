function output = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';


strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'Stevenlr');
if isempty(strctUnit)
    strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'Stevenlr_withobj');
end


xx = max(strctUnit.m_aiStimulusIndex);
tw = 100;
load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
pp = ztrans(pp);

for st = 1:10:400
    
    
    fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, st-tw/2+1, st+tw/2);
    fr(isnan(fr))=0;
    
     fr = fr(1:3000);
     fr = reshape(fr,1000,3);
   
    for i = 1:size(pp,2)
        for j = 1:3;
            
            sta(i,j,(st+9)/10) = sum((pp(:,i).*fr(:,j)))/sum(fr(:,j));
            
            
        end
    end
    tc(:,:,(st+9)/10) = fr;
%     plot(1:6,sta(1:6,:),'.-','linewidth',2,'MarkerSize',20)
%     hold on;
%     plot(7:12,sta(7:12,:),'.-','linewidth',2,'MarkerSize',20)
%     %legend('TwoImage','Down','Up');
%     h1 = xlabel('Feature Dimension');
%     set(h1,'FontSize',15);
%     h1 = ylabel('STA');
%     set(h1,'FontSize',15)
%     box off;
%     set(gca,'linewidth',2);
%     set(gca,'fontsize',12);
%     subplot(1,2,2);
%     for i = 1:size(pp,2)
%         for j = 1:3
%             [tt p]= corrcoef(fr(:,j),pp(:,i));
%             cc(i,j) = tt(1,2);
%             pvalue(i,j) = p(1,2);
%         end
%     end
%     plot(1:6,cc(1:6,:),'.-','linewidth',2,'MarkerSize',20)
%     hold on;
%     plot(7:12,cc(7:12,:),'.-','linewidth',2,'MarkerSize',20)
%     legend({'TwoImage','Down','Up','Max','AVG'});
%     
%     for i = 1:3
%         stavector = sta(:,i);
%         for j = 1:size(pp,1);
%             pv = pp(j,:);
%             pv = pv';
%             vl(i,j) = (dot(pv,stavector)/norm(stavector)^2);
%         end
%     end
    
    % linecc = {'b','g','r'};
    % figure;
    % for i = 1:3
    %     subplot(1,3,i)
    %     [junk index] = sort(vl(i,:));
    %     for j = 1:3
    %         tt = fr(index,j);
    %         tt = reshape(tt,50,20);
    %         hold on;
    %         errorbar(1:20,mean(tt),std(tt)/sqrt(50-1),linecc{j},'linewidth',2);
    %     end
    %     hold on;
    % end
    % legend('TwoImage','Down','Up');
    
    % linecc = {'b','g','r'};
    % figure;
    % for i = 1:3
    %     subplot(1,3,i)
    %     [junk index] = sort(vl(i,:));
    %     for j = 1:3
    %         tt = fr(index,j);
    %         tt = reshape(tt,50,20);
    %         hold on;
    %         errorbar(1:20,mean(tt),std(tt)/sqrt(50-1),linecc{j},'linewidth',2);
    %     end
    %     hold on;
    % end
    % legend('TwoImage','Down','Up');
%     linecc = {'b.-','g.-','r.-'};
%     figure;
%     for i = 1:3
%         [junk index] = sort(vl(i,:));
%         tt = fr(index,i);
%         tt = reshape(tt,50,20);
%         hold on;
%         h = errorbar(1:20,mean(tt),std(tt)/sqrt(50-1),linecc{i},'linewidth',2,'MarkerSize',20);
%         % errorbar_tick(h,3);
%     end
%     h1 = ylabel('Firing Rate');
%     
%     linecc = {'b.-','g.-','k.-','r.-'};
%     
%     figure;
%     for i = 1:6
%         subplot(2,3,i);
%         para = pp(:,i);
%         [junk index] = sort(para);
%         for j = 1:4
%             switch j
%                 case 1
%                     frate = fr(:,1);
%                 case 2
%                     frate = fr(:,3);
%                 case 3
%                     frate = fr(end:-1:1,1);
%                 case 3
%                     frate = fr(end:-1:1,2);
%             end
%             tt = frate(index);
%             tt = reshape(tt,50,20);
%             hold on;
%             h = errorbar(1:20,mean(tt),std(tt)/sqrt(50-1),linecc{j},'linewidth',2,'MarkerSize',20);
%         end
%     end
    
    
    
    %
    % set(h1,'FontSize',14);
    % h1 = xlabel('Distance along STA dimension');
    % set(h1,'FontSize',14)
    % box off;
    % set(gca,'linewidth',2);
    % set(gca,'fontsize',12);
    
    
end
    output.sta = sta;
    output.tc = tc;
