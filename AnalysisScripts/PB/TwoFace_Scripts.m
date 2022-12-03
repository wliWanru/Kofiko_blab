function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber)
%subjID = 'Rocco'; day = '150407'; experiment = 'Test'; unitnumber = '003';
% strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'StevenSingle');
% xx = max(strctUnit.m_aiStimulusIndex);
% fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);
% fr = reshape(fr,50,3);


strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'Twofaces_date07_Apr_2015_1_6_11_16_21_26_31_36_41_46');
xx = max(strctUnit.m_aiStimulusIndex);
fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220);
strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_acMediaName)
    fn{i} = strctDesign.m_acMediaName{i};
end
for i = 1:length(fn)
    filename = fn{i};
    if length(find(filename == '_')) == 1;
        tt = find(filename == '_');
        position = filename(tt+1:end);
        if strcmp(position,'center');
            cond(i,3) = 2;
            cond(i,1) = str2num(filename(1:tt-1));
            cond(i,2) = 0;
        elseif strcmp(position,'left')'
            cond(i,3) = 1;
            cond(i,1) = str2num(filename(1:tt-1));
            cond(i,2) = 0;
        elseif strcmp(position,'right')
            cond(i,3) = 1;
            cond(i,2) = str2num(filename(1:tt-1));
            cond(i,1) = 0;
        end
    elseif length(find(filename == '_')) == 2
        tt = find(filename=='_');
        cc = filename(tt(end)+1:end);
        if strcmp(cc,'ts');
            cond(i,1) = str2num(filename(1:tt(1)-1));
            cond(i,2) = str2num(filename(tt(1)+1:tt(2)-1));
            cond(i,3) = 2;
        elseif strcmp(cc,'lr');
            cond(i,1) = str2num(filename(1:tt(1)-1));
            cond(i,2) = str2num(filename(tt(1)+1:tt(2)-1));
            cond(i,3) = 1;
        end
    end
end

figure;
tt = find(cond(:,2)==0 & cond(:,3)==2);
imlist = cond(tt,1);
rr = zeros(length(imlist),length(imlist),3)
for i = 1:length(imlist)
    for j = i+1:length(imlist)
        f1 = imlist(i);
        f2 = imlist(j);
        i1 = find(cond(:,1) == f1 & cond(:,2) == 0 & cond(:,3) == 2);
        i2 =  find(cond(:,1) == f2 & cond(:,2) == 0 & cond(:,3) == 2);
        i3 =  find(cond(:,1) == f1 & cond(:,2) == f2 & cond(:,3) == 2);
        rr(i,j,1) = fr(i1); rr(i,j,2) = fr(i2); rr(i,j,3) = fr(i3);
    end
end
allrr(1,:,:,:) = rr;
subplot(2,2,1);
hold on;
tt = reshape(rr,length(imlist)^2,3);
index = find(~(sum(tt,2)==0));
[junk mm] = sort(tt(index,1));
index = index(mm);
plot(tt(index,1),'r','linewidth',2);
plot(tt(index,2),'b','linewidth',2);
plot(tt(index,3),'k--','linewidth',2);
subplot(2,2,2);
hold on;
tt = reshape(rr,length(imlist)^2,3);
index = find(~(sum(tt,2)==0));
[junk mm] = sort(tt(index,2));
index = index(mm);
plot(tt(index,1),'r-','linewidth',2);
plot(tt(index,2),'b','linewidth',2);
plot(tt(index,3),'k--','linewidth',2);
m1 = lscov([tt(index,1) tt(index,2)],tt(index,3));
title(['R_T_w_o_F_a_c_e = ' sprintf('%3.3f',m1(1)) 'R_f_a_c_e_1+' sprintf('%3.3f',m1(2)) 'R_f_a_c_e_2']);
%plot(tt(index,1)*m1(1)+tt(index,2)*m1(2),'k--');
hold on;
for i = 1:length(imlist)
    for j = 1:length(imlist)
        if ~(i == j)
            f1 = imlist(i);
            f2 = imlist(j);
            i1 = find(cond(:,1) == f1 & cond(:,2) == 0 & cond(:,3) == 1);
            i2 =  find(cond(:,1) == 0 & cond(:,2) == f2 & cond(:,3) == 1);
            i3 =  find(cond(:,1) == f1 & cond(:,2) == f2 & cond(:,3) == 1);
            [i1 i2 i3]
            pause
            rr(i,j,1) = fr(i1); rr(i,j,2) = fr(i2); rr(i,j,3) = fr(i3);
        end
    end
end
allrr(2,:,:,:) = rr;
subplot(2,2,3);
hold on;
tt = reshape(rr,length(imlist)^2,3);
index = find(~(sum(tt,2)==0));
[junk mm] = sort(tt(index,1));
index = index(mm);
plot(tt(index,1),'r','linewidth',2);
plot(tt(index,2),'b','linewidth',2);
plot(tt(index,3),'k--','linewidth',2);
subplot(2,2,4);
hold on;
tt = reshape(rr,length(imlist)^2,3);
index = find(~(sum(tt,2)==0));
[junk mm] = sort(tt(index,2));
index = index(mm);
plot(tt(index,1),'r','linewidth',2);
plot(tt(index,2),'b','linewidth',2);
plot(tt(index,3),'k--','linewidth',2);
dsmx = [tt(index,1) tt(index,2)];
resp = tt(index,3);
m2 = lscov([tt(index,1) tt(index,2)],tt(index,3));
title(['R_T_w_o_F_a_c_e = ' sprintf('%3.3f',m2(1)) 'R_l_e_f_t+' sprintf('%3.3f',m2(2)) 'R_r_i_g_h_t']);
%plot(tt(index,1)*m2(1)+tt(index,2)*m2(2),'k--');










set(gcf,'position',[ 680   485   806   493]);

