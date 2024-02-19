for idx_f = 1:n_record_files
    i_mapfile = all_files(idx_f).data;
    double(i_mapfile.(ch_name_SEG).('LEVEL')(1)) / i_att_SampleRate
    double(i_mapfile.(ch_name_SEG).('LEVEL')(end)) / i_att_SampleRate
end
