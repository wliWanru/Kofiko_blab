function RR = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,cond)

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'TwoFace_full');

xx = max(strctUnit.m_aiStimulusIndex);

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 200);
%[sc1,vsc1,rr1] = fnSpikeCountPB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, strctUnit.m_aiPeriStimulusRangeMS, 50, 200);




strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end
for i = 1:length(filename)
    nn = filename{i};
    index = find(nn=='_');
    if strcmpi(nn(1:index(1)-1),'lr');
        cc(i,1) = 1;
    else
        cc(i,1) = 2;
    end
    cc(i,2) = str2num(nn(index(1)+1:index(2)-1));
    cc(i,3) = str2num(nn(index(2)+1:end));
end
for j = 1:2
    for i = 1:64
        if i > 32
            indexc = find(cc(:,1) == j & cc(:,2) == i & cc(:,3) == i-32);
            index1 = find(cc(:,1) == j & cc(:,2) == i & cc(:,3) == 0);
            index2 = find(cc(:,1) == j & cc(:,2) == 0 & cc(:,3) == i-32);
        else
            
            indexc = find(cc(:,1) == j & cc(:,2) == i & cc(:,3) == i+32);
            index1 = find(cc(:,1) == j & cc(:,2) == i & cc(:,3) == 0);
            index2 = find(cc(:,1) == j & cc(:,2) == 0 & cc(:,3) == i+32);
        end
        RR(i,1,j) = fr(indexc);
        RR(i,2,j) = fr(index1);
        RR(i,3,j) = fr(index2);
    end
end

    figure;

    subplot(1,2,i);
    R = squeeze(RR(:,:,i));
    [junk t1] = sort(R(:,2));
    hold on;
    plot(R(t1,1),'k--');
    plot(R(t1,2),'r-');
    plot(R(t1,3),'b-');
end
    
    
    

