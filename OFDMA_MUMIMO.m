%MU-MIMO configuring : 4 users using one 242-tone RU
cfgMUMIMO = wlanHEMUConfig(195);

showAllocation(cfgMUMIMO);
% Allocation of the plot showing a single RU assigned to all 4 users

%%
numTx = 6; % No. of transmit antennas
guardInterval = 0.8; % Guard interval in ms

% Config the common parameters for all the users
cfgMUMIMO.NumTransmitAntennas = numTx;
cfgMUMIMO.GuardInterval = guardInterval;

% Config per user parameters
% STA1
cfgMUMIMO.User{1}.NumSpaceTimeStreams = 1;
cfgMUMIMO.User{1}.MCS = 4;
cfgMUMIMO.User{1}.APEPLength = 1000;
% STA2
cfgMUMIMO.User{2}.NumSpaceTimeStreams = 1;
cfgMUMIMO.User{2}.MCS = 4;
cfgMUMIMO.User{2}.APEPLength = 1000;
% STA3
cfgMUMIMO.User{3}.NumSpaceTimeStreams = 1;
cfgMUMIMO.User{3}.MCS = 4;
cfgMUMIMO.User{3}.APEPLength = 1000;
% STA4
cfgMUMIMO.User{4}.NumSpaceTimeStreams = 1;
cfgMUMIMO.User{4}.MCS = 4;
cfgMUMIMO.User{4}.APEPLength = 1000;

%%
% OFDMA configuration - 4 users, each using a 52-tone RU
cfgOFDMA = wlanHEMUConfig(112);

%%
showAllocation(cfgOFDMA);
% plot which shows four RUs, each having a single user.

%%
% Config the common parameters for all the users
cfgOFDMA.NumTransmitAntennas = numTx;
cfgOFDMA.GuardInterval = guardInterval;

