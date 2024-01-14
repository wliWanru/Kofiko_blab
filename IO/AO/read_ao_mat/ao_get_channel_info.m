function [times, datapoints, sample_rate] = ao_get_channel_info(mapfile, channelName)
    % Process a single channel
    times = [mapfile.(channelName).TimeEnd, mapfile.(channelName).TimeBegin];
    datapoints = length(mapfile.(channelName).Samples);
    sample_rate = mapfile.(channelName).KHz;
end
