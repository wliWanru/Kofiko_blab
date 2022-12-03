function predcoef = svm_reg(coef,obdata,M,P)
if nargin < 4
    P = 1:size(coef,2);
end

if nargin < 3
    M = 100;
end

N = size(coef,1);
index = randperm(N);
[junk reind] = sort(index);
k = 1;
for j = P
    y = coef(:,j);
    x = obdata;
    y = y(index);
    x = x(index,:);
    mmy = mean(y);
    ssy = std(y);
    y = zscore(y);
    
    for i = 1:M
        mm = (i-1)/M*N+1:i/M*N;
        nn = setdiff(1:N,mm);
        model = svmtrain(y(nn),x(nn,:),['-s 4 -t 2 -n 0.5 -c 1']);
        [plab, acc, dvpe]=svmpredict(y(mm),x(mm,:),model);
        rr(:,i) = plab;
    end
    dd = reshape(rr,N,1);
    predcoef(:,k) = dd(reind)*ssy + mmy;
    k = k + 1;
end
