sp = strctUnit.m_strctStimulusParams;
fdNames = fieldnames(sp);
k = 1;
for i = 1:length(fdNames)
    if ~strcmp(fdNames{i},'m_afStimulusON_ALL_MS')| strcmp(fdNames{i},'m_afStimulusOFF_ALL_MS');
        eval(['ParameterMatrix(k,:) = sp.' fdNames{i} ';']);
        k = k +1;
    end
end

 
