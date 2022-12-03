function OcclusionAnalysis(subjID,experiment,foldername,unitnumber)
matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_OcclusionsModified.mat']);
[matpath '*_Unit_' unitnumber '_Passive_Fixation_New_OcclusionsModified.mat']
if isempty(mat)
    return;
else
    strctUnit = load([matpath mat(1).name]);
end
strctUnit = strctUnit.strctUnit;

strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    cond{i} = strctDesign.m_astrctMedia(i).m_acAttributes{1};
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

CondMatrix = zeros(300,4);
for i = 1:300
    name = filename{i};
    xx = find(name == '_');
    centerImageIndex = str2num(name(xx(1)-1));
    category = name((xx(1)+1):(xx(1)+4));
    if ~strcmp(category,'face');
        FlankerImageIndex = str2num(name(xx(1)+4));
        FlankerImageIndex = FlankerImageIndex + 5;
        
    else
        FlankerImageIndex = str2num(name(xx(1)+5));
    end
    
    
    align = name(xx(2)+1:xx(3)-1);
    if strcmpi(align,'sidebyside');
        AlignIndex = 1;
    elseif strcmpi(align,'CenterUp');
        AlignIndex = 2;
    else
        AlignIndex = 3;
    end
    lr = name(xx(3)+1:end);
    if strcmp(lr,'LH');
        lh = 1;
    else
        lh = 2;
    end
    CondMatrix(i,:) = [centerImageIndex FlankerImageIndex AlignIndex lh];
end

% [1 2] center
% [3 4] Close
% 5 far
BaseMatrix = zeros(80,3)
for i = 301:length(filename)
    name = filename{i}
    xx = find(name == '_');
    if length(xx) == 1;
        ImageIndex = str2num(name(xx(1)+1));
        category = name(1:xx(1)-1);
        if strcmpi(category,'obj');
            ImageIndex = ImageIndex + 5;
        end
        OccludedOrNot = 1;
        lr = 0;
    elseif length(xx) == 2;
        if strcmp(name(1:4),'face');
            ImageIndex = str2num(name(5));
        else
            ImageIndex = str2num(name(4))+5;
        end
        OccludedOrNot = 5;
        if strcmp(name(xx(2)+1:end),'LH')
            lr = 1;
        else
            lr = 2;
        end
    elseif length(xx) == 3
        if strcmpi(name(1:xx(1)-1),'avgmask');
            if strcmp(name(xx(1)+1:xx(1)+4),'face');
                ImageIndex = str2num(name(xx(1)+5));
            else
                ImageIndex = str2num(name(xx(1)+4))+5;
            end
            if strcmpi(name(xx(2)+1:xx(3)-1),'full')
                OccludedOrNot = 3;
            else
                OccludedOrNot = 4;
            end
            if strcmp(name(xx(3)+1:end),'LH')
                lr = 1;
            else
                lr = 2;
            end
        else
            ImageIndex = str2num(name(5));
            OccludedOrNot = 2;
            if strcmp(name(xx(3)+1:end),'LH')
                lr = 1;
            else
                lr = 2;
            end
        end
        
    end
    BaseMatrix(i-300,:) = [ImageIndex OccludedOrNot lr];
    
end

Resp = strctUnit.m_afAvgFirintRate_Stimulus;
Resp_TwoImage = Resp(1:300);
Resp_SingleImage = Resp(301:380);
mask = ~(isnan(Resp_TwoImage));
CondTwoImage = CondMatrix(mask,:);
rr_real  = Resp_TwoImage(mask);
[junk tt] = sort(CondTwoImage(:,3));
CondTwoImage = CondTwoImage(tt,:);
subplot(2,1,1);

Bar(rr_real(tt));
RealResp = rr_real(tt);
hold on;

% Model 1


for i = 1:size(CondTwoImage,1)
    ImageIndex1 = CondTwoImage(i,1);
    ImageIndex2 = CondTwoImage(i,2);
    lr = CondTwoImage(i,4);
    index1 = find(BaseMatrix(:,1)==ImageIndex1 & BaseMatrix(:,2) == 1 & BaseMatrix(:,3)== 0);
    index2 = find(BaseMatrix(:,1)==ImageIndex2 & BaseMatrix(:,2) == 1 & BaseMatrix(:,3)== 0);
    PredictedResp1(i) = (Resp_SingleImage(index1) + Resp_SingleImage(index2))/2;
