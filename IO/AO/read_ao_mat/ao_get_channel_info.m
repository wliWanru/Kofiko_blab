function [times, datapoints, sample_rate] = ao_get_channel_info(mapfile, channelName)
    % Process a single channel
    times = [mapfile.(channelName).TimeBegin, mapfile.(channelName).TimeEnd];
    datapoints = length(mapfile.(channelName).Samples);
    sample_rate = mapfile.(channelName).KHz;
end
