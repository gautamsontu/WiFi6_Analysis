% Defining a wlanHESUConfig object for a extended single-user transmission
ExtSU = wlanHESUConfig;
ExtSU.ChannelBandwidth = 'CBW20'; % Channel bandwidth
ExtSU.APEPLength = 1000;          % Payload length in bytes
ExtSU.MCS = 0;                    % Modulation and coding scheme
ExtSU.ChannelCoding = 'LDPC';     % Channel coding
ExtSU.NumSpaceTimeStreams = 2;    % Number of space-time streams
ExtSU.NumTransmitAntennas = 2;    % Number of transmit antennas

ExtSU.ExtendedRange = true;  % Enabled extended-range format
ExtSU.Upper106ToneRU = true; % Using only upper 106-tone RU

% Generating a packet
psdu = randi([0 1],getPSDULength(ExtSU)*8,1,'int8'); % Random PSDU
txExtSUWaveform = wlanWaveformGenerator(psdu,ExtSU);   % Creating packet

fs = wlanSampleRate(ExtSU); % Getting baseband sample rate
fprintf('%i\n', fs)
ofdmInfo = wlanHEOFDMInfo('HE-Data',ExtSU);
fftsize = ofdmInfo.FFTLength; % Using the data field fft size
rbw = fs/fftsize; % Resoluton bandwidth
fprintf('%i\n', rbw)
spectrumScope = spectrumAnalyzer(SampleRate=fs,...
    RBWSource='property',RBW=rbw,...
    AveragingMethod='exponential',ForgettingFactor=0.25,...
    YLimits=[-50,20],...
    Title='HE Extended-Range SU with Active Upper 106-Tone RU');
spectrumScope.ViewType = 'Spectrum and Spectrogram';
spectrumScope.TimeSpanSource = 'Property';
spectrumScope.TimeSpan = length(txExtSUWaveform)/fs;
spectrumScope(txExtSUWaveform)

%{
OUTPUT:
Top Panel (Spectrum View): This view shows the power of the signal across different frequencies. 
You can see the full use of the bandwidth during the packet headers, indicated by a wider 
spectral footprint at the beginning of the transmission.

Bottom Panel (Spectrogram View): The spectrogram shows signal utilization over time, 
with colors representing signal power. It illustrates that only the upper part of the channel 
is used for the data portion of the packet, as evidenced by the energy concentration on the 
right side of the frequency band over time.
%}
