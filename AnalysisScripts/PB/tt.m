figure;

for cond = 1:2
    if cond == 1;
        load('C:\PB\StevenLR\Rocco_SVR_between.mat');
    else
        load('C:\PB\StevenUpDown\Rocco_SVR_between.mat');
    end
    load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
    
    ss = std(pp,0,1);
    mm = mean(pp,1);
    pp = zscore(pp);
    for i = 4:4
        for j = 1:2
            subplot(1,4,j+(cond-1)*2);
            plot((pred_pp_between_all(:,i,j+2,j+2)-mm(i))/ss(i),(pred_pp_between_all(:,i,j+2,j)-mm(i))/ss(i),'.')
            sl(i,j,cond) = lscov((pred_pp_between_all(:,i,j+2,j+2)-mm(i))/ss(i),(pred_pp_between_all(:,i,j+2,j)-mm(i))/ss(i))
            hold on;
            plot(-3:3,-3:3,'r-','linewidth',2);
            plot(-3:3, (-3:3)*sl(i,j,cond),'k--','linewidth',2);
            axis equal
            axis([-3 3 -3 3]);
            
            axis square;
            box off;
            set(gca,'LineWidth',1);
        end
    end
end   
    
    
figure;
for i = 1:6
    subplot(2,3,i);
    bar(1:2,sl(i,:,1));
    hold on;
    bar(4:5,sl(i,:,2));
end





figure;

for cond = 1:2
    if cond == 1;
        load('C:\PB\StevenLR\Rocco_SVR_own.mat');
    else
        load('C:\PB\StevenUpDown\Rocco_SVR_own.mat');
    end
    load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
    
    ss = std(pp,0,1);
    mm = mean(pp,1);
    pp = zscore(pp);
    for i = 2:2
        for j = 1:2
            subplot(1,4,j+(cond-1)*2);
            plot(pp(:,i),(pred_pp_own_all(:,i,j)-mm(i))/ss(i),'.');
            sl = polyfit(pp(:,i),(pred_pp_own_all(:,i,j)-mm(i))/ss(i),1);
            hold on;
            plot(-3:3,-3:3,'r-');
            plot(-3:3, (-3:3)*sl(1)+sl(2),'k--');
            axis equal
            axis([-3 3 -3 3]);
            
            axis square;
            
        end
    end
end   
    
