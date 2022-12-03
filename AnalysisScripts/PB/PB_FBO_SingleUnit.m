function output = PB_FBO_SingleUnit(subjID,experiment,day,unitnumber,stimarea)



close all;
strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'FBO');
if isempty(strctUnit)
    strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'FBO_new');
end

if isempty(strctUnit)
    strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'FBO_new3');
end


%strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
load fboxml.mat
tt = strctDesign.m_acMediaName;
if nargin < 5
stimarea = [60 220];
end
xx = max(strctUnit.m_aiStimulusIndex);
% [fr, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] ...
%     = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, stimarea(1), stimarea(2),-50,25);
[fr, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] ...
    = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, stimarea(1), stimarea(2));
newindex = 1:length(tt);
for i = 1:length(tt)
    fn = tt{i};
    zz = find(fn == '_');
    t1 = fn(zz(2)+1);
    if strcmp(t1,'l')
        zz = find(fn == '_');
        p1 = fn(1:zz(1)-1);
        p2 = fn(zz(1)+1:zz(2)-1);
        p3 = str2num(fn(zz(2)+2:(zz(2)+3)));
        newfn = [p2 '_' p1 '_l' num2str(100-p3) '_r' num2str(p3)];
        
        for j = 1:length(tt);
            if strcmp(newfn,tt{j});
                newindex(i) = j;
            end
        end
    end
end

if strcmp('Fez',subjID)
    fr = fr(newindex);
end


        


for bc = 1:2
    figure;
    for i = 1:3
        switch i
            case 1
                ss = {'Face','Object'}; cc = {'ro-','bo-'};
            case 2
                ss = {'Face','Body'};  cc = {'ro-','mo-'};
            case 3
                ss = {'Body','Object'}; cc = {'mo-','bo-'};
        end
        for j = 1:2
            for k = 1:5
                if bc == 1;
                    r1 = [ss{j} '_blank_l' int2str((k-1)*20+10) '_r' int2str(90-(k-1)*20)]
                    r2 = ['blank_' ss{3-j} '_l' int2str((k-1)*20+10) '_r' int2str(90-(k-1)*20)]
                    r3 = [ss{j} '_' ss{3-j} '_l' int2str((k-1)*20+10) '_r' int2str(90-(k-1)*20)]
                    resp(k,1) = fr(find(strcmp(tt,r1)));
                    resp(k,2) = fr(find(strcmp(tt,r2)));
                    resp(k,3) = fr(find(strcmp(tt,r3)));
                else
                    r1 = [ss{j} '_blank_u' int2str((k-1)*20+10) '_d' int2str(90-(k-1)*20)];
                    r2 = ['blank_' ss{3-j} '_u' int2str((k-1)*20+10) '_d' int2str(90-(k-1)*20)];
                    r3 = [ss{j} '_' ss{3-j} '_u' int2str((k-1)*20+10) '_d' int2str(90-(k-1)*20)];
                    resp(k,1) = fr(find(strcmp(tt,r1)));
                    resp(k,2) = fr(find(strcmp(tt,r2)));
                    resp(k,3) = fr(find(strcmp(tt,r3)));
                end
            end
            
            subplot(3,2,(i-1)*2 + j)
            hold on;

            plot(10:20:90,resp(:,1),cc{j},'linewidth',2);
            plot(10:20:90,resp(:,2),cc{3-j},'linewidth',2);
            plot(10:20:90,resp(:,3),'ko-','linewidth',2);
            output(bc,i,j,:,:) = resp;
        end
    end
end