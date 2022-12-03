%save('D:\PB\TwoImageResult\Rocco_population.mat', 'finalresult');
load('D:\PB\TwoImageResult\Rocco_population.mat');
r1 = finalresult.populationresult;
load('D:\PB\TwoImageResult\OZ_population.mat');
 r2 = finalresult.populationresult;
 load('D:\PB\TwoImageResult\Houdini_AL_population.mat');
r3 = finalresult.populationresult;
 %populationresult = cat(4,r1,r2);
 populationresult = r3;
for i = 1:size(populationresult,4);
    tt = populationresult(:,:,:,i);
    tt = tt/max(tt(:));
    response(:,:,:,i) = tt;
end
%response = populationresult;
figure;


rr = reshape(response,45,size(response,4));
[coefs,scores,variances,t2] = princomp((rr));
pc1 = scores(:,1);
pc1 = reshape(pc1,3,3,5);
cc = {'ko--','ro-','bo-'};

for k = 1:3
    pc1 = scores(:,k);
    pc1 = reshape(pc1,3,3,5);
    for i = 1:3
        subplot(3,3,(k-1)*3+i);
        for j = 1:3;
            plot(10:20:90,squeeze(pc1(i,j,:)),cc{j},'linewidth',2);
            hold on;
        end
        box off
    end
end

figure;


for i = 1:size(populationresult,4);
    tt = populationresult(:,:,:,i);
    tt = tt/max(tt(:));
    response(:,:,:,i) = tt;
end

response = mean(response,4);
cc = {'ko--','ro-','bo-'};

for i = 1:3
    subplot(1,3,i);
    for j = 1:3;
        plot(10:20:90,squeeze(response(i,j,:)),cc{j},'linewidth',2);
        hold on;
    end
    box off
end

    


