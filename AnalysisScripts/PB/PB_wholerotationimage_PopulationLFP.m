function finalresult = PB_TwoImage_Population(region,subj);


[dd Unitlist] = ppdata(subj,region);
% switch subj
%     case 'Fez';        
%         switch region
%             case 'AMO';
%                 dd = {'160125','160127','160128','160129','160201','160216','160219','160223','160225','160229','160302'}
%                 Unitlist{1} = [1 4 5]
%                 Unitlist{2} = [1 4 5 6 9 10 15 17 18];
%                 Unitlist{3} = [1 4 6 8 10 14 15 17 18 19];
%                 Unitlist{4} = [1 2 11 12 13];
%                 Unitlist{5} = [2 8 9];
%                 Unitlist{6} = [4 5 6 7 11];
%                 Unitlist{7} = [1 2 6 7 11];
%                 Unitlist{8} = [2 3 4 9 11 13];
%                 Unitlist{9} = [ 3 6 8];
%                 Unitlist{10} = [9:11 13 18];
%                 Unitlist{11} = [4 5 9 10 16 17];
%             case 'ALO';
%                 dd = {'160304','160307','160311'}
%                 Unitlist{1} = [4:7 9 14:18 20 21];
%                 Unitlist{2} = [1 4 5 9 11];
%                 Unitlist{3} = [4 9 15 16];
%             case 'MLO'
%                 dd = {'160203','160209','160210','160212','160219'}
%                 Unitlist{1} = [1 2 4 6 8 9 10 11 13 14 15];
%                 Unitlist{2} = [ 1 5 6 13 14 15];
%                 Unitlist{3} = [8 9 11 15 17];
%                 Unitlist{4} = [9 10 11 12];
%                 Unitlist{5} = [1 2 6 7];
%             case 'ALThreed'
%                 dd = {'160504','160505','160506','160507'};
%                 Unitlist{1} = [15 17];
%                 Unitlist{2} = [6 10 11];
%                 Unitlist{3} = [8:9:10 15 21]
%                 Unitlist{4} = [12 19 20 21 13 22 25 16 17 26];
%         end
%     case 'Alfie';
%         switch region
%             case 'ALThreed'
%                 dd = {'160710','160713','160714','160715'};
%                 Unitlist{1} = [1:4 10 11 13 15 16 18];
%                 Unitlist{2} = [1 6 7 8 15 16 18 20];
%                 Unitlist{3} = [1 2 7 14 16 18 19 20 21];
%                 Unitlist{4} = [7 8 9 11 22 23];
%             case 'ABody';
%                 dd = {'160730','160805','160807','160809','160811','160819','160820'};
%                 Unitlist{1}  = [1:3 11];
%                 Unitlist{2} = [6 7 8 12 13 14 16 ];
%                 Unitlist{3} = [ 7 8 11 19 21 22]
%                 Unitlist{4} = [2 3  6 8 9 10 14 16 19 21];
%                 Unitlist{5} = [8 9 10 11 16 18 19];
%                 Unitlist{6} = [21 37 40 41 42 43 44];
%                 Unitlist{7} = [2:7 11 14 17 20 21 25];
%             case 'MBody';
%                 dd = {'160823','160901','160902','160905','160830'};
%                 Unitlist{1} = [6 9 11 18 19 20 22 26 31 33 35 36];
%                 Unitlist{2} = [15 19 21 27 34 40:42 44 45 46];
%                 Unitlist{3} = [2 4 5 12 13 16:18];
%                 Unitlist{4} = [4 6 7 9 11 14 16 17 18 20 21 22 23 24 28 31 32 33];
%                 Unitlist{5} = [16 17];
%             case 'AMB';
%                 dd = {'160907','160908','160909','160912','160914'};
%                 Unitlist{1} = [6 12];
%                 Unitlist{2} = [3 6 7 9 14 18];
%                 Unitlist{3} = [2 4 5 14 16 18 19];
%                 Unitlist{4} = [5 9 12 16 21];
%                 Unitlist{5} = [4 5 9 16 22];
%             case 'ML'
%                 dd = {'160830'}
%                 Unitlist{1} = [1 4 5 9 10 12 13 15 19 21];
%             case 'AMO'
%                 dd = {'170105','170106','170109','170112','170113','170202','170203','170205'};
%                 Unitlist{1} = [3 9 10 25];
%                 Unitlist{2} = [2 13 17 18 19 20];
%                 Unitlist{3} = [4 7 12 13];
%                 Unitlist{4} = [1:4 13 18 19 20 26];
%                 Unitlist{5} = [6 11];
%                 Unitlist{6} = [20 21];
%                 Unitlist{7} = [12];
%                 Unitlist{8} = [4 6 7 8 17:20];
%                 
%             case 'junk1'
%                 dd = {'170212','170213'};
%                 Unitlist{1} = [7 8 11 14 16 18 20 21];
%                 Unitlist{2} = [6 8 10 12];
%             case 'junk2';
%                 dd = {'170209'};
%                 Unitlist{1} = [3 4 5 7 9 11 15 17 19 20 21];
%             case 'ALO';
%                 %         dd = {'170223','170225'};
%                 %         Unitlist{1} = [19 8 22 9 23 16];
%                 %         Unitlist{2} = [10 16 18 19 22 25 26];
%                 dd = {'170225','170305'};
%                 Unitlist{1} = [10 16 18 19 22 25 26];
%                 Unitlist{2} = [4:8 11:13 16 17 19:21];
%             case 'MLO';
%                 
%         end
% end

