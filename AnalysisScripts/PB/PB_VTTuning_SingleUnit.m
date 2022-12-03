function resp = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,cond)

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,['VT_Hue' int2str(cond)]);

xx = max(strctUnit.m_aiStimulusIndex);

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 200);




strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end
for i = 1:length(filename)
    nn = filename{i};
    index = find(nn=='_');
    cc(i,1) = str2num(nn(9:10));
    cc(i,2) = str2num(nn(12:13));
    
end
cc(cc==21) = - 99;
dd = cc + 10;
dd(dd>20) = dd(dd>20)-20;

for i = 1:20
    for j = 1:20
        index1 = find(cc(:,1)==i & cc(:,2) == j);
        index2 = find(cc(:,1)==j & cc(:,2) == i);
        resp(i,j) =  (fr(index1) + fr(index2))/2;
        
    end
end

for i = 1:20
    for j = 1:20
        index1 = find(dd(:,1)==i & dd(:,2) == j);
        index2 = find(dd(:,1)==j & dd(:,2) == i);
        resp2(i,j) =  (fr(index1) + fr(index2))/2;
        
    end
end


figure;
subplot(1,2,1);
imshow(imresize(resp,[200 200],'nearest'),[]);
colormap('default');

subplot(1,2,2);
imshow(imresize(resp2,[200 200],'nearest'),[]);
colormap('default');

colorbar;

