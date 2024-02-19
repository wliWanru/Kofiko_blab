function downsampled_spike_waveforms = downsampleSpikesFast(spike_waveforms, n_waveform_shorter)
    % Transpose spike_waveforms to make each spike waveform a column
    spike_waveforms = spike_waveforms';

    % Original number of samples
    original_length = size(spike_waveforms, 1);

    % New number of samples (assumes n_waveform_shorter is the target length for each waveform)
    desired_length = n_waveform_shorter;

    % Calculate resampling factors
    p = desired_length; % New sample rate factor
    q = original_length; % Original sample rate factor

    % Use resample function directly on the transposed matrix
    downsampled_spike_waveforms = resample(spike_waveforms, p, q);

    % Transpose the result back to the original orientation
    downsampled_spike_waveforms = downsampled_spike_waveforms';
end
