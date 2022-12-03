if strcmpi(fn(end-2:end),'txt');
    fid = fopen(fn,'r');
    dd = fscanf(fid,'%d');
    d1 = dd(1:2:end);
    d2 = dd(2:2:end);
end

rd1 = computeResp_a2bRaster(d1,d2,1593);

c1 = strctUnit.m_a2bRaster_Valid;
c2 = strctUnit.m_aiStimulusIndexValid;

for i = 1:400
    c2i = sum(c1(:,i:i+150));
    rc1 = computeResp_a2bRaster(c2i,c2,1593);
    tt = corrcoefomitnan(rc1,rd1);
    cc(i) = tt(1,2);
end
