function output = OcclusionAnalysis(subjID,experiment,foldername,unitnumber1,unitnumber2)
close all;
usePB = 1;
%subjID = 'Rocco'; experiment = 'test'; foldername = '140904'; unitnumber1 = '002';unitnumber2 = '034';
matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
mat = dir([matpath '*_Unit_' unitnumber1 '_Passive_Fixation_New_.mat']);
if isempty(mat)
    strctUnit = [];
    mat = dir([matpath '*_Unit_' unitnumber1 '_Passive_Fixation_New_PB_TwoImage_*.mat']);
    if ~isempty(mat)
        strctUnit1 = load([matpath mat(1).name]);
        strctUnit1 = strctUnit1.strctUnit;
        mat = dir([matpath '*_Unit_' unitnumber2 '_Passive_Fixation_New_PB_TwoImage_*.mat']);
        strctUnit2 = load([matpath mat(1).name]);
        strctUnit2 = strctUnit2.strctUnit;
        strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit1.m_strImageListUsed, false, false);
        for i = 1:length(strctDesign.m_astrctMedia);
            cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
            filename{i} = strctDesign.m_astrctMedia(i).m_strName;
        end
    else
        output = nan;
        return;
    end
    
else
    strctUnit1 = load([matpath mat(1).name]);
    matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
    mat = dir([matpath '*_Unit_' unitnumber2 '_Passive_Fixation_New_.mat']);
    strctUnit2 = load([matpath mat(1).name]);
    
    strctUnit2 = strctUnit2.strctUnit;
    
    fid = fopen('\\192.168.50.15\StimulusSet\PB_TwoImages\twoimages.txt');
    C = textscan(fid,'%s');
    filename = C{1};
    fclose(fid);
end
CondMatrix = zeros(length(filename),5);
figure;

for i = 1:length(filename)
    fn = filename{i};
    xx = find(fn == '_');
    Name1 = fn(1:xx(1)-1);
    CondMatrix(i,1) = findcond(Name1);
    Name2 = fn(xx(1)+1:xx(2)-1);
    CondMatrix(i,2) = findcond(Name2);
    CC1 = fn(xx(2)+1:xx(2)+3);
    CondMatrix(i,3) = str2num(CC1(end-1:end));
    CC2 = fn(xx(3)+1:xx(3)+3);
    CondMatrix(i,4) = str2num(CC2(end-1:end));
    if strcmpi(CC1(1),'l') && strcmpi(CC2(1),'r');
        CondMatrix(i,5) = 1;
    else
        CondMatrix(i,5) = 2;
    end
end
figure;
clear xx;
t = 1;
t1 = strctUnit1.m_afStimulusONTime;
t2 = strctUnit2.m_afStimulusONTime;

[junk i1 i2] = intersect(t1,t2);

if isempty(junk);
    return ;
else
    strctUnit1.m_a2bRaster_Valid = strctUnit1.m_a2bRaster_Valid(i1,:);
    strctUnit2.m_a2bRaster_Valid = strctUnit2.m_a2bRaster_Valid(i2,:);
    strctUnit1.m_aiStimulusIndexValid = strctUnit1.m_aiStimulusIndexValid(i1);
        strctUnit2.m_aiStimulusIndexValid = strctUnit2.m_aiStimulusIndexValid(i2);

