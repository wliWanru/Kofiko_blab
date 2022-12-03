addpath('C:\PB\KofikoPB\trunk\AnalysisScripts\PB');
cd('C:\PB\EphysData');

subjlist = {'Rocco','Ozomatli','Fez','Alfie','Houdini'};
Exp = {'Test','','Test','Test','test'};

index = 1;
for i = 1:length(subjlist)
    cd(subjlist{i});
    if ~(isempty(Exp{i}))
        cd(Exp{i});
    end
    xx = dir;
    for j = 1:length(xx)
        fn = xx(j).name;
        pp = pwd;
        if isdir(fn) && strcmp(fn(1),'1');
            cd(fn);
            fn
            if isdir('Processed');
                cd('Processed')
                if isdir('SingleUnitDataEntries');
                    cd('SingleUnitDataEntries');
                    zz = dir('*PB_TwoImage_0908.mat');
                    for k = 1:length(zz)
                        mn = zz(k).name;
                        output = PB_TwoImage_SingleUnit_mat(mn);
                        if ~isnan(output)
                            alloutput(:,:,:,index) = output;
                            allsubj{index} = subjlist{i};
                            allexp{index} = Exp{i};
                            alldate{index} = fn;
                            underscoreindex = find(mn == '_');
                            allneuron{index} = mn(underscoreindex(6)+1:underscoreindex(7)-1);
                            index = index + 1;
                            index
                        end
                    end
                end
            end
        end
        cd(pp);
    end
    cd('C:\PB\EphysData');
end

k = 1;

cc = {'ko-','ro-','bo-'};
ss = zeros(length(allexp),1);
for j = 1:size(alloutput,4)
    j
    close all;
    response = alloutput(:,:,:,j);
    if strcmp(allsubj{j},'Alfie');
        obj = squeeze(response(2,3,:));
        face = squeeze(response(2,2,:));
        response = response(3:-1:2,:,:);
    else
        obj = squeeze(response(3,3,:));
        face = squeeze(response(3,2,:));
        response = response(2:3,:,:);
    end
    
    
    if mean(obj) > mean(face);
        figure;
        for i = 1:2
            subplot(1,2,i);
            for ii = 1:3;
                plot(10:20:90,squeeze(response(i,ii,:)),cc{ii},'linewidth',2);
                hold on;
            end
            box off
            set(gca,'Linewidth',2);
            set(gca,'FontSize',12);
        end
        incl = 0;
        while ~(incl == 1 || incl == 2)
            incl = input('Accept\n');
            if incl == 1;
                newoutput(:,:,:,k) = response;
                k = k + 1;
                ss(j) = 1;
            elseif incl == 2;
            else
                incl = 0;
            end
        end
    end
end


for i = 1:size(newoutput,4);
    kk = newoutput(:,:,:,i);
    newoutput(:,:,:,i) = kk / mean(kk(:));
end

response = mean(newoutput,4);
se = std(newoutput,0,4)/sqrt(size(newoutput,4));

for i = 1:2
    subplot(1,2,i);
    for j = 1:3;
        errorbar(10:20:90,squeeze(response(i,j,:)),squeeze(se(i,j,:)),cc{j},'linewidth',2);
        hold on;
    end
    box off
    set(gca,'Linewidth',1);
    set(gca,'FontSize',12);
    set(gca,'XTick',10:20:90)
end