end
subplot(2,1,1);
plot(PredictedResp1,'r','linewidth',2);
hold on;
Rsquare(1) = sumsqr(PredictedResp1-RealResp');
% Model 2
Resp_SingleImage = Resp(301:380);

for i = 1:size(CondTwoImage,1)
    ImageIndex1 = CondTwoImage(i,1);
    ImageIndex2 = CondTwoImage(i,2);
    ImageCond = CondTwoImage(i,3);
    lr = CondTwoImage(i,4);
    switch ImageCond
        case 1
            index1 = find(BaseMatrix(:,1) == ImageIndex1 & BaseMatrix(:,2) == 1 & BaseMatrix(:,3)==0);
            index2 = find(BaseMatrix(:,1) == ImageIndex2 & BaseMatrix(:,2) == 5 & BaseMatrix(:,3)==lr);
        case 2
            index1 = find(BaseMatrix(:,1) == ImageIndex1 & BaseMatrix(:,2) == 1 & BaseMatrix(:,3)==0);
            index2 = find(BaseMatrix(:,1) == ImageIndex2 & BaseMatrix(:,2) == 4 & BaseMatrix(:,3)==lr);
        case 3
            index1 = find(BaseMatrix(:,1) == ImageIndex1 & BaseMatrix(:,2) == 2 & BaseMatrix(:,3)==lr);
            index2 = find(BaseMatrix(:,1) == ImageIndex2 & BaseMatrix(:,2) == 3 & BaseMatrix(:,3)==lr);
    end
    PredictedResp2(i) = (Resp_SingleImage(index1) + Resp_SingleImage(index2))/2;
    
end
plot(PredictedResp2,'c','linewidth',2);
Rsquare(2) = sumsqr(PredictedResp2-RealResp');

% Model 3
Resp_SingleImage = Resp(301:380);

for i = 1:size(CondTwoImage,1)
    ImageIndex1 = CondTwoImage(i,1);
    ImageIndex2 = CondTwoImage(i,2);
    ImageCond = CondTwoImage(i,3);
    lr = CondTwoImage(i,4);
    switch ImageCond
        case 1
            index1 = find(BaseMatrix(:,1) == ImageIndex1 & BaseMatrix(:,2) == 1 & BaseMatrix(:,3)==0);
            index2 = find(BaseMatrix(:,1) == ImageIndex2 & BaseMatrix(:,2) == 5 & BaseMatrix(:,3)==lr);
            PredictedResp3(i) = (Resp_SingleImage(index1) + Resp_SingleImage(index2))/2;
            
        case 2
            index1 = find(BaseMatrix(:,1) == ImageIndex1 & BaseMatrix(:,2) == 1 & BaseMatrix(:,3)==0);
            index2 = find(BaseMatrix(:,1) == ImageIndex2 & BaseMatrix(:,2) == 4 & BaseMatrix(:,3)==lr);
            PredictedResp3(i) = (Resp_SingleImage(index1) + Resp_SingleImage(index2)*1/2)/(3/2);
            
        case 3
            index1 = find(BaseMatrix(:,1) == ImageIndex1 & BaseMatrix(:,2) == 2 & BaseMatrix(:,3)==lr);
            index2 = find(BaseMatrix(:,1) == ImageIndex2 & BaseMatrix(:,2) == 3 & BaseMatrix(:,3)==lr);
            PredictedResp3(i) = (Resp_SingleImage(index1)*1 + Resp_SingleImage(index2)*1)/(2);
            
    end
    
end
plot(PredictedResp3,'g','linewidth',2);
Rsquare(3) = sumsqr(PredictedResp3-RealResp');

hold off;

hold off;
Rsquare


for i = 1:3
    subplot(2,3,3+i);
    cc = {'ro','co','go'}
    
    if i == 1
        pp = PredictedResp1;
    elseif i==2
        pp = PredictedResp2;
    else
        pp = PredictedResp3;
    end
    plot(pp,RealResp,cc{i});
    hold on;
    plot(0:60,0:60,'r');
    axis square;
    axis equal
    axis([0 60 0 60]);
end

figure;

k = 1;
for i = 1:10
    for j = 1:5
    index = find(BaseMatrix(:,1) == i & BaseMatrix(:,2) == j & (BaseMatrix(:,3) == 1 | BaseMatrix(:,3) == 0))
    if ~isempty(index)
    rb(k) = Resp_SingleImage(index);
    else
        rb(k) = 0;
    end
    k = k + 1;
    end
end
bar(rb);




