%%
% Init parameters of the joint low level control calibration for fine tuning of the
% application. Advanced users only.
%%

% Start and end point of data samples
timeStart = 1;  % starting time in capture data file (in seconds)
timeStop  = -1; % ending time in capture data file (in seconds). If -1, use the end time from log
subSamplingSize = 400; % number of samples after sub-sampling the raw data

filtParams.type = 'sgolay';
filtParams.sgolayK = 5;
filtParams.sgolayF = 11;
