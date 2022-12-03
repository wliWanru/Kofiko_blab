function finalresult = PB_TwoImage_Population(subj,region);


%[dd Unitlist] = ppdata('Alfie',region);

if strcmp(subj,'Alfie');
    if strcmp(region,'ALO');
        dd = {'170728','170726','170723','170712','170710'};
        Unitlist{1} = [5 6 17 19 20 21];
        Unitlist{2} = [2 3 7 9 10 16];
        Unitlist{3} = [1 2 8 11 12 16 18 19];
        Unitlist{4} = [3 12:14];
        Unitlist{5} = [7 8 9 11 12];
    elseif strcmp(region,'AMO');
        dd = {'170813','170811','170810','170821','170819','170817','170815'};
        Unitlist{1} = [10 11 17 31];
        Unitlist{2} = [3 5 11 12];
        Unitlist{3} = [19 20 21];
        Unitlist{4} = [9 17 24];
        Unitlist{5} = [4 5 7 8];
        Unitlist{6} = [];
        Unitlist{7} = [10 13 15 16 18 21];
    end
elseif strcmp(subj,'Fez');
    if strcmp(region,'AMO');
        dd = {'170710','170714','170727'};
        Unitlist{1} = [2 4 8];
        Unitlist{2} = [32];
        Unitlist{3} = [25 27 28];
    end
end





k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    close all;
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' subj '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
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
        [fr fr_rb consistency] = PB_PNG_singleUnit(subj,'Test',ExpDate,unitstr);
        if ~isnan(fr)
            frall(:,k) = fr;
            fr_rball(:,k) = fr_rb;
            cc(:,k) = consistency;
            dataentry_date{k} = dd{i};
            dataentry_unitnumber{k} = unitstr;
            k = k + 1;
        end
    end
end

finalresult.fr = frall;
finalresult.fr_rb = fr_rball;
finalresult.consistency = cc;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save(['C:\PB\RotationImages\' subj '_PNG_' region '.mat'], 'finalresult');

return;

subjlist = {'Alfie','Fez'};
regionlist = {'ALO','AMO'};

for rl = 1:length(regionlist)
    region = regionlist{rl};
    fball = []; ccall = [];
    for j = 1:length(subjlist);
        subj = subjlist{j};
        fn = ['C:\PB\RotationImages\' subj '_PNG_' region '.mat'];
        if exist(fn,'file');
            load(fn);
            
            fb = finalresult.fr_rb;
            cc = finalresult.consistency;
            fball = cat(2,fb,fball);
            ccall = cat(2,cc,ccall);
        end
    end
    fb = fball;
    index = ccall>0;

    for i = 1:size(fb,2);
        fb(:,i) = zscore(fb(:,i));
    end
    fr(:,rl) = mean(fb(:,index),2);
end
load('C:\PB\RotationImages\impngonlyobj');imall = im;

figure;
subplot(1,3,1);
[junk index] = sort(fr);
index = index(end:-1:end-63);
imt = moscicimage(imall,index);
imshow(uint8(imt));


subplot(1,3,3);
[junk index] = sort(fr);
index = index(1:64);
imt = moscicimage(imall,index);
imshow(uint8(imt));

subplot(1,3,2);
[junk index] = sort(fr);
index = index(224-32:224+31);
imt = moscicimage(imall,index);
imshow(uint8(imt));


subj = 'Alfie';
region = 'ALO';


load(['C:\PB\RotationImages\' subj '_PNG_' region '.mat']);
index = finalresult.consistency > 0.4;

fr = finalresult.fr;
fr = fr(:,index);

for i = 1:size(fr,2);
    fr(:,i) = (fr(:,i))/std(fr(:,i));
end
D = pdist(fr,'euclidean');
[Y,stress,disparities] = mdscale(D,2);
for i = 1:size(fr,1)
    sim{i} = imall(:,:,i);
    cc(i,:) = [1 1 1];
end
imbk = showmds_image_color(Y,sim,1000,25,cc);


