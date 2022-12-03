load('D:\PB\TwoImageResult\result_0912.mat');

result = finalresult.populationresult;

for i = 1:size(result,4);
    rr = squeeze(result(2:3,2,:,i));
    tt = mean(rr,2);
    lr_ratio(i) = log10(tt(1)/tt(2));
    xx(i) = (tt(1)-tt(2))/(tt(1)+tt(2))
end
% h = hist(xx,20,'FaceColor','r','EdgeColor','w');
%set(h,'FaceColor','r','EdgeColor','w')
[junk kk] = sort(xx);

groupnumber = 3;
group_mem = floor(size(result,4)/groupnumber);
for group = 1:groupnumber;
    pr = result(:,:,:,kk((group-1)*group_mem+1:group*group_mem))
    for i = 1:size(pr,4);
        tt = pr(:,:,:,i);
        tt = tt/max(tt(:));
        response(:,:,:,i) = tt;
    end
    
    response = mean(response,4);
    cc = {'ko--','ro-','bo-'};
    
    for i = 1:3
        subplot(groupnumber,3,(group-1)*3+i);
        for j = 1:3;
            plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
            hold on;
        end
        box off
        axis([0 100 0 1]);
    set(gca,'linewidth',2);
    set(gca,'fontsize',12);
    end
    
end
