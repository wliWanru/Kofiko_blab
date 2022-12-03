function predcoef = svm_reg(coef,traindata,testdata,P);
if nargin < 4
    P = 1:size(coef,2);
end




k = 1;
for j = P
    y = coef(:,j);
    ssy = std(y);
    mmy = mean(y);
    y = zscore(y);
    trainx = traindata;
    testx = testdata;
   
    model = svmtrain(y,trainx,['-s 4 -t 2 -n 0.5 -c 1']);
    [plab, acc, dvpe]=svmpredict(y,testx,model);
   
    predcoef(:,k) = plab*ssy + mmy;
    k = k + 1;
end
