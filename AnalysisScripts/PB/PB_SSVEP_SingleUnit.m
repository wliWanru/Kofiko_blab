function OcclusionAnalysis(subjID,experiment,foldername,unitnumber)
usePB = 1;
%subjID = 'Rocco'; experiment = 'test'; foldername = '140827'; unitnumber = '008';
matpath = ['D:\PB\EphysData\' subjID '\' experiment '\' foldername '\Processed\SingleUnitDataEntries\'];
mat = dir([matpath '*_Unit_' unitnumber '_Passive_Fixation_New_PB_SSVEP_*.mat']);
if ~isempty(mat)
    strctUnit = load([matpath mat(1).name]);
    strctUnit = strctUnit.strctUnit;
else
    output = nan;
    return;
end

avgfiring =  1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
    strctUnit.m_aiStimulusIndexValid,...
    diag(1:max(strctUnit.m_aiStimulusIndexValid))>0,3,...
    0);
rr = avgfiring(1,201:end);


lfp = fnAverageBy(strctUnit.m_a2fLFP(strctUnit.m_abValidTrials,:), strctUnit.m_aiStimulusIndexValid, diag(1:max(strctUnit.m_aiStimulusIndexValid))>0,0);
rr2 = lfp(1,201:end);
subplot(2,2,1);
plot(rr);

Fs = 1000;
N = length(rr);
xdft = fft(rr);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(rr):Fs/2;
subplot(2,2,2);

plot(freq,10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
subplot(2,2,3);
plot(rr2);
fs = 1000;
N = length(rr2);
xdft = fft(rr2);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(rr2):Fs/2;
subplot(2,2,4);

plot(freq,10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')


figure;
rr = avgfiring(151,201:end);
rr2 = lfp(151,201:end);
plot(freq,10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
subplot(2,2,3);
plot(rr2);
fs = 1000;
N = length(rr2);
xdft = fft(rr2);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(rr2):Fs/2;
subplot(2,2,4);

plot(freq,10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
