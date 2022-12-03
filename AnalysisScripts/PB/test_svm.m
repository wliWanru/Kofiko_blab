clear rr
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

% y = [ones(1000,1)*3;ones(1000,1)*2;ones(1000,1)*1];
% x = reshape(frall,size(frall,1)*size(frall,2),size(frall,3));
% 
% N = length(y);
% index = randperm(N);
% y = y(index);
% x = x(index,:);
% 
% for i = 1:10
%     mm = (i-1)/10*N+1:i/10*N;
%     nn = setdiff(1:N,mm);
%     model = svmtrain(y(nn),x(nn,:));
%     [plab, acc, dvpe]=svmpredict(y(mm),x(mm,:),model)
%     rr(:,i,1) = plab;
%     rr(:,i,2) = y(mm);
% end

load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
index = randperm(N);
N = 1000;
figure;
pp = ztrans(pp);
M = 100;
for j = 1:6
    y = pp(:,6+j);
    x = squeeze(frall(:,2,:));
    y = y(index);
    x = x(index,:);
    
    for i = 1:M
        mm = (i-1)/M*N+1:i/M*N;
        nn = setdiff(1:N,mm);
        model = svmtrain(y(nn),x(nn,:),['-s 4 -t 2 -n 0.5 -c 1']);
        [plab, acc, dvpe]=svmpredict(y(mm),x(mm,:),model);
        rr(:,i,1) = plab;
        rr(:,i,2) = y(mm);
    end
    dd = reshape(rr,1000,2);
    subplot(2,3,j)
    plot(dd(:,1),dd(:,2),'.');
        hold on;
plot(-4:4,-4:4,'r-','linewidth',2);
    axis([-3.5 3.5 -3.5 3.5]);
    
    axis square;
end




load('\\192.168.50.15\StimulusSet\StevenUpdown\pp.mat');
index = randperm(N);
N = 1000;
figure;
pp = ztrans(pp);
M = 100;
for j = 1:6
    y = pp(:,6+j);
    x = squeeze(frall(:,2,:));
    y = y(index);
    x = x(index,:);
    
    for i = 1:M
        mm = (i-1)/M*N+1:i/M*N;
        nn = setdiff(1:N,mm);
        model = svmtrain(y(nn),x(nn,:),['-s 4 -t 2 -n 0.5 -c 1']);
        [plab, acc, dvpe]=svmpredict(y(mm),x(mm,:),model);
        rr(:,i,1) = plab;
        rr(:,i,2) = y(mm);
    end
    dd = reshape(rr,1000,2);
    subplot(2,3,j)
    plot(dd(:,1),dd(:,2),'.');
        hold on;
plot(-4:4,-4:4,'r-','linewidth',2);
    axis([-3.5 3.5 -3.5 3.5]);
    
    axis square;
end