k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['C:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
        xx = dir([Datafolder '*.mat']);
        for j = 1:length(xx)
            fn = xx(j).name;
            tt = find(fn == '_');
            unitnumber(j) = str2num(fn(tt(8)+1:tt(9)-1));
        end
        unitnumber = unique(unitnumber);
    end
    for j = 1:length(unitnumber)
        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]
        fr = PB_wholerotationimage_LFP(subj,'Test',ExpDate,unitstr,0);
        if ~isnan(fr) & size(fr,2) == 1101;
            frall(:,:,k) = fr;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.fr = frall;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save(['C:\PB\RotationImages\' subj '_RotationImage_populationLFP_' region '.mat'], 'finalresult');

return;

clear all;
region = 'ALThreed';
load(['\C:\PB\RotationImages\Fez_RotationImage_populationLFP_' region '.mat']);
fr = finalresult.populationresult;
for i = 1:size(fr,3);
    ff = fr(:,:,i);
    ff = ff/mean(ff);
    allrr(:,:,i) = reshape(ff,24,51);
end

rr = allrr(1:8,:,:);
sz = size(rr,1);
for i = 1:sz
    for j = 1:51
        for k = 1:sz
            for m = 1:51
                tt = corrcoef(squeeze(rr(i,j,:)),squeeze(rr(k,m,:)));
                im((i-1)*51+j,(k-1)*51+m) = tt(1,2);
            end
        end
    end
end

rr = allrr;
sz = size(rr,1);
for i = 1:sz
    for j = 1:51
        for k = 1:sz
            for m = 1:51
                tt = corrcoef(squeeze(rr(i,j,:)),squeeze(rr(k,m,:)));
                im((i-1)*51+j,(k-1)*51+m) = tt(1,2);
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CorrelationMatrix

load('C:\PB\Stimuli\RotationImages\imall.mat');
imall = double(imall);
load('C:\PB\RotationImages\Fez_RotationImage_population.mat');
fr = finalresult.populationresult;
fr = squeeze(fr);
for i = 1:size(fr,2);
    ff = fr(:,i);
    dd = ones(1,1,length(ff));
    dd(1,1,:) = ff;
    dd = repmat(dd,[200,200,1]);
    imt = sum((dd.*imall),3)/sum(squeeze(ff));
    for j = 1:1000
        ft = ff(randperm(length(ff)));
        dt = ones(1,1,length(ft));
        dt(1,1,:) = ft;
        dt = repmat(dt,[200,200,1]);
        imr(:,:,j) = sum((dt.*imall),3)/sum(squeeze(ft));
        if mod(j,50) == 0
            disp('ok');
        end
        
    end
    z_score = abs(imt - mean(imr,3))/std(imr,0,3);
    subplot(1,2,1);
    imshow(imt,[]);
    subplot(1,2,2);
    imshow(z_score,[]);
    pause;
end






