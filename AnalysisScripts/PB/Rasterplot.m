function im = Rasterplot(m_a2bRaster,stimulusindex,displayindex,trialnumber);
for i = 1:length(displayindex)
    ii = displayindex(i);
    x(i) = length(find(stimulusindex == ii));
end
im = zeros(min(x)*length(displayindex),size(m_a2bRaster,2));
for i = 1:length(displayindex)
    ii = displayindex(i);
    index = find(stimulusindex == ii);
    index = index(1:min(x));
    rr(:,i) = sum(m_a2bRaster(index,251:350),2);
end

meanrr = mean(rr);

number = 10;

tt = abs(rr(:,1)-meanrr(1)); [junk i1] = sort(tt); fi(:,1) = i1(1:number);
tt = abs(rr(:,2)-meanrr(2)); [junk i2] = sort(tt); fi(:,2) = i2(1:number);
%tt = abs(rr(:,3)- (meanrr(1)+meanrr(2))/2); [junk i3] = sort(tt); fi(:,3) = i3(1:number);
tt = abs(rr(:,3)- meanrr(3)); [junk i3] = sort(tt); fi(:,3) = i3(1:number);
im = zeros(number*length(displayindex),size(m_a2bRaster,2));
for i = 1:length(displayindex)
    ii = displayindex(i);
    index = find(stimulusindex == ii);
    index = index(fi(:,i));
    im((i-1)*number+1:i*number,:) = m_a2bRaster(index,:);
end