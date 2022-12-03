clear all;
load('D:\PB\TwoImageResult\Rocco_TwoImageContrast_population.mat');
populationresult = finalresult.populationresult;

for i = 1:size(populationresult,2);
    tt = populationresult(:,i);
    tt = tt/max(tt(:));
    response(:,i) = tt;
end

for i = 1:size(response,2);
    xx = response(:,i);
    