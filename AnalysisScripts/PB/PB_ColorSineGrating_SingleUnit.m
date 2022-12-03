function output = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'ColorGrating');
%
%strctDesign = fnParsePassiveFixationDesignMediaFiles(strctUnit.m_strImageListUsed, false, false);
cc = {'k-','b-','c-','g-','m-','r-','y-','k--'};

fr = strctUnit.m_a2fAvgFirintRate_Stimulus;
fr = reshape(fr,7,8,5,size(fr,2));
% figure;
% for i = 1:8
%     for j = 1:5;
%         subplot(8,5,(i-1)*5+j)
%         hold on;
%         for k = 1:7
%             plot(strctUnit.m_aiPeriStimulusRangeMS(1:600),squeeze(fr(k,i,j,1:600)),cc{k},'linewidth',2);
%         end
%     end
% end

figure;
subplot(1,3,1);
hold on;

ff = reshape(fr,7,40,length(strctUnit.m_aiPeriStimulusRangeMS));
for k = 1:7
    plot(strctUnit.m_aiPeriStimulusRangeMS(1:600),squeeze(mean(ff(k,:,1:600),2)),cc{k},'linewidth',2);
end
subplot(1,3,2);
hold on;

for k = 1:8
    ff = squeeze(fr(:,k,:,:));
    ff = reshape(ff,35,length(strctUnit.m_aiPeriStimulusRangeMS));
    ff = mean(ff,1);
    plot(strctUnit.m_aiPeriStimulusRangeMS(1:600),ff(1:600),cc{k},'linewidth',2);
end
subplot(1,3,3);
hold on;

for k = 1:5
    ff = squeeze(fr(:,:,k,:));
    ff = reshape(ff,56,length(strctUnit.m_aiPeriStimulusRangeMS));
    ff = mean(ff,1);
    plot(strctUnit.m_aiPeriStimulusRangeMS(1:600),ff(1:600),cc{k},'linewidth',2);
end


figure;
subplot(2,3,1);
bar(1:7,strctUnit.m_afAvgFiringRateCategory([1:4 13:14 20])*1000);
set(gca,'XTickLabel',{ 'black','blue','cyan','green','purple','red','yellow'}); 

subplot(2,3,2);
bar(1:8,strctUnit.m_afAvgFiringRateCategory([5:12])*1000);
set(gca,'XTickLabel',0:22.5:180-22.5);

subplot(2,3,3);
bar(1:5,strctUnit.m_afAvgFiringRateCategory([15:19])*1000);
set(gca,'XTickLabel',1:5);

subplot(2,3,5);
tt = strctUnit.m_afAvgFirintRate_Stimulus;
tt = reshape(tt,7,8,5);
[junk index] = max(strctUnit.m_afAvgFiringRateCategory([1:4 13:14 20]));
tmax = squeeze(tt(index,:,:));
bar(mean(tmax,2))
subplot(2,3,6)
bar(mean(tmax));


%bar(1:7,

return;

