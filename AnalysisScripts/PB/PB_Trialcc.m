function [cc ff1 ff2 ff ev] = trialcc(xx);
ff = zeros(length(xx),1);
for i = 1:length(xx)
    fr = xx{i};
    fr = fr(randperm(length(fr)));
    if length(fr) > 2
        f1 = fr(1:round(length(fr)/2));
        ff1(i) = mean(f1);
        f2 = fr(round(length(fr)/2)+1:end);
        ff2(i) = mean(f2);
    else
        ff1(i) = nan;
        ff2(i) = nan;
    end
    ff(i) = mean(fr);
end

[tt p q] = corrcoefomitnan(ff1,ff2);

cc = tt(1,2);

mm = isnan(ff1);
f1 = ff1(~mm);
f2 = ff2(~mm);

ev = (2*cc/(1+cc))^2;


