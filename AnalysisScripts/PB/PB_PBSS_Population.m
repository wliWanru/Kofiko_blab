function finalresult = PB_TwoImage_Population
dd = {'161123','161125'};
Unitlist{1} = [2 3 4 9 12 13];
Unitlist{2}= [7];


Subject = 'Alfie';
k = 1; dataentry_date{1} = '';
for i = 1:length(dd)
    ExpDate = dd{i};
    unitnumber = Unitlist{i};
    if unitnumber == 0
        Datafolder = ['D:\PB\EphysData\' Subject '\test\' ExpDate '\Processed\SingleUnitDataEntries\'];
        xx = dir([Datafolder '*.mat']);
        for j = 1:length(xx)
            fn = xx(j).name;
            tt = find(fn == '_');
            unitnumber(j) = str2num(fn(tt(8)+1:tt(9)-1));
        end
        unitnumber = unique(unitnumber);
    end
    for j = 1:length(unitnumber)
        close all;
        
        if unitnumber(j) < 10
            unitstr = ['00' num2str(unitnumber(j))];
        elseif unitnumber(j)<100
            unitstr = ['0' num2str(unitnumber(j))];
        else
            unitstr = num2str(unitnumber(j));
        end
        
        [ExpDate unitstr]
        output = 
        (Subject,'Test',ExpDate,unitstr)
        populationresult{k} = output;
        dataentry_date{k} = dd{i};
        dataentry_unitnumber{k} = unitstr;
        k = k + 1;
    end
end

finalresult.populationresult = populationresult;
finalresult.dataentry_date = dataentry_date;
finalresult.dataentry_unitnumber = dataentry_unitnumber;
save('C:\PB\RotationImages\Alfie_PBSS_population.mat', 'finalresult');

return;

load('C:\PB\RotationImages\Alfie_PBSS_population.mat');
populationresult = finalresult.populationresult;
for i = 1:length(populationresult)
    pp = populationresult{i};
    fr = pp.fr;
    fr(isnan(fr)) = 0;
    flag = pp.flag;
    if flag == 1;
        load('C:\PB\RotationImages\artifical2\pp.mat');
    else
        load('C:\PB\RotationImages\artifical3\pp.mat');
    end
    sc = std(score,0,1);
    ts = xx.* repmat(sc(1:30),size(xx,1),1);
    for k = 1:size(ts,1);
        vv(k) = norm(ts(k,:));
    end
    factor = mean(vv);
    xx = ts/factor;
    ss = reshape(score,24,51,200);
    ss = ss(1:8,:,:);
    ss = reshape(ss,8*51,200);
    ss = ss(:,1:30)/factor;
    xx = xx*2; ss = ss *2;
    m = fitrsvm(xx,fr(1:2000,1),'KernelFunction','gaussian');
    pobj = predict(m,ss);
    ml = fitrsvm(xx,fr(1:2000,1),'KernelFunction','linear');
    plobj = predict(ml,ss);
    tt = corrcoef(pobj,fr(end-407:end));
    r(i,1) = tt(1,2);
    tt = corrcoef(plobj,fr(end-407:end));
    r(i,2) = tt(1,2);
    i
end
