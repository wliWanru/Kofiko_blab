function PB_ReduceTwoImage(subjID,experiment,day,unitnumber);
strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'ReduceTwoImage');

indexmap = [1 3 8
    2 7  9
    6 4 5];

figure;
for i = 2:2
    rr= fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:9)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);
    
    im = RasterPlot(strctUnit.m_a2bRaster_Valid,strctUnit.m_aiStimulusIndexValid,indexmap(i,:));
    im = im(:,201:600);
  
    im = expandim(im,30,5);
    tt = size(im,1)/3;
    for i = 1:3
h1 = tightsubplot(3,1,i,'Spacing',0.1)
        imshow(1-im((i-1)*tt+1:i*tt,:));
    end
end

function nnim = expandim(im,s1,s2)
newim = zeros(size(im,1)*s1, size(im,2));
for i = 1:size(im,1)
    newim((i-1)*s1+1:i*s1,:) = repmat(im(i,:),s1,1);
end

nnim = zeros(size(newim,1),size(newim,2)*s2);
for i = 1:size(newim,2);
    nnim(:,(i-1)*s2+1:i*s2) = repmat(newim(:,i),1,s2);
end
