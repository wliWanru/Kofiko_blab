function [times, datapoints, sample_rate] = ao_get_channel_info(mapfile, channelName)
    % Process a single channel
    times = [mapfile.(channelName).TimeBegin, mapfile.(channelName).TimeEnd];
    if isfield(mapfile.(channelName),'Samples')
    datapoints = length(mapfile.(channelName).Samples);
    else
        datapoints = nan;
    end
    sample_rate = mapfile.(channelName).KHz;
end
