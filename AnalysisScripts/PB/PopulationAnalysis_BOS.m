dd = {'071114_14','140715','140721','140722','140731','140804','140813'}
k = 1;
Subject = 'Rocco';
for i = 1:length(dd)
    ExpDate = dd{i};   
Datafolder = ['D:\PB\EphysData\' Subject '\Test\' ExpDate '\Processed\SingleUnitDataEntries\'];
xx = dir([Datafolder '*.mat']);
for j = 1:length(xx)
    fn = xx(j).name;
    tt = find(fn == '_');
    unitnumber(j) = str2num(fn(tt(8)+1:tt(9)-1));
end
unitnumber = unique(unitnumber)
for j = 1:length(unitnumber)
    rr(:,k) = zeros(4,1);
    if unitnumber(j) < 10
        unitstr = ['00' num2str(unitnumber(j))];
    else
                unitstr = ['0' num2str(unitnumber(j))];
    end
    try
        rr(:,k) = simplestim_BOS(ExpDate,unitstr)
    catch ME
        
    end
    k = k + 1;
end
end
 
tt = mean(rr);
rr(:,find(tt==0))=[];
for i = 1:size(rr,2);
        index = (rr(1,i) + rr(3,i))/(rr(2,i) + rr(4,i));
        if index < 1
            index = 1/index;
        end
        BOSIndex(i) = index;
end
