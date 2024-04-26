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
