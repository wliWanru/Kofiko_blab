function finalresult = PB_TwoImage_Population
dd = {'160125','160127','160128','160129'}
Unitlist{1} = [1 4 5]
Unitlist{2} = [1 4 5 6 9 10 15 17 18];
Unitlist{3} = [1 4 6 8 10 14 15 17 18 19];
Unitlist{4} = [1 2 11 12 13];

Subject = 'Fez';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
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
        output = PB_wholerotationimage_SingleUnit('Fez','Test',ExpDate,unitstr,0)
        if ~isnan(output)
            populationresult(:,:,k) = output;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('C:\PB\RotationImages\Fez_RotationImage_population.mat', 'finalresult');

return;

clear all;
load('C:\PB\RotationImages\Fez_RotationImage_population.mat');
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


        



