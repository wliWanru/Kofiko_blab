
function im = faceRF(strctUnit)

%strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
[avgFiring, avgFiringStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 20, 150);
%avgFiring = strctUnit.m_afAvgFirintRate_Stimulus;
for i = 1:33
    xx(i,:) = avgFiring((i-1)*3+1:i*3);
end
mxx = xx(:,3);

[x y] = meshgrid(-150:150,-150:150);
[th rho] = cart2pol(x,y);
th = th - pi*13/8;
th(th<-pi) = th(th<-pi) + 2*pi;
th = - th;
th = th + pi;
im = zeros(size(rho));
im2 = im;
im(rho<30) = mxx(1);
k = 1;
for i = 1:4
    for j = 1:8
        mask = rho>i*30 & rho<(i+1) * 30 & th>(j-1)*pi/4 & th<j*pi/4;
        im(mask)  = mxx((i-1)*4+j+1);
        im2(mask) = k;
        k = k + 1;
    end
end
