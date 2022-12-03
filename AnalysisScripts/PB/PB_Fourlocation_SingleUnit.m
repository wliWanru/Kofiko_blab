function result = OcclusionAnalysis(subjID,experiment,foldername,unitnumber,doplot)
usePB = 1;
if nargin <5
    doplot = 1;
end

%subjID = 'Rocco'; experiment = 'test'; foldername = '141012'; unitnumber = '001';
matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];

mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_TwoImageFourlocation_*.mat']);
if ~isempty(mat)
    strctUnit = load([matpath mat(1).name]);
    strctUnit = strctUnit.strctUnit;
    
    strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    for i = 1:length(strctDesign.m_astrctMedia);
        cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
        filename{i} = strctDesign.m_astrctMedia(i).m_strName;
    end
else
    output = nan;
    return;
end

CondMatrix = zeros(length(filename),5);

for i = 1:length(filename)
    fn = filename{i};
    xx = find(fn == '_');
    if strcmpi(fn(1:xx(1)-1),'blank')
        CondMatrix(i,1) = 0;
    else
        CondMatrix(i,1) = str2num(fn(xx(1)-1));
    end
    if strcmpi(fn(xx(1)+1:xx(2)-1),'blank')
        CondMatrix(i,2) = 0;
    else
        CondMatrix(i,2) = str2num(fn(xx(2)-1));
    end
    
    CondMatrix(i,3) = str2num(fn(xx(3)-1));
    CondMatrix(i,4) = str2num(fn(xx(4)-1));
    CondMatrix(i,5) = str2num(fn(end-1:end));
end




if usePB
    [strctUnit.m_afAvgFirintRate_Stimulus, strctUnit.m_afAvgFirintRate_StimulusStd, aiCount] = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 150);
else
    strctUnit.m_afAvgFirintRate_StimulusStd = zeros(size(strctUnit.m_afAvgFirintRate_Stimulus));
    strctUnit.m_afAvgStimulusResponseMinusBaselineStd = zeros(size(strctUnit.m_afAvgFirintRate_Stimulus));
    aiCount = ones(size(strctUnit.m_afAvgFirintRate_StimulusStd));
    strctUnit.m_afAvgStimulusResponseMinusBaseline = strctUnit.m_afAvgStimulusResponseMinusBaseline * 1000;
end
result = zeros(3,5,4,4);
if doplot
    h1 = figure;
    h2 = figure;
end
for i = 1:4
    for j = 1:4
        
        for cc = 10:20:90
            indexface= find(CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 0 & CondMatrix(:,5) == cc);
            indexobj = find(CondMatrix(:,1) == 0 & CondMatrix(:,4) == j & CondMatrix(:,3) == 0 & CondMatrix(:,5) == cc);
            indexcomb = find( CondMatrix(:,4) == j & CondMatrix(:,3) == i & CondMatrix(:,5) == cc);
            if ~isempty(indexcomb);
                
                rf((cc+10)/20) = mean(strctUnit.m_afAvgFirintRate_Stimulus(indexface));
                ro((cc+10)/20) = mean(strctUnit.m_afAvgFirintRate_Stimulus(indexobj));
                rc((cc+10)/20) = mean(strctUnit.m_afAvgFirintRate_Stimulus(indexcomb));
            end
            
        end
        if ~isempty(indexcomb);
            result(1,:,i,j) = rf;
            result(2,:,i,j) = ro;
            result(3,:,i,j) = rc;
        end
        if doplot
            figure(h1);
            subplot(4,4,(i-1)*4+j);
            if ~isempty(indexcomb)
                
                hold on;
                plot(10:20:90,rf,'ro-','LineWidth',2);
                plot(10:20:90,ro,'bo-','LineWidth',2);
                plot(10:20:90,rc,'ko-','LineWidth',2);
                figure(h2);
                subplot(4,4,(i-1)*4+j);
                imshow(strctDesign.m_astrctMedia(indexcomb(1)).m_acFileNames{1});
            end
        end
        
        
    end
end


