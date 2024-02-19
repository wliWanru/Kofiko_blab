function ao = transfermat(matfile1);
bo = load(matfile1);

fd = fieldnames(bo);

for i = 1:size(bo.Channel_ID_Name_Map,1)
    cn = bo.Channel_ID_Name_Map(i).Name;
    index = (cn==' ');
    try
        ao.(cn).ID = bo.Channel_ID_Name_Map(i).ID;
    catch
        cn(end) = [];
        ao.(cn).ID = bo.Channel_ID_Name_Map(i).ID;
    end
    for j = 1:length(fd)
        if length(fd{j}) < length(cn)
        else
            if strcmpi(fd{j}(1:length(cn)),cn)
                if length(fd{j}) == length(cn) % identical
                    ao.(cn).Samples = bo.(cn);
                else
                    parameter = fd{j}(length(cn)+2:end);
                    ao.(cn).(parameter) = bo.(fd{j});
                end
            end
        end
    end
end

for i = 1:size(bo.Ports_ID_Name_Map,1)
    cn = bo.Ports_ID_Name_Map(i).Name;
    if strcmpi(cn,'CInPort_001')
        ao.(cn).ID = bo.Ports_ID_Name_Map(i).ID;
        for j = 1:length(fd)
            if length(fd{j}) < length(cn)
            else
                if strcmpi(fd{j}(1:length(cn)),cn)
                    if length(fd{j}) == length(cn) % identical
                        ao.(cn).Samples = bo.(cn);
                    else
                        parameter = fd{j}(length(cn)+2:end);
                        ao.(cn).(parameter) = bo.(fd{j});
                    end
                end
            end
        end
    end
end


