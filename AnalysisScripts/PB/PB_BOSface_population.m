[rr1{1},rr2{1},rr3{1}] =  PB_BOSface_SingleUnit('141028','001');
[rr1{2},rr2{2},rr3{2}] =  PB_BOSface_SingleUnit('141028','002');
% rr(:,:,:,3) =  PB_BOSface_SingleUnit('141028','003');
[rr1{3},rr2{3},rr3{3}] =  PB_BOSface_SingleUnit('141028','006');
[rr1{4},rr2{4},rr3{4}] =  PB_BOSface_SingleUnit('141006','002');


newrr2 = rr2;
clear rr2;
for i = 1:4
    
    yy = newrr2{i};
    if i == 3
        
        yy = yy(:,2:-1:1,:);
    end
    rr2(:,:,:,i) = yy;
    
end

k = 1;

for i = 1:size(rr2,4)
    xx = rr2(:,:,:,i);
    xx = xx/max(xx(:));
    if sum(isnan(xx(:)))>1
        i
    end
    rr222(:,:,:,i) = xx;
    
end
result = mean(rr222,4);
for i = 1:size(result,1);
    subplot(3,5,i+10);
    plot(-200:400,squeeze(result(i,2,:)),'b-','LineWidth',2);
    hold on;
    plot(-200:400,squeeze(result(i,1,:)),'r-','LineWidth',2);
    box off;
    set(gca,'fontsize',12);
    set(gca,'Linewidth',2);
end

k = 1;
for i = [1 2 4]
    rr33(:,:,:,k) = rr3{i};
    k = k + 1;
end


for i = 1:size(rr33,4)
    xx = rr33(:,:,:,i);
    xx = xx/max(xx(:));
    if sum(isnan(xx(:)))>1
        i
    end
    rr333(:,:,:,i) = xx;
    
end
result = mean(rr333,4);
for i = 1:size(result,1);
    subplot(3,5,i+12);
    hold off;
    plot(-200:400,squeeze(result(i,2,:)),'r-','LineWidth',2);
    hold on;
    plot(-200:400,squeeze(result(i,1,:)),'b-','LineWidth',2);
    box off;
    set(gca,'fontsize',12);
    set(gca,'Linewidth',2);
end






for i = 1:4
    rr(:,:,:,i) = rr1{i};
end


for i = 1:size(rr,4)
    xx = rr(:,:,:,i);
    xx = xx/max(xx(:));
    if sum(isnan(xx(:)))>1
        i
    end
    newrr(:,:,:,i) = xx;
    
end



result = mean(newrr,4);
for i = 1:size(result,1);
    subplot(3,size(result,1),i+12);
    plot(-200:400,squeeze(result(i,1,:)),'b-','LineWidth',2);
    hold on;
    plot(-200:400,squeeze(result(i,2,:)),'r-','LineWidth',2);
    box off;
    set(gca,'fontsize',12);
    set(gca,'Linewidth',2);
end

