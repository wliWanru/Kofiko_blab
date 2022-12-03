function finalresult = PB_TwoImage_Population
dd = {'150325','150401','150403'}
Unitlist{1} = [1 2 3 5 6 7 8 9 10 12 15 20 21]
Unitlist{2} = [13:19 24 36];
Unitlist{3} = [4:7 9:12 17:22 27];

Subject = 'Rocco';
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
        output = PB_TwoImageContrast_SingleUnit('Rocco','Test',ExpDate,unitstr,0)
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
save('D:\PB\TwoImageResult\Rocco_TwoImageContrast_population.mat', 'finalresult');

return;

clear all;
load('D:\PB\TwoImageResult\Rocco_TwoImageContrast_population.mat');
populationresult = finalresult.populationresult;

for i = 1:size(populationresult,2);
    tt = populationresult(:,i);
    tt = tt/mean(tt(:));
    response(:,i) = tt;
end

fr = mean(response,2);
strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\TwoImageContrast\TwoImageContrast.xml', false, false);
for i = 1:length(strctDesign.m_astrctMedia);
    filename{i} = strctDesign.m_astrctMedia(i).m_strName;
end

for i = 1:length(filename)
    fn = filename{i};
    xx = find(fn == '_');
    Name1 = fn(1:xx(1)-1);
    CondMatrix(i,1) = findcond(Name1);
    Name2 = fn(xx(1)+1:xx(2)-1);
    CondMatrix(i,2) = findcond(Name2);
    CC1 = fn(xx(2)+1:xx(2)+3);
    CondMatrix(i,3) = str2num(CC1(end-1:end));
    CC2 = fn(xx(3)+1:xx(3)+3);
    CondMatrix(i,4) = str2num(CC2(end-1:end));
    if strcmpi(CC1(1),'l') && strcmpi(CC2(1),'r');
        CondMatrix(i,5) = 1;
    else
        CondMatrix(i,5) = 2;
    end
end





for i = 10:20:90
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i  & CondMatrix(:,5) == 2);
    ff((i+10)/20,1) = fr(index);
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,5) == 1);
    ff((i+10)/20,2) = fr(index);
    index = find(CondMatrix(:,1) == 0 & CondMatrix(:,2) == 1 & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
    ff((i+10)/20,3) = fr(index);
end

for i = 10:20:90
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,4) == i  & CondMatrix(:,5) == 2);
    oo((i+10)/20,1) = fr(index);
    index = find(CondMatrix(:,1) == 0 & CondMatrix(:,2) == 4 & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
    oo((i+10)/20,2) = fr(index);
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,5) == 1);
    oo((i+10)/20,3) = fr(index);
end

figure;
for i = 10:20:90
    for j = 10:20:90
        index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == j & CondMatrix(:,5) == 2);
        m = (i+10)/20; n = (j+10)/20;
        resp(m,n) = fr(index);
    end
end

cc = {'ro-','go-','bo-','co-','ko-'}
subplot(2,3,1);
for i = 1:5
    hold on;
    plot(10:20:90,resp(i,:),cc{i},'linewidth',2);
    plot(100,oo(i,1),cc{i},'linewidth',3);
end
% ff1 = mean(ff(:,1)); oo1 = mean(oo(:,1));
% for i = 1:5
%     subplot(1,5,i);
%     plot(10:20:90,resp(i,:),cc{i},'linewidth',2);
%     hold on;
%     for j = 1:5
%         R(j) = ff1*i/(i+j)+oo1*j/(i+j)
%     end
%         plot(10:20:90,R,[cc{i} '-']);
% end


subplot(2,3,4);
for i = 1:5
    hold on;
    plot(10:20:90,resp(:,i),cc{i},'linewidth',2);
    plot(100,ff(i,1),cc{i},'linewidth',3);
    
end

for i = 10:20:90
    for j = 10:20:90
        index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == j & CondMatrix(:,5) == 1);
        m = (i+10)/20; n = (j+10)/20;
        resp(m,n) = fr(index);
    end
end

subplot(2,3,2);
for i = 1:5
    hold on;
    plot(10:20:90,resp(i,:),cc{i},'linewidth',2);
    plot(100,oo(i,2),cc{i},'linewidth',3);
end

subplot(2,3,5);
for i = 1:5
    hold on;
    plot(10:20:90,resp(:,i),cc{i},'linewidth',2);
    plot(100,ff(i,2),cc{i},'linewidth',3);
end


for i = 10:20:90
    for j = 10:20:90
        index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == j & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
        m = (i+10)/20; n = (j+10)/20;
        resp(m,n) = fr(index);
    end
end

subplot(2,3,3);
for i = 1:5
    hold on;
    plot(10:20:90,resp(i,:),cc{i},'linewidth',2);
    plot(100,oo(i,3),cc{i},'linewidth',3);
end

subplot(2,3,6);
for i = 1:5
    hold on;
    plot(10:20:90,resp(:,i),cc{i},'linewidth',2);
    plot(100,ff(i,3),cc{i},'linewidth',3);
end

for i = 1:6
    subplot(2,3,i);
    axis([0 110 0 max(fr)+0.1]);
end

figure;

for i = 10:20:90
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 2);
    m = (i+10)/20;
    RR(m,1) = fr(index);
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 2);
    RR(m,2) = fr(index);
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 2);
    RR(m,3) = fr(index);
end

subplot(1,3,1);
cc = {'ko--','ro-','bo-'};
for j = 1:3;
    plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
    hold on;
end

for i = 10:20:90
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 1);
    m = (i+10)/20;
    RR(m,1) = fr(index);
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 1);
    RR(m,2) = fr(index);
    index = find(CondMatrix(:,1) == 0 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i & CondMatrix(:,5) == 1);
    RR(m,3) = fr(index);
end

subplot(1,3,2);
cc = {'ko--','ro-','bo-'};
for j = 1:3;
    plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
    hold on;
end

for i = 10:20:90
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
    m = (i+10)/20;
    RR(m,1) = fr(index);
    index = find(CondMatrix(:,1) ==  0 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
    RR(m,2) = fr(index);
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i & CondMatrix(:,5) == 1);
    RR(m,3) = fr(index);
end


subplot(1,3,3);
cc = {'ko--','ro-','bo-'};
for j = 1:3;
    plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
    hold on;
end