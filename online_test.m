clear all;

% [fr(:,1) junk im2(:,:,1) ev(1,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180308','003',1,[60 220],0,para);
% [fr(:,2) junk im2(:,:,2) ev(2,:)]  = PB_OnLineImage_SingleUnit('Alfie','test','180311','005',2,[60 100],0,para);
% [fr(:,3) junk im2(:,:,3) ev(3,:)]  = PB_OnLineImage_SingleUnit('Alfie','test','180313','004',1,[80 110],0,para);
% [fr(:,4) junk im2(:,:,4) ev(4,:)]  = PB_OnLineImage_SingleUnit('Alfie','test','180315','007',1,[80 110],0,para);
% [fr(:,5) junk im2(:,:,5) ev(5,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180323','004',3,[60 220],0,para);
% [fr(:,6) junk im2(:,:,6) ev(6,:) ] = PB_OnLineImage_SingleUnit('Alfie','test','180328','001',1,[60 220],0,para);
% [fr(:,7) junk im2(:,:,7) ev(7,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180328','003',2,[60 220],0,para);
% [fr(:,8) junk im2(:,:,8) ev(8,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180330','002',1,[60 220],0,para);
% [fr(:,9) junk im2(:,:,9) ev(9,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180321','001',1,[60 220],0,para);
% [fr(:,10) junk im2(:,:,10) ev(10,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180404','002',1,[60 220],0,para);
% [fr(:,11) junk im2(:,:,11) ev(11,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180404','004',3,[60 220],0,para);
% [fr(:,12) junk im2(:,:,12) ev(12,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180406','002',1,[60 220],0,para);
% [fr(:,13) junk im2(:,:,13) ev(13,:)] = PB_OnLineImage_SingleUnit('Alfie','test','180408','001',1,[60 220],0,para);


dd = {'180308','003',1
    '180311','005',2
    '180313','004',1
    '180315','007',1
    '180323','004',3
    '180328','001',1
    '180328','003',2
    '180330','002',1
    '180321','001',2
    '180404','002',1
    '180404','004',3
    '180406','002',1
    '180408','001',1
    '180411','005',1
    '180411','009',2};
for i = 1:size(dd,1);
    day = dd{i,1}; unitnumber = dd{i,2}; serialno = dd{i,3};
    [fr fr_rb im_ fr_half frss] = PB_OnLineImage_SingleUnit('Alfie','test',day,unitnumber,serialno,[60 220],0);
    rr(i).fr = fr;
    rr(i).fr_rb = fr_rb;
    rr(i).im_ = im_;
    rr(i).fr_half = fr_half;
    rr(i).frss = frss;
end

for i = 1:length(rr)
    [rpca(i) rpls(i) rplc(i) sta(:,i)] = alexnetev(rr(i).fr_half,rr(i).frss,rr(i).im_,sx,resp,net,17);
end



% for i = 1:length(rr)
%     frss = rr(i).frss;
%     ev = pred_image















dd = {'180318','014',1
    '180309','009',1
    '180320','003',1
    '180322','002',1
    '180322','003',3
    '180329','009',2
    '180329','009',3
    '180402','003',1
    '180405','009',1
    '180413','003',1
    '180413','003',2
    '180413','004',1
    '180413','004',2
    '180413','006',4
    '180413','008',3
    '180413','008',4
    };

for i = 1:size(dd,1);
    day = dd{i,1}; unitnumber = dd{i,2}; serialno = dd{i,3};
    [fr fr_rb im_ fr_half frss] = PB_OnLineImage_SingleUnit('Fez','test',day,unitnumber,serialno,[100 200],0);
    rr(i).fr = fr;
    rr(i).fr_rb = fr_rb;
    rr(i).im_ = im_;
    rr(i).fr_half = fr_half;
    rr(i).frss = frss;
end


% clear all;
% [fr(:,1) junk im2(:,:,1)] = PB_OnLineImage_SingleUnit('Fez','test','180318','014',1,[100 200],0);
% [fr(:,2) junk im2(:,:,2)] = PB_OnLineImage_SingleUnit('Fez','test','180309','009',1,[100 200],0);
% [fr(:,3) junk im2(:,:,3)] = PB_OnLineImage_SingleUnit('Fez','test','180320','003',1,[100 200],0);
% [fr(:,4) junk im2(:,:,4)] = PB_OnLineImage_SingleUnit('Fez','test','180322','002',1,[100 200],0);
% [fr(:,5) junk im2(:,:,5)] = PB_OnLineImage_SingleUnit('Fez','test','180322','003',3,[100 200],0);
% [fr(:,6) junk im2(:,:,6)] = PB_OnLineImage_SingleUnit('Fez','test','180329','009',2,[100 200],0);
% [fr(:,7) junk im2(:,:,7)] = PB_OnLineImage_SingleUnit('Fez','test','180329','009',3,[100 200],0);
% [fr(:,8) junk im2(:,:,8)] = PB_OnLineImage_SingleUnit('Fez','test','180402','003',1,[100 200],0);
%
%
% frall = fr;
% k = 0;
% figure;
% set(gcf,'Position',[630   129   963   859]);
% for sz = 1:size(frall,2)
%     if k > 8;
%         figure;
%         set(gcf,'Position',[630   129   963   859]);
%
%         k = 0;
%     end
%     k = k + 1;
%
%     subplot(3,3,k);
%     hold on;
%     fr = frall(:,sz);
%     fr = reshape(fr,12,12);
%     f2 = mean(fr(12,:));
%     f1 = mean(fr(1,:));
%
%     ff = (fr-f1)/(f2-f1);
%     ff(ff<0) = 0;
%     ff(ff>1) = 1;
%
%
%     for i=1:12
%         for j = 1:12
%             scatter(i,13- j,100,[ff(i,j) 0 1-ff(i,j)],'filled');
%         end
%     end
%
%     axis equal
%     axis square;
%     axis([0 13 0 13]);
%     k = k + 1;
%     subplot(3,3,k);
%
%     plot(mean(fr,1),'bo-');
%     hold on;
%     plot(mean(fr,2),'ro-');
%
%     %legend('Othogonal','STA');
%     axis square;
%
%     k = k + 1;
%     subplot(3,3,k);
%     imshow(im2(:,:,sz),[]);
%
% end