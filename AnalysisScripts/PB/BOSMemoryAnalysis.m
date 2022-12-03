function a = BOSMemoryAUX(strctUnit)

AvgFiringRate = strctUnit.m_a2fAvgFirintRate_Stimulus;
for i = 1:4
    for j = 1:8
        if j == 1
            a(i,1:700) = AvgFiringRate((i-1)*4+j,1:700);
        else
            a(i,(j-1)*500+1+200:j*500+200) = AvgFiringRate((i-1)*4+j,201:700);
        end
    end
end

