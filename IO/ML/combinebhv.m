function [bhvmat fn folder] = combinebhv;

folder = uigetdir('EphysData\','Pick the raw folder');
bhvlist = dir(fullfile(folder,'*.bhv2'));

bhvmat = [];

for i = 1:length(bhvlist)
    disp(['Now Read ' bhvlist(i).name]);
    bhv = mlread(fullfile(folder,bhvlist(i).name));
    bhvmat = [bhvmat bhv];
end

for i = 1:length(bhvmat)
    trialstart(i) = datenum(bhvmat(i).TrialDateTime);
end

ff = bhvlist(1).name;
index = find(ff=='_');
subjname = ff(index(1)+1:index(2)-1);

[starttime index] = sort(trialstart)

timestring = datestr(starttime(1),'yymmdd_HHMMSS');

bhvmat = bhvmat(index)

fn = [timestring '_' subjname];

savename = [fn '_ML.mat'];

save(fullfile(folder,savename),'bhvmat');
