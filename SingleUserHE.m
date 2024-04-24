 % Defining a wlanHESUConfig object for a single-user transmission
SU = wlanHESUConfig;
SU.ExtendedRange = false;          % Not using extended-range format
SU.ChannelBandwidth = 'CBW20';     % Channel bandwidth
SU.APEPLength = 1000;              % Length of the MAC Protocol Data Unit (MPDU) payload 
SU.MCS = 0;                        % Modulation and coding scheme
SU.ChannelCoding = 'LDPC';         % Low-Density Parity-Check (LDPC) coding is used for error correction
SU.NumSpaceTimeStreams = 4;        % Number of space-time streams
SU.NumTransmitAntennas = 4;        % Number of transmit antennas

% Generating random PSDU data which is a random binary sequence 
psdu = randi([0 1], getPSDULength(SU) * 8, 1, 'int8'); 

% Creating the transmit waveform
txSUWaveform = wlanWaveformGenerator(psdu, SU);

% Spectrum analysis setup
fs = wlanSampleRate(SU); 
ofdmInfo = wlanHEOFDMInfo('HE-Data', SU); % Extracts OFDM parameters for the 'HE-Data' field
fftsize = ofdmInfo.FFTLength;
rbw = fs / fftsize; % Resolution bandwidth

% Configure the spectrum analyzer
spectrumScope = spectrumAnalyzer('SampleRate', fs, ...
    'RBWSource', 'Property', 'RBW', rbw, ...
    'AveragingMethod', 'Exponential', 'ForgettingFactor', 0.25, ...
    'YLimits', [-50, 20], ...
    'Title', 'IEEE 802.11ax HE SU Transmission Spectrum', ...
    'SpectrumUnits', 'dBm', ...
    'ViewType', 'Spectrum and Spectrogram', ...
    'TimeSpanSource', 'Property', 'TimeSpan', length(txSUWaveform) / fs);

% Visualizing the spectrum of the transmission
spectrumScope(txSUWaveform);

%{
OUTPUT:
Top Panel (Spectrum View): This shows the power of the signal across different frequencies. 
The x-axis is frequency, and the y-axis is power in dBm. The sharp drop-offs on the sides are 
due to the filtering of the signal, which limits the bandwidth to the configured CBW20 
(20 MHz channel bandwidth). The relatively flat line across the channel indicates 
that the transmission power is spread evenly across the utilized frequency spectrum.

Bottom Panel (Spectrogram View): This view shows how the signal's frequency content evolves over time. 
The x-axis is frequency, the y-axis is time, and the colors represent signal power at 
different frequencies over time. Here, the consistent coloration across time indicates a steady, 
continuous transmission without frequency hopping or variation in signal power. 
The bright vertical lines at the edges represent the transition periods where 
the signal starts or ends, with higher power due to transient effects.

The output confirms that a standard Wi-Fi signal was generated according to the IEEE 802.11ax 
specifications and visualized over the course of the transmission. The signal maintains its 
characteristics over the duration of the transmission, as expected for a typical Wi-Fi signal 
without any external interference or channel effects.
%}