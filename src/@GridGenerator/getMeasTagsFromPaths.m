function measTag = getMeasTagsFromPaths(qT)

% For each pair of simultaneous target positions <qT_i,qA_i>, set the tag
% activating or deactivating the sensor data acquisition.
% The motion in the qT dimension is always a transition motion, so if
% qT_{i-1} nd qT_{i} differ, don't acquire data.

% Compute the delta vector:
% if qT_{i-1} nd qT_{i} differ, then qT_{i}=false
qTcurrent  = qT;
qTprevious = [0 qT(1:numel(qT)-1)];
qTdelta = qTcurrent - qTprevious;
qTdelta = ~boolean(qTdelta);

% First target position is assumed to be reached through a transition
% motion, so measTag(1) = 'false'.
qTdelta(1) = false;

% Convert boolean to char
measTag = char(string(qTdelta));

end
