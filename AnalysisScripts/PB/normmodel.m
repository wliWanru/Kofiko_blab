function R = normmodel(x,c50,n,rr)
R = zeros(size(x,1),1);
n
ro = rr(1); rf = rr(2);
for i = 1:size(x,1)
    co = x(i,1);
    cf = x(i,2);
    R(i) = (ro*co + rf*cf)/(c50^n + (sqrt(co+cf))^n);
end