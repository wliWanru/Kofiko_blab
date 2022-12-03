function [weightedim xx]  = staimage(weight,imall);

weight_im = repmat(weight,[1,size(imall,2),size(imall,3)]);
xx = squeeze(sum((weight_im.*imall)));
weightedim = xx/sum(weight);
