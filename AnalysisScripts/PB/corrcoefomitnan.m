function  [tt p q] = corrcoefomitnan(x,y)
if size(x,2) == 1
else
    x = x';
end
if size(y,2) == 1
else
    y = y';
end


t1 = find(isnan(x));
t2 = find(isnan(y));

tnan = unique([t1;t2]);
x(tnan) = [];
y(tnan) = [];
[tt p q] = corrcoef(x,y);

