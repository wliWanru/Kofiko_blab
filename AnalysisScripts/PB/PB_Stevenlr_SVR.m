function PB_StevenUpDown_SVR
load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
load('D:\PB\StevenUpDown\Houdini_AL_population.mat');
populationresult = finalresult.populationresult;
for i = 1:length(populationresult)
    fr(:,:,i) = populationresult{i}.fr(:,:);
end
for i = 1:size(fr,3)
    tt = fr(:,:,i);
    tt = tt/mean(tt(:));
    frall(:,:,i) = tt;
end
resp = zeros(size(frall,1),4,size(frall,3));
resp(:,1,:) = frall(:,1,:);
resp(:,2,:) = frall(end:-1:1,1,:);
resp(:,3,:) = frall(:,3,:);
resp(:,4,:) = frall(end:-1:1,2,:);


for cond = 1:4 % 1 both 2 down 3 up
    
    bothdata = resp(:,cond,:); resp = squeeze(resp);
    pred_pp_own = svm_reg(pp,bothdata,100,1:6);
    pred_pp_own_all(:,:,cond) = pred_pp_own;
    
    %     for i = 1:6
    %         subplot(4,6,(cond-1)*6+i);
    %         plot((pred_pp_own(:,i)),(pp(:,i)),'.');
    %         tt = corrcoef(pred_pp_own(:,i),pp(:,i));
    %         title(['Correlation:' num2str(tt(1,2))]);
    %         tmax = max(([pred_pp_own(:,i);pp(:,i)]));
    %         tmin = min(([pred_pp_own(:,i);pp(:,i)]));
    %         hold on;
    %         plot(tmin-1:tmax+1:tmin-1:tmax+1,'r-','linewidth',2);
    %         axis([tmin tmax tmin tmax]);
    %         axis square;
    %         box off
    %     end
end
save('D:\PB\StevenUpDown\Houdini_SVR_own.mat','pred_pp_own_all');
% figure;
% load('D:\PB\StevenUpDown\Rocco_SVR_own.mat');
% for cond = 1:4
%     pred_pp_own = pred_pp_own_all(:,:,cond);
%     
%     for i = 1:6
%         subplot(4,6,(cond-1)*6+i);
%         plot((pred_pp_own(:,i)),(pp(:,i)),'.');
%         tt = corrcoef(pred_pp_own(:,i),pp(:,i));
%         title(['Correlation:' num2str(tt(1,2))]);
%         tmax = max(([pred_pp_own(:,i);pp(:,i)]));
%         tmin = min(([pred_pp_own(:,i);pp(:,i)]));
%         hold on;
%         plot(tmin-1:tmax+1,tmin-1:tmax+1,'r-','linewidth',2);
%         axis([tmin tmax tmin tmax]);
%         axis square;
%         box off
%     end
% end

for traindata = 1:4
    for testdata = 1:4
        if ~(traindata == testdata)
            trainresp = resp(:,traindata,:); trainresp = squeeze(trainresp);
            testresp = resp(:,testdata,:); testresp = squeeze(testresp);
            plab = svm_reg_tran(pp(:,1:6),trainresp,testresp);
            pred_pp_between_all(:,:,traindata,testdata) = plab;
        end
    end
end
save('D:\PB\StevenUpDown\Houdini_SVR_between.mat','pred_pp_between_all');
for t1 = 1:4
    figure;
    for cond = 1:4
        pred_pp_own = pred_pp_between_all(:,:,t1,cond);
        
        for i = 1:6
            subplot(4,6,(cond-1)*6+i);
            plot((pred_pp_own(:,i)),(pp(:,i)),'.');
            tt = corrcoef(pred_pp_own(:,i),pp(:,i));
            title(['Correlation:' num2str(tt(1,2))]);
            tmax = max(([pred_pp_own(:,i);pp(:,i)]));
            tmin = min(([pred_pp_own(:,i);pp(:,i)]));
            hold on;
            plot(tmin-1:tmax+1,tmin-1:tmax+1,'r-','linewidth',2);
            axis([tmin tmax tmin tmax]);
            axis square;
            box off
        end
    end
end

% load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
% load('D:\PB\StevenUpDown\Rocco_population.mat');
% populationresult = finalresult.populationresult;
% for i = 1:length(populationresult)
%     fr(:,:,i) = populationresult{i}.fr(:,:);
% end
% for i = 1:size(fr,3)
%     tt = fr(:,:,i);
%     tt = tt/mean(tt(:));
%     frall(:,:,i) = tt;
% end

% for tranlist = 1:3
%     figure;
%     for testlist = 1:3
%         traindata = frall(:,tranlist,:); bothdata = squeeze(bothdata);
%         testdata = frall(:,testlist,:); updata = squeeze(updata);
%         %pp = ztrans(pp);
%         pc_stevenParameter_bothFace = svm_reg_tran(pp(:,1:6),updata,bothdata);
%
%         figure;
%         for i = 1:6
%             subplot(3,4,i);
%             plot((pc_stevenParameter_bothFace(:,i)),(pp(:,i)),'.');
%             tt = corrcoef(pc_stevenParameter_bothFace(:,i),pp(:,i));
%             title(['Correlation:' num2str(tt(1,2))]);
%             tmax = max(([pc_stevenParameter_bothFace(:,i);pp(:,i)]));
%             tmin = min(([pc_stevenParameter_bothFace(:,i);pp(:,i)]));
%             axis([tmin tmax tmin tmax]);
%             axis square;
%         end
%
%
%         downdata = frall(:,2,:); downdata = squeeze(downdata); downdata = downdata(end:-1:1,:);
%         updata = frall(:,3,:); updata = squeeze(updata);
%         %pp = ztrans(pp);
%         pc_stevenParameter_bothFace = svm_reg_tran(pp(:,1:6),downdata,updata);
%
%         figure;
%         for i = 1:6
%             subplot(3,4,i);
%             plot((pc_stevenParameter_bothFace(:,i)),(pp(:,i)),'.');
%             tt = corrcoef(pc_stevenParameter_bothFace(:,i),pp(:,i));
%             title(['Correlation:' num2str(tt(1,2))]);
%             tmax = max(([pc_stevenParameter_bothFace(:,i);pp(:,i)]));
%             tmin = min(([pc_stevenParameter_bothFace(:,i);pp(:,i)]));
%             axis([tmin tmax tmin tmax]);
%             axis square;
%         end
%     end
% end