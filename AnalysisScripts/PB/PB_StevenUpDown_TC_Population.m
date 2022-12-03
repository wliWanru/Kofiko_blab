function finalresult = PB_TwoImage_Population
% dd = {'150214','150216'};
% Unitlist{1} = [1 2 3 4 5 8 12 14 15];
% Unitlist{2}= [3:26 28:30];

dd = {'150413','150415','150421','150424'};
Unitlist{1} = [1:6 9 10 14 16 17:20 23];
Unitlist{2} = [5 7 13 21 22 23];
Unitlist{3} = [5:7 8:10 12 13 16];
Unitlist{4} = [5 7 8 9 10 11 20 23 24 25 28 29];


Subject = 'Rocco';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' Subject '\test\' ExpDate '\Processed\SingleUnitDataEntries\'];
        xx = dir([Datafolder '*.mat']);
        for j = 1:length(xx)
            fn = xx(j).name;
            tt = find(fn == '_');
            unitnumber(j) = str2num(fn(tt(8)+1:tt(9)-1));
        end
        unitnumber = unique(unitnumber);
    end
    for j = 1:length(unitnumber)
        close all;
        
        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]
        output = PB_StevenUpDown_TC_SingleUnit(Subject,'Test',ExpDate,unitstr)
        populationresult{k} = output;
        dataentry_date{k} = dd{i};
        dataentry_unitnumber{k} = unitstr;
        k = k + 1;
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\StevenUpDown\Rocco_TC_population.mat', 'finalresult');

return;

load('D:\PB\StevenUpDown\Rocco_population.mat');
populationresult = finalresult.populationresult;
for i = 1:length(populationresult)
    fr(:,:,i) = populationresult{i}.fr(:,:);
end

for i = 1:size(fr,3)
    tt = fr(:,:,i);
    tt = tt/mean(tt(:));
    frall(:,:,i) = tt;
end

y = [ones(1000,1)*3;ones(1000,1)*2;ones(1000,1)*1];
x = reshape(frall,size(frall,1)*size(frall,2),size(frall,3));

N = length(y);
index = randperm(N);
y = y(index);
x = x(index,:);

for i = 1:10
    mm = (i-1)/10*N+1:i/10*N;
    nn = setdiff(1:N,mm);
    model = svmtrain(y(nn),x(nn,:));
    [plab, acc, dvpe]=svmpredict(y(mm),x(mm,:),model)
    plaball(:,i) = plab
    accu(i) = acc(1);
end

load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
load('D:\PB\StevenUpDown\Rocco_population.mat');
populationresult = finalresult.populationresult;
for cond = 1:3 % 1 both 2 down 3 up
    switch cond
        case 1
            figure;
            M = 1:12;
        case 2
            figure;
            M = 6:12;
        case 3
            M = 1:6;
    end
    
    for i = 1:length(populationresult)
        fr(:,:,i) = populationresult{i}.fr(:,:);
    end
    for i = 1:size(fr,3)
        tt = fr(:,:,i);
        tt = tt/mean(tt(:));
        frall(:,:,i) = tt;
    end
    
    bothdata = frall(:,cond,:); bothdata = squeeze(bothdata);
    %pp = ztrans(pp);
    pc_stevenParameter_bothFace = svm_reg(pp,bothdata,100);
    
    figure;
    
    for i = M
        subplot(2,6,i);
        plot((pc_stevenParameter_bothFace(:,i)),(pp(:,i)),'.');
        tt = corrcoef(pc_stevenParameter_bothFace(:,i),pp(:,i));
        title(['Correlation:' num2str(tt(1,2))]);
        tmax = max(([pc_stevenParameter_bothFace(:,i);pp(:,i)]));
        tmin = min(([pc_stevenParameter_bothFace(:,i);pp(:,i)]));
        %axis([tmin tmax tmin tmax]);
        axis square;
        box off
    end
end



% fr = mean(frall,3);
%
% subplot(1,3,1);
% plot(fr(:,1),fr(:,2),'.');
% [tt p] = corrcoef(fr(:,1),fr(:,2));
% tt = tt(1,2);
% xlabel('TwoImage');
% ylabel('DownImage');
% title(['Coeffiency between TwoImage and DownImage is ' sprintf('%3.3g',tt)]);
%
% subplot(1,3,2);
% plot(fr(:,1),fr(:,3),'.');
% [tt p] = corrcoef(fr(:,1),fr(:,3));
% tt = tt(1,2);
% xlabel('TwoImage');
% ylabel('UpImage');
% title(['Coeffiency between TwoImage and UpImage is ' sprintf('%3.3g',tt)]);
%
% subplot(1,3,3);
% plot(fr(:,2),fr(end:-1:1,3),'.');
% [tt p] = corrcoef(fr(:,2),fr(end:-1:1,3));
% tt = tt(1,2);
% xlabel('DownImage');
% ylabel('UpImage');
% title(['Coeffiency between DownImage and UpImage is ' sprintf('%3.3g',tt)]);
%
% for i = 1:3
%     subplot(1,3,i);
%     hold on
%
%     plot(1:max(fr(:)),1:max(fr(:)),'r','linewidth',2)
%     axis([0 max(fr(:))+1 0 max(fr(:))+1]);
%     axis square;
% end
%
% figure;
% set(gcf,'Position',[   430         419        1114         454]);
%
%
% load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
% pp = reshape(pp,3000,4);
% qq = sqrt(sum(pp.*pp)/1000);
% pp = pp./repmat(qq,size(pp,1),1);
% pp = reshape(pp,1000,12);
% figure;
% subplot(1,2,1);
% for i = 1:size(pp,2)
%     for j = 1:3
%         sta(i,j) = sum((pp(:,i).*fr(:,j)))/sum(fr(:,j));
%     end
% end
% plot(1:6,sta(1:6,:),'.-','linewidth',2,'MarkerSize',20)
% hold on;
% plot(7:12,sta(7:12,:),'.-','linewidth',2,'MarkerSize',20)
% %legend('TwoImage','Down','Up');
% h1 = xlabel('Feature Dimension');
% set(h1,'FontSize',15);
% h1 = ylabel('STA');
% set(h1,'FontSize',15)
% box off;
% set(gca,'linewidth',2);
% set(gca,'fontsize',12);
% subplot(1,2,2);
% for i = 1:size(pp,2)
%     for j = 1:3
%         [tt p]= corrcoef(fr(:,j),pp(:,i));
%         cc(i,j) = tt(1,2);
%         pvalue(i,j) = p(1,2);
%     end
% end
% plot(1:6,cc(1:6,:),'.-','linewidth',2,'MarkerSize',20)
% hold on;
% plot(7:12,cc(7:12,:),'.-','linewidth',2,'MarkerSize',20)
% legend('TwoImage','Down','Up');
