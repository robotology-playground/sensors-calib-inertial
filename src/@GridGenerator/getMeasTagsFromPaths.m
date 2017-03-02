function measTag = getMeasTagsFromPaths(qT)

% For each pair of simultaneous target positions <qT_i,qA_i>, set the tag
% activating or deactivating the sensor data acquisition.
% The motion in the qT dimension is always a transition motion, so if
% qT_{i-1} nd qT_{i} differ, don't acquire data.
% [in] qT: a column vector of transition positions
% [out]measTag: tag activating or deactivating the sensor data acquisition

% Compute the delta vector:
% if qT_{i-1} nd qT_{i} differ, then qT_{i}=false
qTcurrent  = qT;
qTprevious = [0; qT(1:numel(qT)-1)];
qTdelta = qTcurrent - qTprevious;
measTag = ~boolean(qTdelta);

% First target position is assumed to be reached through a transition
% motion, so measTag(1) = false.
measTag(1) = false;

end
