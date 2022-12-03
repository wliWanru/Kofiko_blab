function fr = PB_ClutterNew_SingleUnit(subjID,experiment,day,unitnumber,cond)

if nargin < 5
    cond = '*';
else
    cond = [cond '*'];
end

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,['TwoFace' cond]);

xx = max(strctUnit.m_aiStimulusIndex);

fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
[sc1,vsc1,rr1] = fnSpikeCountPB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, strctUnit.m_aiPeriStimulusRangeMS, 50 ,220);




strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

for i = 1:length(filename)
    fn = filename{i};
    ii = find(fn == '_');
    list(i) = str2num(fn(ii(end)+1:end));
end
list = unique(list);
list(list == 0) = [];


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
figure;
for i = 1:length(list)
    for j = 1:length(list)
        if ~(i==j)
            indexc = find(cc(:,1) == 2 & cc(:,2) == list(i) & cc(:,3) == list(j) );
            index1 = find(cc(:,1) == 2 & cc(:,2) == list(i) & cc(:,3) == 0);
            index2 = find(cc(:,1) == 2 & cc(:,2) == 0 & cc(:,3) == list(j));
            if ~isempty(indexc)
                subplot(length(list),length(list),(i-1)*4+j);
                plot(strctUnit.m_a2fAvgFirintRate_Stimulus(index1,:),'r');
                hold on;
                plot(strctUnit.m_a2fAvgFirintRate_Stimulus(index2,:),'b');
                plot(strctUnit.m_a2fAvgFirintRate_Stimulus(indexc,:),'k');
            end
        end
        axis([0 600 0 max(strctUnit.m_a2fAvgFirintRate_Stimulus(:))]);
    end
end


% figure;
% for i = 1:4
%     for j = 1:4
%         if ~(i==j)
%             indexc = find(cc(:,1) == 2 & cc(:,2) == i & cc(:,3) == j);
%             index1 = find(cc(:,1) == 2 & cc(:,2) == i & cc(:,3) == 0);
%             index2 = find(cc(:,1) == 2 & cc(:,2) == 0 & cc(:,3) == j);
%             subplot(4,4,(i-1)*4+j);
%             plot(strctUnit.m_a2fAvgFirintRate_Stimulus(index1,:),'r');
%             hold on;
%             plot(strctUnit.m_a2fAvgFirintRate_Stimulus(index2,:),'b');
%             plot(strctUnit.m_a2fAvgFirintRate_Stimulus(indexc,:),'k');
%
%         end
%         axis([0 600 0 max(strctUnit.m_a2fAvgFirintRate_Stimulus(:))]);
%     end
% end

k = 1;
for i = 1:length(list)
    for j = 1:length(list)
        if ~(i==j)
            
            indexc = find(cc(:,1) == 2 & cc(:,2) == list(i) & cc(:,3) == list(j) );
            index1 = find(cc(:,1) == 2 & cc(:,2) == list(i) & cc(:,3) == 0);
            index2 = find(cc(:,1) == 2 & cc(:,2) == 0 & cc(:,3) == list(j));
            if ~isempty(indexc)
                r(k,1) = fr(index1);
                r(k,2) = fr(index2);
                r(k,3) = fr(indexc);
                k = k + 1;
            end
        end
        
    end
end

figure;
subplot(1,2,1);
[xx junk] = sort(r(:,1));
plot(r(junk,1),'r');
hold on;
plot(r(junk,2),'b');
plot(r(junk,3),'k');
subplot(1,2,2);
[xx junk] = sort((r(:,1)-r(:,2)));
plot(r(junk,1),'r');
hold on;
plot(r(junk,2),'b');
plot(r(junk,3),'k');

figure;

for i = 1:length(list)
    for j = 1:length(list)
        if ~(i==j)
            
            indexc = find(cc(:,1) == 2 & cc(:,2) == list(i) & cc(:,3) == list(j) );
            index1 = find(cc(:,1) == 2 & cc(:,2) == list(i) & cc(:,3) == 0);
            index2 = find(cc(:,1) == 2 & cc(:,2) == 0 & cc(:,3) == list(j));
            if ~isempty(indexc)
            r1 = rr1{index1};
            r2 = rr1{index2};
            rc = rr1{indexc};
            subplot(4,4,(i-1)*4+j);
            dd = max([r1;r2;rc]);
            hist(r1,0:round(dd)+1);
            hold on;
            hist(r2,0:round(dd)+1);
            hist(rc,0:round(dd)+1);
            h = findobj(gca,'Type','patch');
            set(h(3),'Facecolor',[1 0 0],'EdgeColor','k');
            set(h(2),'Facecolor',[0 0 1],'EdgeColor','k');
            set(h(1),'Facecolor',[0 0 0],'EdgeColor','k');
            end
        end
        
    end
