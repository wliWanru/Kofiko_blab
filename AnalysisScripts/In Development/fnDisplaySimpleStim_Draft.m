function fnDisplaySimpleStim_Draft(Date,Unit);
NewDate = ['20' Date(1:2) '-' Date(3:4) '-' Date(5:6')];
spacing = 0.12;spacing2 = 0.1;
if Unit<10
    UnitString = ['00' num2str(Unit)];
elseif Unit<100
    UnitString = ['0' num2str(Unit)];
else
    UnitString = num2str(Unit);
end


expnum = 2;


matlist = dir(['D:\PB\EphysData\Benjamin\Border_Project\' Date '\Processed\SingleUnitDataEntries\*_' NewDate '*_Unit_' UnitString '_Simple_Stim_' num2str(expnum) '.mat']);
load(['D:\PB\EphysData\Benjamin\Border_Project\' Date '\Processed\SingleUnitDataEntries\' matlist(1).name])
workingfolder = ['D:\PB\EphysData\Benjamin\Border_Project\' Date '\'];

figure;

tightsubplot(2,2,1,'Spacing',spacing);
imagesc(strctUnit.m_aiPeriStimulusRangeMS,(1:size(strctUnit.m_a2fAvgFirintRate_Stimulus,1)-1)*15,...
    strctUnit.m_a2fAvgFirintRate_Stimulus);

xlabel('Time (ms)');
ylabel('Orientation');
colorbar
%title(sprintf('Firing rate (running avg, 30 ms)'));
axis xy
colormap('Default')
% set(gca,'Clim',[0 150]);
tightsubplot(2,2,2,'Spacing',spacing)
if ~isfield(strctUnit,'m_afAvgFiringSamplesCategory')
    strctUnit.m_afAvgFiringSamplesCategory = 1e3*strctUnit.m_afAvgFiringRateCategory;
end
polarhandle = polar(([0:15:345 360])/180*pi, [strctUnit.m_afAvgFiringSamplesCategory strctUnit.m_afAvgFiringSamplesCategory(1)]);
set(polarhandle,'LineWidth',2);

expnum = 4;
matlist = dir(['D:\PB\EphysData\Benjamin\Border_Project\' Date '\Processed\SingleUnitDataEntries\*_' NewDate '*_Unit_' UnitString '_Simple_Stim_' num2str(expnum) '.mat']);
load(['D:\PB\EphysData\Benjamin\Border_Project\' Date '\Processed\SingleUnitDataEntries\' matlist(1).name])

%load('D:\PB\EphysData\Benjamin\Border_Project\140417\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-04-17_15-55-20_Exp_NaN_Ch_001_Unit_004_Simple_Stim_4.mat');
xx = 50:25:(size(strctUnit.m_a2fAvgFirintRate_Stimulus,1)-1)*25+50;
tightsubplot(2,2,3,'Spacing',spacing);
imagesc(strctUnit.m_aiPeriStimulusRangeMS,xx,...
    strctUnit.m_a2fAvgFirintRate_Stimulus);

xlabel('Time (ms)');
ylabel('Size(Pix)');
colorbar
%title(sprintf('Firing rate (running avg, 30 ms)'));
axis xy
colormap('Default')
% set(gca,'Clim',[0 150]);
tightsubplot(2,2,4,'Spacing',0.1)
if ~isfield(strctUnit,'m_afAvgFiringSamplesCategory')
    strctUnit.m_afAvgFiringSamplesCategory = 1e3*strctUnit.m_afAvgFiringRateCategory;
end
bar(xx,[strctUnit.m_afAvgFiringSamplesCategory],0.7 );
box off;
set(gcf,'Position',[ 195   236   942   697]);
if exist([workingfolder 'Figure_EPS'],'dir')
else
    mkdir([workingfolder 'Figure_EPS']);
end

saveAs(gcf,[workingfolder 'Figure_EPS\Uint_' UnitString '_BasicProperty.eps'],'epsc');
figure;

expnum = 5;
matlist = dir(['D:\PB\EphysData\Benjamin\Border_Project\' Date '\Processed\SingleUnitDataEntries\*_' NewDate '*_Unit_' UnitString '_Simple_Stim_' num2str(expnum) '.mat']);
load(['D:\PB\EphysData\Benjamin\Border_Project\' Date '\Processed\SingleUnitDataEntries\' matlist(1).name])

stimulusSize = strctUnit.m_strctStimulusParams.m_afStimulusSizePix;

sizecond = unique(stimulusSize)
iStartAvg = 0;
iEndAvg = 250;
iStartIndex = find(strctUnit.m_aiPeriStimulusRangeMS>iStartAvg,1,'first');
iEndIndex = find(strctUnit.m_aiPeriStimulusRangeMS>iEndAvg,1,'first');
for i = 1:length(sizecond)
    sz = sizecond(i);
    szindex = (stimulusSize == sz);
    rasterplot = 1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid(szindex,:),strctUnit.m_aiStimulusIndexValid(szindex),diag(1:4)>0,3,1);
    tightsubplot(length(sizecond),3,(i-1)*3+1,'Spacing',spacing2);
    plot(strctUnit.m_aiPeriStimulusRangeMS, rasterplot(1:2,:),'LineWidth',2);
    box off;
    Axis([-200 500 0 100]);
    tightsubplot(length(sizecond),3,(i-1)*3+2,'Spacing',spacing2);
    plot(strctUnit.m_aiPeriStimulusRangeMS, rasterplot(3:4,:),'LineWidth',2);
    box off;
    Axis([-200 500 0 100]);   
    meanfiring = mean(rasterplot(:, iStartIndex:iEndIndex),2);
        tightsubplot(length(sizecond),3,(i-1)*3+3,'Spacing',spacing2);
    bar(1:4,meanfiring,0.7);
    box off;
    
end
set(gcf,'Position',[   680   249   886   729]);
saveAs(gcf,[workingfolder 'Figure_EPS\Uint_' UnitString '_BorderOwner.eps'],'epsc');

