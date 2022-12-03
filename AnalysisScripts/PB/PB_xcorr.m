function [cc cc_control]=PB_xcorr(raster1,raster2,timewindow,trialtype);

for i = 1:max(trialtype);
    index = find(trialtype == i);
    tc1 = raster1(index,timewindow);
    tc1 = tc1'; tc1 = tc1(:);
    tc2 = raster2(index,timewindow);
    tc2 = tc2'; tc2 = tc2(:);
    cc(:,i) = xcorr(tc1-mean(tc1),tc2-mean(tc2),1600,'coeff');
    for j = 1:100
        tc_control = raster2(index,timewindow);
        tc_control = tc_control(randperm(length(index)),:);
        tc_control = tc_control';
        tc_control = tc_control(:);
        kk(:,j) = xcorr(tc1-mean(tc1),tc_control-mean(tc_control),1600,'coeff');
    end
    cc_control(:,i) = mean(kk(:,j),2);
end