end
    for i = 1:3
        for j = 4:7
            for k = 10:20:90;
                index = find(CondMatrix(:,1) == j & CondMatrix(:,2) == i & CondMatrix(:,4) == k & CondMatrix(:,5) == 1);
                tt = find(strctUnit1.m_aiStimulusIndexValid == index);
                for m = 1:length(tt)
                    %                plot(strctUnit1.m_a2bRaster_Valid(tt(m),201:600),'b');
                    %                 xx(t,1) = sum(strctUnit1.m_a2bRaster_Valid(tt(m),201:800));
                    %                hold on;
                    %                 plot(strctUnit2.m_a2bRaster_Valid(tt(m),201:600),'r');
                    %                  xx(t,2) = sum(strctUnit2.m_a2bRaster_Valid(tt(m),201:800));
                    %                 t = t + 1;
                    %                hold off;
                    %                pause
                    xx(:,m,1) = strctUnit1.m_a2bRaster_Valid(tt(m),251:400);
                    xx(:,m,2) = strctUnit2.m_a2bRaster_Valid(tt(m),251:400);
                end
                rr{i,j-3,(k+10)/20} = xx;
                
            end
        end
    end
    % t1 = 0;
    % for timewindow = [10 20 40 80 160]
    %     t1 = t1 + 1;
    %     for i = 1:3
    %         for j = 1:4
    %             for k = 1:5
    %                 xx = rr{i,j,k};
    %                 for m = 1:size(xx,2);
    %                     for t = 1:(size(xx,1)-timewindow)
    %                         unit1_window(t,m) = sum(squeeze(xx(t:t+timewindow-1,m,1)));
    %                         unit2_window(t,m) = sum(squeeze(xx(t:t+timewindow-1,m,2)));
    %                     end
    %                 end
    %                 unit1_window = reshape(unit1_window,size(unit1_window,1)*size(unit1_window,2),1);
    %                 unit2_window = reshape(unit2_window,size(unit2_window,1)*size(unit2_window,2),1);
    %                 junk = corrcoef(unit1_window,unit2_window);
    %                 corr_result(t1,i,j,k) = junk(1,2);
    %             end
    %         end
    %     end
    % end
    
    for i = 1:3
        for j = 1:4
            for k = 1:5
                xx = rr{i,j,k};
                xx = squeeze(sum(xx,1));
                kk = corrcoef(xx(:,1),xx(:,2));
                trialbasecorr(i,j,k) = kk(1,2);
            end
        end
    end
    
    for randnumber = 1:100
        for i = 1:3
            for j = 1:4
                for k = 1:5
                    xx = rr{i,j,k};
                    xx = squeeze(sum(xx,1));
                    xx(:,2) = xx(randperm(size(xx,1)),2);
                    kk = corrcoef(xx(:,1),xx(:,2));
                    trialbasecorr_random(i,j,k,randnumber) = kk(1,2);
                end
            end
        end
    end
    baseline = reshape(trialbasecorr_random,12,5,100);
    trialbasecorr = reshape(trialbasecorr,12,5);
    trialbasecorr = 0.5 * log((1+trialbasecorr)./(1-trialbasecorr));
    baseline = 0.5 * log((1+baseline)./(1-baseline));
    for i = 1:5
        subplot(3,2,i)
        tt = squeeze(baseline(:,i,:));
        
        h = boxplot(tt');
        set(h,'linewidth',2);
        hold on;
        xx = trialbasecorr(:,i);
        xx(xx>2) = 2;
        xx(xx<-2) = -2;
        plot(xx,'ro','linewidth',2);
        box off;
        axis([0.5 12.5 -2 2]);
    end
    
    subplot(3,2,6);
    afX = 1:length(strctUnit1.m_afAvgWaveForm);
    afY = strctUnit1.m_afAvgWaveForm;
    afS = strctUnit1.m_afStdWaveForm;
    
    fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], [1 0 0]);hold on;
    plot(afX,afY, 'color', 'r','LineWidth',2);
    afX = 1:length(strctUnit2.m_afAvgWaveForm);
    afY = strctUnit2.m_afAvgWaveForm;
    afS = strctUnit2.m_afStdWaveForm;
    
    fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], [0 0 1]);hold on;
    plot(afX,afY, 'color', 'b','LineWidth',2);
    legend(unitnumber1,'',unitnumber2);
    set(gcf,'Position',[    438    49   891   948]);
    epsfilename = [matpath '..\figure\' unitnumber1 '_' unitnumber2 '_PB_TwoImage_Coherence.eps'];
    if exist([matpath '..\figure\'],'dir');
    else
        mkdir([matpath '..\figure\']);
    end
    set(gcf, 'PaperPositionMode', 'auto')
    print('-depsc',epsfilename);