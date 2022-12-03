function FiringRate_BOS = SimpleStim(ExpDate,Unit,Subject);
FiringRate_BOS = zeros(4,1);;
Close all;
figure;
if nargin < 3
    Subject = 'Rocco';
end

Datafolder = ['D:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];

matname = dir([Datafolder '*_Unit_' Unit '_*_BarOrientation.mat']);
if isempty(matname)
matname = dir([Datafolder '*_Unit_' Unit '_*_2.mat']);
end
if isempty(matname)
matname = dir([Datafolder '*_Unit_' Unit '_*_1.mat']);
end
if ~isempty(matname);
    strctUnit = load([Datafolder matname(1).name]);
    strctUnit = strctUnit.strctUnit;
    [AllFiringRate  All_Std  AllaiCount AllDescription] = SimpleStimAnalysisAux( strctUnit,20,200 )
    if size(AllFiringRate,2) > 1;
        Resp_BarOrientation = AllFiringRate(:,1);
    else
        Resp_BarOrientation = AllFiringRate;
    end
    subplot(2,2,1);
    h = polar([(0:15:345)/360*2*pi 0],[Resp_BarOrientation' Resp_BarOrientation(1)],'-b');
    set(h,'LineWidth',2);
    Title('Orientation-Selectivity');
    [junk index] = max(AllFiringRate);
    Orientation = (index-1) * 15;
end


% matname = dir([Datafolder '*_Unit_' Unit '_*_BarSize.mat']);
% if ~isempty(matname);
%     strctUnit = load([Datafolder matname(1).name]);
%     strctUnit = strctUnit.strctUnit;
%     [AllFiringRate  All_Std  AllaiCount AllDescription] = SimpleStimAnalysisAux( strctUnit,20,200 )
%     if size(AllFiringRate,2) > 1;
%         Resp_BarSize = AllFiringRate(:,1);
%     else
%         Resp_BarSize = AllFiringRate;
%     end
%     subplot(3,2,2);
%     Title('BarSize');
%     bar(50:25:300,Resp_BarSize')
%     box off;
%     Title('Size-Measurement(2Dimension)');
% end

matname = dir([Datafolder '*_Unit_' Unit '_*_BarSize_XDimension.mat']);
if isempty(matname)
matname = dir([Datafolder '*_Unit_' Unit '_*_4.mat']);
end
if ~isempty(matname);
    strctUnit = load([Datafolder matname(1).name]);
    strctUnit = strctUnit.strctUnit;
    [AllFiringRate  All_Std  AllaiCount AllDescription] = SimpleStimAnalysisAux( strctUnit,20,200 )
    if size(AllFiringRate,2) > 1;
        Resp_BarSize = AllFiringRate(:,1);
    else
        Resp_BarSize = AllFiringRate;
    end
    subplot(2,2,2);
    Title('BarSize');
    bar(50:25:300,Resp_BarSize')
    box off;
    Title('Size-Measurement(1Dimension)');
end

matname = dir([Datafolder '*_Unit_' Unit '_*_RFmapping.mat']);
if isempty(matname)
matname = dir([Datafolder '*_Unit_' Unit '_*_9.mat']);
end
if ~isempty(matname);
    strctUnit = load([Datafolder matname(1).name]);
    strctUnit = strctUnit.strctUnit;
    [AllFiringRate  All_Std  AllaiCount AllDescription] = SimpleStimAnalysisAux( strctUnit,20,200 )
    if size(AllFiringRate,2) > 1;
        Resp_RF = AllFiringRate(:,1);
    else
        Resp_RF = AllFiringRate;
    end
    subplot(2,2,3);
    Title('RF_Mapping');
    if (length(Resp_RF)==289)
    Resp_RF = reshape(Resp_RF,17,17);
    imshow(Resp_RF,[]);
    Colormap('Default');
    Colorbar;
    Title('ReceptiveField Mapping');
    end
end


matname = dir([Datafolder '*_Unit_' Unit '_*_ContrastBorderOwner.mat']);
if isempty(matname)
matname = dir([Datafolder '*_Unit_' Unit '_*_5.mat']);
end
if ~isempty(matname);
    strctUnit = load([Datafolder matname(1).name]);
    strctUnit = strctUnit.strctUnit;
    [AllFiringRate  All_Std  AllaiCount AllDescription AllRepeat] = SimpleStimAnalysisAux( strctUnit,20,500 )
    [junk index] = max(AllRepeat)
    if size(AllFiringRate,2) > 1;
        Resp_BarSize = AllFiringRate(:,index);
    else
        Resp_BarSize = AllFiringRate;
    end
    fh = subplot(2,2,4);
    FiringRate_BOS = Resp_BarSize;
    bar(1:4,Resp_BarSize')
    box off;
    Title('BorderOwnerCell');
    
    Position = get(fh,'Position');
    Figurewidth = Position(3);
    offsetX = Figurewidth/(4*6);
    offsetY = 0.06;
    im = BOSImage(Orientation);
    for i = 1:length(im);
        xStart = Figurewidth/(4)*(i-1)+offsetX+Position(1);
        yStart = Position(2) - offsetY;
        impp = [xStart yStart offsetX*4 offsetX*4]
        subplot('Position',impp);
        imhandle = imshow(im{i});
    end
end
colormap('default');
matname = dir([Datafolder '*_Unit_' Unit '_*_BOSOcclusion.mat']);

if ~isempty(matname);
    strctUnit = load([Datafolder matname(1).name]);
    strctUnit = strctUnit.strctUnit;
    [AllFiringRate  All_Std  AllaiCount AllDescription AllRepeat] = SimpleStimAnalysisAux( strctUnit,20,500 )
    [junk   index] = max(AllRepeat)
    if size(AllFiringRate,2) > 1;
        Resp_BarSize = AllFiringRate(:,index);
    else
        Resp_BarSize = AllFiringRate;
    end
    Resp_BarSize = Resp_BarSize;
    fh = subplot(2,2,3);
    bar(1:4,Resp_BarSize')
    box off;
    Title('BorderOwnerCell');

Position = get(fh,'Position');
Figurewidth = Position(3);
offsetX = Figurewidth/(4*6);
offsetY = 0.06;
strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);

for i = 1:4
    imall{i} = imread(strctDesign.m_astrctMedia(i).m_acFileNames{1})
end
for i = 1:length(im);
    xStart = Figurewidth/(4)*(i-1)+offsetX+Position(1);
    yStart = Position(2) - offsetY;
    impp = [xStart yStart offsetX*4 offsetX*4]
    subplot('Position',impp);
    im = imall{i};
    im(im==0) = 1;
    im = imrotate(im,Orientation,'crop');
    im(im==0) = 172;
    imshow(uint8(im));
end
end
colormap('default');



foldername = [Datafolder  '..\figure\'];
if ~exist(foldername,'dir');
    mkdir(foldername)
end

set(gcf,'Position',[393          49        1273         948]);


filename = [Datafolder  '..\figure\' Unit '_SimpleStim.eps'];
 set(gcf, 'PaperPositionMode', 'auto')
    print('-depsc',filename);

matname = dir([Datafolder '*_Unit_' Unit '_*_BOSmemory.mat']);
if ~isempty(matname);
    strctUnit = load([Datafolder matname(1).name]);
    strctUnit = strctUnit.strctUnit;
    result = BOSMemoryAnalysis(strctUnit);
    rotationAngle = strctUnit.m_strctStimulusParams.m_afRotationAngle;
    [angle I J] = unique(rotationAngle);
    for i = 1:length(angle)
        A(i) = sum(J == i);
    end
    [junk index] = max(A);
    rotationAngle = Orientation;
    
    strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
    figure;
    imagewidth = 0.04;
    
    for j = 1:4
        subplot(8,1,(j-1)*2+1);
        %         h = subplot(4,1,j);
        %         originalPosition = get(h,'Position');
        %         originalPosition = [originalPosition(1:3) originalPosition(4)-imagewidth*1.5];
        %         subplot('Position',originalPosition);
        hold on;
        h = plot(-199:4000,result(j,:),'r-','linewidth',2);
        set(gca,'XLim',[-200 3500]);
        axislength = abs(max(get(gca,'XLim')) - min(get(gca,'Xlim')));
        figureh = get(h,'Parent');
        fposition = get(figureh,'Position');
        xstart = fposition(1); xlength = fposition(3); ystart = fposition(2);
        for i = 1:4
            imXcenter = xstart + (xlength/axislength*200) + (1-mod(i,2))*(xlength/axislength*500)+(i>2)*(xlength/axislength*1500);
            if i < 3
                im = imread(strctDesign.m_astrctMedia((j-1)*8+i).m_acFileNames{1});
            else
                im = imread(strctDesign.m_astrctMedia((j-1)*8+i+1).m_acFileNames{1} );
                
            end
            imPosition = [imXcenter-imagewidth/2, ystart - 0.07,imagewidth,imagewidth];
            subplot('position',imPosition);
            im(im==0) = 1;
            im = imrotate(im,rotationAngle,'crop');
            im(im==0) = 172;
            imshow(uint8(im));
        end
    end
    set(gcf,'Position',[981    56   710   936]);
    
    filename = [Datafolder '..\figure\' Unit '_SimpleStim_BOSMemory.eps'];
    set(gcf, 'PaperPositionMode', 'auto')
    print('-depscc',filename);

    
end





