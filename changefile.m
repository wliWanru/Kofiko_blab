function acSessions = changefile(acSessions)

for i = 1:length(acSessions)
    i
    if strcmpi(acSessions{i}.m_strSubject,'fez') || strcmpi(acSessions{i}.m_strSubject,'Alfie')
    else
        acSessions{i}.m_strKofikoFullFilename  = switchname( acSessions{i}.m_strKofikoFullFilename);
        for j = 1:length(acSessions{i}.acDataEntries)
            acSessions{i}.acDataEntries{j}.m_strFile = switchname(acSessions{i}.acDataEntries{j}.m_strFile);
        end
    end
end


















function kfname = switchname(kfname);

index = find(kfname == '\');
kfname(1:index(3)-1) = [];
kfname = ['D:\PB2\EphysData' kfname];