% Config per user parameters
% STA1 (RU #1)
cfgOFDMA.User{1}.NumSpaceTimeStreams = 2;
cfgOFDMA.User{1}.MCS = 4;
cfgOFDMA.User{1}.APEPLength = 1000;
% STA2 (RU #2)
cfgOFDMA.User{2}.NumSpaceTimeStreams = 2;
cfgOFDMA.User{2}.MCS = 4;
cfgOFDMA.User{2}.APEPLength = 1000;
% STA3 (RU #3)
cfgOFDMA.User{3}.NumSpaceTimeStreams = 2;
cfgOFDMA.User{3}.MCS = 4;
cfgOFDMA.User{3}.APEPLength = 1000;
% STA4 (RU #4)
cfgOFDMA.User{4}.NumSpaceTimeStreams = 2;
cfgOFDMA.User{4}.MCS = 4;
cfgOFDMA.User{4}.APEPLength = 1000;

%%
% Mixed OFDMA and MU-MIMO config
cfgMixed = wlanHEMUConfig(25);

%%
showAllocation(cfgMixed);
% Allocation plot which shows three RUs, one with 2 users (MU-MIMO), and the others having one user each (OFDMA).

%%
% Config common parameters for all the users:
cfgMixed.NumTransmitAntennas = numTx;
cfgMixed.GuardInterval = guardInterval;

% Config the per user parameters
% RU #1 has two users (MU-MIMO) and a total of 2 STS (1 per user)
% STA1 (RU #1)
cfgMixed.User{1}.NumSpaceTimeStreams = 1;
cfgMixed.User{1}.MCS = 4;
cfgMixed.User{1}.APEPLength = 1000;
% STA2 (RU #1)
cfgMixed.User{2}.NumSpaceTimeStreams = 1;
cfgMixed.User{2}.MCS = 4;
cfgMixed.User{2}.APEPLength = 1000;

% The remaining two users are OFDMA
% STA3 (RU #2)
cfgMixed.User{3}.NumSpaceTimeStreams = 2;
cfgMixed.User{3}.MCS = 4;
cfgMixed.User{3}.APEPLength = 1000;
% STA4 (RU #3)
cfgMixed.User{4}.NumSpaceTimeStreams = 2;
cfgMixed.User{4}.MCS = 4;
cfgMixed.User{4}.APEPLength = 1000;

%% Channel Model Config:
% Create channel config, common for all users
tgaxBase = wlanTGaxChannel;
tgaxBase.DelayProfile = 'Model-D';     % Delay 
tgaxBase.NumTransmitAntennas = numTx;  % transmit antennas
tgaxBase.NumReceiveAntennas = 2;       % Each user has receive antennas = 2
tgaxBase.TransmitReceiveDistance = 10; % distance: Non-line of sight 
tgaxBase.ChannelBandwidth = cfgMUMIMO.ChannelBandwidth;
tgaxBase.SampleRate = wlanSampleRate(cfgMUMIMO);
% Set a fixed seed for the channel
tgaxBase.RandomStream = 'mt19937ar with seed';
tgaxBase.Seed = 5;


% Create the channels- for each user

% Initialize the cell array, so to store channel objects
numUsers = numel(cfgMixed.User); % Number of users
tgax = cell(1, numUsers);

% Generate channels- for each user
for userIdx = 1:numUsers
    % Clone tgaxBase for each user and set unique UserIndex
    tgax{userIdx} = clone(tgaxBase);
    tgax{userIdx}.UserIndex = userIdx; % Set unique user index
end

%% Beamforming Feedback:

% Generate NDP packet, for feedback only
cfgNDP = wlanHESUConfig('APEPLength', 0, 'GuardInterval', 0.8); % NDP -config
cfgNDP.ChannelBandwidth = tgaxBase.ChannelBandwidth;
cfgNDP.NumTransmitAntennas = cfgMUMIMO.NumTransmitAntennas;
cfgNDP.NumSpaceTimeStreams = cfgMUMIMO.NumTransmitAntennas;

% Generate NDP packet which is empty PSDU
txNDP = wlanWaveformGenerator([], cfgNDP);

% Obtain feedback channel state matrix which is done by SVD, for each user
staFeedback = cell(1, numUsers);
for userIdx = 1:numel(tgax)
    % Received waveform at user STA with 50 sample padding (no noise)
    rx = tgax{userIdx}([txNDP; zeros(50, size(txNDP, 2))]);

    % Calculate full-band beamforming feedback for user
    staFeedback{userIdx} = heUserBeamformingFeedback(rx, cfgNDP);
end

%% Simulation Parameters:


% Simulation parameters
cfgSim = struct;
cfgSim.NumPackets = 10;       % Packets/path loss
cfgSim.Pathloss = (96:3:105); % Path losse in dB
cfgSim.TransmitPower = 30;    % AP transmit power in dBm
cfgSim.NoiseFloor = -89.9;    % STA noise floor in dBm
cfgSim.IdleTime = 20;         % Idle time between packets in micros

%% Simulation with OFDMA:

% for each RU, Calculate the steering matrix 
for ruIdx = 1:numel(cfgOFDMA.RU)
    % Calculate steering matrix based on STA feedback
    steeringMatrix = heMUCalculateSteeringMatrix(staFeedback, cfgOFDMA, cfgNDP, ruIdx);

    % Apply steering matrix to each RU
    cfgOFDMA.RU{ruIdx}.SpatialMapping = 'Custom';
    cfgOFDMA.RU{ruIdx}.SpatialMappingMatrix = steeringMatrix;
end


%% Simulating OFDMA

disp('Simulating OFDMA:');
throughputOFDMA = heMUSimulateScenario(cfgOFDMA, tgax, cfgSim);

%% Simulating MU-MIMO

% Calculate, then apply the steering matrix
ruIdx = 1; % Index of the RU
steeringMatrix = heMUCalculateSteeringMatrix(staFeedback, cfgMUMIMO, cfgNDP, ruIdx);
cfgMUMIMO.RU{1}.SpatialMapping = 'Custom';
cfgMUMIMO.RU{1}.SpatialMappingMatrix = steeringMatrix;

%simulation for MU-MIMO
disp('Simulating MU-MIMO:');
throughputMUMIMO = heMUSimulateScenario(cfgMUMIMO, tgax, cfgSim);

%% Simulating both Combined MU-MIMO and OFDMA

% Calculate and apply steering matrices for all RUs
for ruIdx = 1:numel(cfgMixed.RU)
    steeringMatrix = heMUCalculateSteeringMatrix(staFeedback, cfgMixed, cfgNDP, ruIdx);
    cfgMixed.RU{ruIdx}.SpatialMapping = 'Custom';
    cfgMixed.RU{ruIdx}.SpatialMappingMatrix = steeringMatrix;
end

% simulation
disp('Simulating Mixed MU-MIMO and OFDMA:');
throughputMixed = heMUSimulateScenario(cfgMixed, tgax, cfgSim);

%%Results

figure;
plot(cfgSim.Pathloss, sum(throughputOFDMA, 2), '-x');
hold on;
plot(cfgSim.Pathloss, sum(throughputMUMIMO, 2), '-o');
plot(cfgSim.Pathloss, sum(throughputMixed, 2), '-s');
grid on;
xlabel('Pathloss (dB)');
ylabel('Throughput (Mbps)');
legend('OFDMA', 'MU-MIMO', 'MU-MIMO & OFDMA');
title('Raw AP Throughput');


