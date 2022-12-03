
function PB_facetypewriter_SFC(subjID,experiment,day,time,unit1,unit2,doplot);

if nargin<7
    doplot = 1;
end

strctUnit1 = fnFindMat(subjID,day,experiment,unit1,'face_typewriter',time);
strctUnit2 = fnFindMat(subjID,day,experiment,unit2,'face_typewriter',time);


t1 = strctUnit1.m_afStimulusONTime;
t2 = strctUnit2.m_afStimulusONTime;
[junk i1 i2] = intersect(t1,t2);

strctUnit1.m_a2fLFP_Valid = strctUnit1.m_a2fLFP(strctUnit1.m_abValidTrials,:);
strctUnit2.m_a2fLFP_Valid = strctUnit2.m_a2fLFP(strctUnit2.m_abValidTrials,:);



if isempty(junk);
    return ;
end
raster1 = strctUnit1.m_a2bRaster_Valid(i1,:);
raster2 = strctUnit2.m_a2bRaster_Valid(i2,:);
lfp1 = strctUnit1.m_a2fLFP_Valid(i1,:);
lfp2 = strctUnit2.m_a2fLFP_Valid(i2,:);
% lfp1 = filterLFPofTrial( lfp1', 2, 1000 )
% lfp1 = lfp1{1};
% lfp1 = lfp1';
% lfp2 = filterLFPofTrial( lfp2', 2, 1000 )
% lfp2 = lfp2{1};
% lfp2 = lfp2';
trialtype = strctUnit2.m_aiStimulusIndexValid(i2);

j = 250
tic
SFC_spike1_to_lfp2 =  PB_SpikeFieldCoherence(raster1,lfp2,j:j+20,trialtype,200)
toc
SFC_spike2_to_lfp1 =  PB_SpikeFieldCoherence(raster2,lfp1,j:j+20,trialtype,200)
toc
SFC_spike1_to_lfp1 =  PB_SpikeFieldCoherence(raster1,lfp1,j:j+20,trialtype,200)
toc
SFC_spike2_to_lfp2 =  PB_SpikeFieldCoherence(raster2,lfp2,j:j+20,trialtype,200)
toc

m = 2;
n = 4;
if doplot
    h1 = figure;
    k = 0;
    k = k + 1;
    subplot(m,n,k)
    hold on;
    %title('ML-Spike:Stimulus Triggered');
    plot(strctUnit1.m_aiPeriStimulusRangeMS,strctUnit1.m_a2fAvgFirintRate_Category(1,:),'b-','linewidth',2);
    plot(strctUnit1.m_aiPeriStimulusRangeMS,strctUnit1.m_a2fAvgFirintRate_Category(2,:),'r-','linewidth',2);
    axis([0 700 0 1]);
    axis 'auto y'
    k = k + 1;
    subplot(m,n,k)
    hold on;
    %title('V4-Spike:Stimulus Triggered');
    plot(strctUnit2.m_aiPeriStimulusRangeMS,strctUnit2.m_a2fAvgFirintRate_Category(1,:),'b-','linewidth',2);
    plot(strctUnit2.m_aiPeriStimulusRangeMS,strctUnit2.m_a2fAvgFirintRate_Category(2,:),'r-','linewidth',2);
    axis([0 700 0 1]);
    axis 'auto y'
    k = k + 1;
    subplot(m,n,k)
    hold on;
    %title('ML-LFP:Stimulus Triggered');
    plot(strctUnit1.m_aiPeriStimulusRangeMS,strctUnit1.m_a2fAvgLFPCategory(1,:),'b-','linewidth',2);
    plot(strctUnit1.m_aiPeriStimulusRangeMS,strctUnit1.m_a2fAvgLFPCategory(2,:),'r-','linewidth',2);
    axis([0 700 0 1]);
    axis 'auto y'
    k = k + 1;
    subplot(m,n,k)
    hold on;
    %title('V4-LFP:Stimulus Triggered');
    plot(strctUnit2.m_aiPeriStimulusRangeMS,strctUnit2.m_a2fAvgLFPCategory(1,:),'b-','linewidth',2);
    plot(strctUnit2.m_aiPeriStimulusRangeMS,strctUnit2.m_a2fAvgLFPCategory(2,:),'r-','linewidth',2);
    axis([0 700 0 1]);
    axis 'auto y'
    %     k = k + 1;
    %     subplot(m,n,k)
    %     hold on;
    %     title('ML-LFP:ML Spike Triggered');
    %     plot(-200:200,SFC_spike1_to_lfp1.stlfp(1,:),'b-','linewidth',2)
    %     plot(-200:200,SFC_spike1_to_lfp1.stlfp(2,:),'r-','linewidth',2)
    %     k = k + 1;
    %     subplot(m,n,k)
    %     hold on;
    %     title('V4-LFP:V4 Spike Triggered');
    %     plot(-200:200,SFC_spike2_to_lfp2.stlfp(1,:),'b-','linewidth',2)
    %     plot(-200:200,SFC_spike2_to_lfp2.stlfp(2,:),'r-','linewidth',2)
    %     k = k + 1;
    %     subplot(m,n,k)
    %     hold on;
    %     title('ML-LFP:V4 Spike Triggered');
    %     plot(-200:200,SFC_spike2_to_lfp1.stlfp(1,:),'b-','linewidth',2)
    %     plot(-200:200,SFC_spike2_to_lfp1.stlfp(2,:),'r-','linewidth',2)
    %     k = k + 1;
    %     subplot(m,n,k)
    %     hold on;
    %     title('V4-LFP:ML Spike Triggered');
    %     plot(-200:200,SFC_spike1_to_lfp2.stlfp(1,:),'b-','linewidth',2)
    %     plot(-200:200,SFC_spike1_to_lfp2.stlfp(2,:),'r-','linewidth',2)
    
    k = k + 1;
    subplot(m,n,k)
    hold on;
    %title('Spike-triggered coherence:ML Spike ML LFP ');
    freq = linspace(0,500,257);
    plot(freq,SFC_spike1_to_lfp1.stenergy(1,:)./SFC_spike1_to_lfp1.stlfpenergy(1,:),'b-','linewidth',2)
    plot(freq,SFC_spike1_to_lfp1.stenergy(2,:)./SFC_spike1_to_lfp1.stlfpenergy(2,:),'r-','linewidth',2)
    axis([1 20 0 1]);
    axis 'auto y'
    
    k = k + 1;
    subplot(m,n,k)
    hold on;
    %title('Spike-triggered coherence:V4 Spike V LFP ');
    freq = linspace(0,500,257);
    plot(freq,SFC_spike2_to_lfp2.stenergy(1,:)./SFC_spike2_to_lfp2.stlfpenergy(1,:),'b-','linewidth',2)
    plot(freq,SFC_spike2_to_lfp2.stenergy(2,:)./SFC_spike2_to_lfp2.stlfpenergy(2,:),'r-','linewidth',2)
    axis([1 20 0 1]);
    axis 'auto y'
    
    k = k + 1;
    subplot(m,n,k)
    hold on;
    freq = linspace(0,500,257);
    plot(freq,SFC_spike2_to_lfp1.stenergy(1,:)./SFC_spike2_to_lfp1.stlfpenergy(1,:),'b-','linewidth',2)
    plot(freq,SFC_spike2_to_lfp1.stenergy(2,:)./SFC_spike2_to_lfp1.stlfpenergy(2,:),'r-','linewidth',2)
    axis([1 20 0 1]);
    k = k + 1;
    subplot(m,n,k)
    hold on;
    %title('Spike-triggered coherence:V4');
    freq = linspace(0,500,257);
    plot(freq,SFC_spike1_to_lfp2.stenergy(1,:)./SFC_spike1_to_lfp2.stlfpenergy(1,:),'b-','linewidth',2)
    plot(freq,SFC_spike1_to_lfp2.stenergy(2,:)./SFC_spike1_to_lfp2.stlfpenergy(2,:),'r-','linewidth',2)
    axis([1 40 0 1]);
    axis 'auto y'
  %  writepdf(h1,['D:\PB\facetypewriter\' subjID '_' day '_' time '_ML_' unit1 '_V4_' unit2 '.pdf']);
end

