[fr(:,:,1) fc(:,:,1)] = PB_OcclusionMovie_SingleUnit('Rocco','test','150226','011','21-23-51',0);
[fr(:,:,2) fc(:,:,2)] = PB_OcclusionMovie_SingleUnit('Rocco','test','150226','007','19-50-34',0);
[fr(:,:,3) fc(:,:,3)] = PB_OcclusionMovie_SingleUnit('Rocco','test','150226','008','19-50-34',0);
[fr(:,:,4) fc(:,:,4)] = PB_OcclusionMovie_SingleUnit('Rocco','test','150226','011','19-50-34',0);
[fr(:,:,5) fc(:,:,5)] = PB_OcclusionMovie_SingleUnit('Rocco','test','150226','008','21-23-51',0);

oldfr = fr;
oldfc = fc;

for i = 1:size(fr,3);
    tt = fr(:,:,i);
    tt = tt/max(tt(:));
    fr(:,:,i) = tt;
end

for i = 1:size(fc,3);
    tt = fc(:,:,i);
    tt = tt/max(tt(:));
    fc(:,:,i) = tt;
end

fr = mean(fr,3);
fc = mean(fc,3);

h1=figure;
subplot(2,1,1)
hold on;
plot(-200:900,fc(1,:),'b-','linewidth',2);
plot(-200:900,fc(2,:),'r-','linewidth',2);
title('AvgResponse');
for i = 1:4
    subplot(4,2,4+i);
    hold on;
    plot(-200:900,fr((i-1)*2+1,:),'b-','linewidth',2);
    plot(-200:900,fr((i-1)*2+2,:),'r-','linewidth',2);
    title(['Face-' int2str(i)]);
end


[junk,junk,lfpc(:,:,1),lfpr(:,:,1)] = PB_OcclusionMovie_SingleUnit('Rocco','test','150226','011','19-50-34',0);
[junk,junk,lfpc(:,:,2),lfpr(:,:,2)] = PB_OcclusionMovie_SingleUnit('Rocco','test','150226','008','21-23-51',0);

h2=figure;
subplot(2,1,1)
hold on;
plot(-200:900,lfpc(1,:),'b-','linewidth',2);
plot(-200:900,lfpc(2,:),'r-','linewidth',2);
title('AvgResponse');
for i = 1:4
    subplot(4,2,4+i);
    hold on;
    plot(-200:900,lfpr((i-1)*2+1,:),'b-','linewidth',2);
    plot(-200:900,lfpr((i-1)*2+2,:),'r-','linewidth',2);
    title(['Face-' int2str(i)]);
end
