%%
% Init parameters of the joint low level control calibration for fine tuning of the
% application. Advanced users only.
%%

% Start and end point of data samples
timeStart = 1;  % starting time in capture data file (in seconds)
timeStop  = -1; % ending time in capture data file (in seconds). If -1, use the end time from log
subSamplingSize = 1000; % number of samples after sub-sampling the raw data.

filtParams.type = 'none';
%filtParams.sgolayK = 5;
%filtParams.sgolayF = 11;

posCtrlEmulator.samplingPeriod = 0.01; % seconds
posCtrlEmulator.timeout = 300; % seconds

plotterThread.samplingPeriod = 0.05; % seconds
plotterThread.timeout = 300; % seconds