end

% if doplot
%     strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\TwoImageContrast\TwoImageContrast.xml', false, false);
%     for i = 1:length(strctDesign.m_astrctMedia);
%         filename{i} = strctDesign.m_astrctMedia(i).m_strName;
%     end
%
%     for i = 1:length(filename)
%         fn = filename{i};
%         xx = find(fn == '_');
%         Name1 = fn(1:xx(1)-1);
%         CondMatrix(i,1) = findcond(Name1);
%         Name2 = fn(xx(1)+1:xx(2)-1);
%         CondMatrix(i,2) = findcond(Name2);
%         CC1 = fn(xx(2)+1:xx(2)+3);
%         CondMatrix(i,3) = str2num(CC1(end-1:end));
%         CC2 = fn(xx(3)+1:xx(3)+3);
%         CondMatrix(i,4) = str2num(CC2(end-1:end));
%         if strcmpi(CC1(1),'l') && strcmpi(CC2(1),'r');
%             CondMatrix(i,5) = 1;
%         else
%             CondMatrix(i,5) = 2;
%         end
%     end
%
%     figure;
%     for i = 10:20:90
%         for j = 10:20:90
%             index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == j & CondMatrix(:,5) == 2);
%             m = (i+10)/20; n = (j+10)/20;
%             resp(m,n) = fr(index);
%         end
%     end
%
%     cc = {'ro-','go-','bo-','co-','ko-'}
%     subplot(2,3,1);
%     for i = 1:5
%         hold on;
%         plot(resp(i,:),cc{i},'linewidth',2);
%     end
%
%     subplot(2,3,4);
%     for i = 1:5
%         hold on;
%         plot(resp(:,i),cc{i},'linewidth',2);
%     end
%
%     for i = 10:20:90
%         for j = 10:20:90
%             index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == j & CondMatrix(:,5) == 1);
%             m = (i+10)/20; n = (j+10)/20;
%             resp(m,n) = fr(index);
%         end
%     end
%
%     subplot(2,3,2);
%     for i = 1:5
%         hold on;
%         plot(resp(i,:),cc{i},'linewidth',2);
%     end
%
%     subplot(2,3,5);
%     for i = 1:5
%         hold on;
%         plot(resp(:,i),cc{i},'linewidth',2);
%     end
%
%
%     for i = 10:20:90
%         for j = 10:20:90
%             index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == j & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
%             m = (i+10)/20; n = (j+10)/20;
%             resp(m,n) = fr(index);
%         end
%     end
%
%     subplot(2,3,3);
%     for i = 1:5
%         hold on;
%         plot(resp(i,:),cc{i},'linewidth',2);
%     end
%
%     subplot(2,3,6);
%     for i = 1:5
%         hold on;
%         plot(resp(:,i),cc{i},'linewidth',2);
%     end
%
%     figure;
%
%     for i = 10:20:90
%         index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 2);
%         m = (i+10)/20;
%         RR(m,1) = fr(index);
%         index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 2);
%         RR(m,2) = fr(index);
%         index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 2);
%         RR(m,3) = fr(index);
%     end
%
%     subplot(1,3,1);
%     cc = {'ko--','ro-','bo-'};
%     for j = 1:3;
%         plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
%         hold on;
%     end
%
%     for i = 10:20:90
%         index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 1);
%         m = (i+10)/20;
%         RR(m,1) = fr(index);
%         index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 1);
%         RR(m,2) = fr(index);
%         index = find(CondMatrix(:,1) == 0 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 1);
%         RR(m,3) = fr(index);
%     end
%
%     subplot(1,3,2);
%     cc = {'ko--','ro-','bo-'};
%     for j = 1:3;
%         plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
%         hold on;
%     end
%
%     for i = 10:20:90
%         index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
%         m = (i+10)/20;
%         RR(m,1) = fr(index);
%         index = find(CondMatrix(:,1) ==  0 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
%         RR(m,2) = fr(index);
%         index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
%         RR(m,3) = fr(index);
%     end
%
%
%     subplot(1,3,3);
%     cc = {'ko--','ro-','bo-'};
%     for j = 1:3;
%         plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
%         hold on;
%     end
% end
%
%
