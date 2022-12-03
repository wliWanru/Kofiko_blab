function ff = PB_StevenUpDown_SingleUnit(subjID,experiment,day,unitnumber,flag)

if nargin < 5
    flag = 0;
end
%subjID = 'Rocco'; day = '150413'; experiment = 'Test'; unitnumber = '004';

strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'StevenMore');
xx = max(strctUnit.m_aiStimulusIndex);
fr = fnAveragePB(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:xx)>0, strctUnit.m_aiPeriStimulusRangeMS, 50, 200);





fr = reshape(fr,50,6);

ff = zeros(50,3,2);
ff(:,:,1) = fr(:,[1 6 5]);
ff(:,:,2) = fr(:,[2 4 3]);


figure;

for i = 1:2
    subplot(3,2,i);
    [junk tt] = sort(squeeze(ff(:,3,i)));
    plot(ff(tt,1,i),'k-','linewidth',2);
    hold on;
    plot(ff(tt,2,i),'r-','linewidth',2);
    plot(ff(tt,3,i),'b-','linewidth',2);
     subplot(3,2,i+2);
    [junk tt] = sort(squeeze(ff(:,2,i)));
    plot(ff(tt,1,i),'k-','linewidth',2);
    hold on;
    plot(ff(tt,2,i),'r-','linewidth',2);
    plot(ff(tt,3,i),'b-','linewidth',2);
    subplot(3,2,i+4);
    [junk tt] = sort(squeeze(ff(:,2,i)-ff(:,3,i)));
    plot(ff(tt,1,i),'k-','linewidth',2);
    hold on;
    plot(ff(tt,2,i),'r-','linewidth',2);
    plot(ff(tt,3,i),'b-','linewidth',2);
end


