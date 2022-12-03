function finalresult = PB_TwoImage_Population
dd = {'150325','150401','150403'};
Unitlist{1} = [1 3 5 6 10];
Unitlist{2} = [13:19  36];
Unitlist{3} = [4 5 6 7 9 10 11 12 20 21 22 24 26 27];
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
        output = PB_TwoImageUpDown_LFP('Rocco','Test',ExpDate,unitstr,0)
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
save('C:\PB\TwoImageResult\Rocco_TwoImageUpDown_LFP_population.mat', 'finalresult');

return;
close all;
clear all;
load('C:\PB\TwoImageResult\Rocco_TwoImageUpDown_LFP_population.mat');
populationresult = finalresult.populationresult;

pp = mean(populationresult,3);




strctDesign = fnParsePassiveFixationDesignMediaFiles('\\192.168.50.15\StimulusSet\TwoImagesUpDown\TwoImageUpdown.xml', false, false);
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
end

% figure;
% 
% 
% cc = {'ro-','go-','bo-','co-','ko-'}
% 
% for i = 10:20:90
%     for j = 10:20:90
%         index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == j);
%         m = (i+10)/20; n = (j+10)/20;
%         resp(m,n) = fr(index);
%     end
% end
% 
% subplot(2,2,1);
% for i = 1:5
%     hold on;
%     plot(resp(i,:),cc{i},'linewidth',2);
% end
% 
% subplot(2,2,3);
% for i = 1:5
%     hold on;
%     plot(resp(:,i),cc{i},'linewidth',2);
% end
% 
% 
% for i = 10:20:90
%     for j = 10:20:90
%         index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == j & CondMatrix(:,4) == i);
%         m = (i+10)/20; n = (j+10)/20;
%         resp(m,n) = fr(index);
%     end
% end
% 
% subplot(2,2,2);
% for i = 1:5
%     hold on;
%     plot(resp(i,:),cc{i},'linewidth',2);
% end
% 
% subplot(2,2,4);
% for i = 1:5
%     hold on;
%     plot(resp(:,i),cc{i},'linewidth',2);
% end


figure;

for i = 10:20:90
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i);
    m = (i+10)/20;
    RR1(m,:,3) = pp(index,:);
    index = find(CondMatrix(:,1) == 1 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i);
    RR1(m,:,1) = pp(index,:);
    index = find(CondMatrix(:,1) == 0 & CondMatrix(:,2) == 4 & CondMatrix(:,3) == i & CondMatrix(:,4) == 100-i);
    RR1(m,:,2) = pp(index,:);
end



for i = 10:20:90
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i);
    m = (i+10)/20;
    RR2(m,:,3) = pp(index,:);
    index = find(CondMatrix(:,1) ==  0 & CondMatrix(:,2) == 1 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i);
    RR2(m,:,1) = pp(index,:);
    index = find(CondMatrix(:,1) == 4 & CondMatrix(:,2) == 0 & CondMatrix(:,3) == 100-i & CondMatrix(:,4) == i);
    RR2(m,:,2) = pp(index,:);
end


subplot(1,2,2);
cc = {'ko--','ro-','bo-'};
for j = 1:3;
    plot(10:20:90,squeeze(RR(:,j)),cc{j},'linewidth',2);
    hold on;
end