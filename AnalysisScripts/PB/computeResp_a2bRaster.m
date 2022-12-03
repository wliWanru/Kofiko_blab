function r = computeResp_a2bRaster(d1,d2,n);
if nargin < 3
    n = max(d2);
end

for i = 1:n
    index = find(d2 == i);
    if length(index) > 0
        r(i) = mean(d1(index));
    else
        r(i) = nan;
    end
    
end