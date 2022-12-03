clear all;
close all;

[1 2 7 9 11 12 15 16 18 19 20 21]

load('C:\PB\TwoImageResult\Fez_FBO_population.mat');
populationresult1 = finalresult.populationresult;
%populationresult1(1,:,:,:,:,:) = populationresult1(1,:,2:-1:1,:,:,:);
load('C:\PB\TwoImageResult\Alfie_FBO_population.mat');
populationresult2 = finalresult.populationresult;
populationresult2 = populationresult2(:,:,:,:,:,[1:6 10:12]);
populationresult3  = cat(6,populationresult1(:,:,:,:,:,[11 12 15 16 18 19 20 21 23 24 25]),populationresult2);
populationresult4 =  cat(6,populationresult1(:,:,:,:,:,[11 12 15 16 18 19 20 21]),populationresult2);

for i = 1:size(populationresult3,6)%[1:6 10:12]
    tt = populationresult3(:,:,:,:,:,i);
    tt = tt/mean(tt(:));
    response1(:,:,:,:,:,i) = tt;
end


rr1 = mean(response1,6);
sd1 = std(response1,0,6)/sqrt(size(response1,6));


for i = 1:size(populationresult4,6)%[1:6 10:12]
    tt = populationresult4(:,:,:,:,:,i);
    tt = tt/mean(tt(:));
    response2(:,:,:,:,:,i) = tt;
end


rr2 = mean(response2,6);
sd2 = std(response2,0,6)/sqrt(size(response2,6));

rr(1,:,:,:,:) = rr1(1,:,:,:,:);
rr(2,:,:,:,:) = rr2(2,:,:,:,:);

sd(1,:,:,:,:) = sd1(1,:,:,:,:);
sd(2,:,:,:,:) = sd2(2,:,:,:,:);


figure;
for bc = 1:2
    for i = 2:3
        switch i
            case 1
                ss = {'Face','Object'}; cc = {'ro-','bo-'};
            case 2
                ss = {'Face','Body'};  cc = {'ro-','mo-'};
            case 3
                ss = {'Body','Object'}; cc = {'mo-','bo-'};
        end
        for j = 1:2
            resp = squeeze(rr(bc,i,j,:,:));
            se = squeeze(sd(bc,i,j,:,:));
            if i == 2 & bc == 2
                subplot(2,4,(i-2)*4 + 3 - j + (bc-1)*2);
            elseif i == 3 & bc == 1
                subplot(2,4,(i-2)*4 + 3 - j + (bc-1)*2);
            else
                subplot(2,4,(i-2)*4 +j + (bc-1)*2);
            end
            
            if (i == 2 && j == 1) || (i == 3 && j == 2)
                xa = 90:-20:10;
            else
                xa = 10:20:90;
            end
            hold on;
            %             if bc == 1;
            %                 title(['Ipsi:' ss{j} ' Contra:' ss{3-j}]);
            %             else
            %                 title(['Upper: ' ss{j} ' lower:' ss{3-j}]);
            %             end
            errorbar(xa,resp(:,1),se(:,1),cc{j},'linewidth',2);
            errorbar(xa,resp(:,2),se(:,2),cc{3-j},'linewidth',2);
            errorbar(xa,resp(:,3),se(:,3),'ko-','linewidth',2);
            set(gca,'Xtick',10:20:90)
            set(gca,'FontSize',10);
        end
    end
end

set(gcf,'Position',[669         135        1055         843]);
