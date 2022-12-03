function [fr,fr_rb,consistency] = PB_Civall_half_singleUnit(subjID,experiment,day,unitnumber,cc)

if nargin < 5
    cc = [60 220];
end


strctUnit = fnFindMat(subjID,day,experiment,unitnumber,'cvall_half');



[fr fr_half consistency]  = fnAveragePB_splitharf(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:12*4*13)>0, strctUnit.m_aiPeriStimulusRangeMS, cc(1),cc(2));
consistency
fr_rb = fnAveragePB_MinusBaseline(strctUnit.m_a2bRaster_Valid,  strctUnit.m_aiStimulusIndexValid, diag(1:12*4*13)>0, strctUnit.m_aiPeriStimulusRangeMS, 60, 220,-50,25);

fr(isnan(fr)) = 0;
fr(isnan(fr_rb)) = 0;

ss = strctUnit.m_a2fAvgFirintRate_Stimulus;
ss = reshape(ss,12,4,13,size(ss,2));
ss = permute(ss,[1 3 2 4]);
ss = reshape(ss,12*4*13,size(ss,4));
% figure;
% imshow(ss,[]);
% colormap('default');
% axis on;
% set(gca,'xTick',[100:100:1000]);
% set(gca,'xTickLabel',[-100:100:800]);
%
%

% consistency
% fr = reshape(fr,12,4,13);
% figure;
% for i = 1:4
%     subplot(2,2,i);
%     ff = fr(:,i,:);
%     ff = squeeze(ff);
%     imshow(imresize(ff,10,'nearest'));
%     colormap('default');
%     set(gca,'Clim',[min(fr(:)) max(fr(:)    )]);
% end


% for i = 1:4
%     subplot(2,2,i);
%     im = zeros(100*12,100*13);
%     for j = 1:12
%         for k = 1:13
%             im((j-1)*100+1:j*100,(k-1)*100+1:k*100) = imresize(imc(:,:,j,i,k),[100 100]);
%         end
%     end
%     imshow(im,[]);
% end

