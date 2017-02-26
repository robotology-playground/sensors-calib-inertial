function [qT,qA,dqT,dqA,measTag] = buildGrid(qTparams,qAparams,acqVel,transVel)

% Unwrap parameters
% (A:acquire motion parameters. T:transient motion parameters).
Init.unWrap_n(qTparams,T);
Init.unWrap_n(qAparams,A);
qinterv1 = (qmax1-qmin1)/nbInterv1; qinterv2 = (qmax2-qmin2)/nbInterv2;

% Create grid of qT|qA joint angles.
% For instance, if qT spans from 1 to 4, and qA has values min|max=-5|5,
% we get:
% qT =     <--- qT --->
%      1     2     3     4
%      1     2     3     4
%
% qA =                      ^
%      5     5     5     5  qA
%     20    20    20    20  v
%
[qTGrid,qAGrid] = meshgrid(qmin1:qinterv1:qmax1,[qmin2 qmax2]);

% Define a reordering table matching the format of qT and qA
qApathIdxesOverGrid = getPathOnGrid(qAGrid);

% Reshape qT and qA grids to column vectors reordering the elements
% as per 'idxesMat'.
qT(qApathIdxesOverGrid) = qTGrid; qT = qT(:);
qA(qApathIdxesOverGrid) = qAGrid; qA = qA(:);

% Velocities: the motion in the qT dimension is always a transition motion,
% so qT always moves at 'transVel' speed; the motion in the qA dimension is
% always done while acquiring sensor data, so qA always moves at 'acqVel'
% speed.
dqT = repmat(transVel,size(qT));
dqA = repmat(acqVel,size(qA));

% Measurement tags
measTag = getMeasTagsFromPaths(qT);

end
