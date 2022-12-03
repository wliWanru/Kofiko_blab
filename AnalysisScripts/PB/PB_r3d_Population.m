function finalresult = PB_TwoImage_Population
dd = {'151210','151213'};
Unitlist{1} = [1 2 5 6 8 9 10 11 13 16 17 18];
Unitlist{2} = [1 2 6 7 9 12 16 17 ];
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
        output = PB_r3d_SingleUnit(Subject,'Test',ExpDate,unitstr,0)
        if ~isnan(output)
            populationresult(:,k) = output;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('D:\PB\ObjectRegion\Fez_r3d_population.mat', 'finalresult');

return;
close all;
clear all;
load('D:\PB\ObjectRegion\Fez_r3d_population.mat');
load('D:\PB\ObjectRegion\windex.mat');

populationresult = finalresult.populationresult;

for i = 1:size(populationresult,2);
    tt = populationresult(:,i);
    tt = tt/mean(tt(:));
    response(:,i) = tt;
end
response(windex,:) = [];
allrr = reshape(response,11,57,size(response,2));
%rr = rr([1 3 5 8 10],:,:);
% clear im;
% rr = allrr;
% sz = size(rr,1);
% for i = 1:sz
%     for j = 1:57
%         for k = 1:sz
%             for m = 1:57
%                 tt = corrcoef(rr(i,j,:),rr(k,m,:));
%                 im((i-1)*57+j,(k-1)*57+m) = tt(1,2);
%             end
%         end
%     end
% end
% 
clear im;
rr = allrr([1 3 5 8 10],:,:);
sz = size(rr,1);
for i = 1:sz
    for j = 1:57
        for k = 1:sz
            for m = 1:57
                tt = corrcoef(rr(i,j,:),rr(k,m,:));
                im((i-1)*57+j,(k-1)*57+m) = tt(1,2);
            end
        end
    end
end
subplot(1,2,1)
imshow(1-im,[]);
im1 = 1-im;

clear im;

rr = allrr([2 4 6 9 11],:,:);
sz = size(rr,1);
for i = 1:sz
    for j = 1:57
        for k = 1:sz
            for m = 1:57
                tt = corrcoef(rr(i,j,:),rr(k,m,:));
                im((i-1)*57+j,(k-1)*57+m) = tt(1,2);
            end
        end
    end
end
subplot(1,2,2)
imshow(1-im,[]);
im2 = 1- im;