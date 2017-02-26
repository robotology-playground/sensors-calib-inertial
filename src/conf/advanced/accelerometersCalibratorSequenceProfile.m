
%% Home single step sequence

% For limbs calibration
homeCalibLimbs.labels = {...
    'ctrl','ctrl','ctrl','ctrl','ctrl','ctrl';...
    'pos','pos','pos','pos','pos','pos';
    'left_arm','right_arm','left_leg','right_leg','torso','head'};
homeCalibLimbs.val = {...
    [0 45 0 0 0 0 0],...
    [0 45 0 0 0 0 0],...
    [0 10 0 0 0 0],...
    [0 10 0 0 0 0],...
    [0 0 0],...
    [0 0 0]};

% For torso calibration
homeCalibTorso = homeCalibLimbs;
homeCalibTorso.val = {...
    [-30 30 -30 20 0 0 0],...
    [-30 30 -30 20 0 0 0],...
    [0 10 0 0 0 0],...
    [0 10 0 0 0 0],...
    [0 0 0],...
    [0 0 0]};

%% Motion sequences
% (a single sequence is intended to move all defined parts synchronously,
% motions from 2 different sequences should be run asynchronously)
% each calibPart should be caibrated within a single sequence.

% define grid motion patterns for each limb

%% Left and right arms
left_arm_seqParams.labels = {...
    'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ,'meas'     ;...
    'pos'                ,'vel'           ,'joint'    ,'joint'    ,'acc'      ;...
    'left_arm'           ,'left_arm'      ,'left_arm' ,'torso'    ,'left_arm'};

gridParams = {...
    'part'    ,'jointIdx','qmin','qmax','nbInterv';...
    'left_arm', 1        , 20   , 116   , 6       ;...
    'left_arm', 2        ,-23   ,  49   , 6       };

acqVel = 4; transVel = 10;

left_arm_seqParams.val = setValFromGrid(gridParams,acqVel,transVel,left_arm_seqParams.labels);

right_arm_seqParams.labels = {...
    'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ,'meas'      ;...
    'pos'                ,'vel'           ,'joint'    ,'joint'    ,'acc'       ;...
    'right_arm'          ,'right_arm'     ,'right_arm','torso'    ,'right_arm'};

right_arm_seqParams.val = left_arm_seqParams.val;

%% Left and right legs
left_leg_seqParams.labels = {...
    'ctrl'               ,'ctrl'          ,'meas'     ,'meas'    ;...
    'pos'                ,'vel'           ,'joint'    ,'acc'     ;...
    'left_leg'           ,'left_leg'      ,'left_leg' ,'left_leg'};

gridParams = {...
    'part'    ,'jointIdx','qmin','qmax','nbInterv';...
    'left_leg', 1        , 20   , 80   , 6        ;...
    'left_leg', 2        ,-60   , 60   , 6        };

acqVel = 4; transVel = 10;

left_leg_seqParams.val = setValFromGrid(gridParams,acqVel,transVel,left_leg_seqParams.labels);

right_leg_seqParams.labels = {...
    'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ;...
    'pos'                ,'vel'           ,'joint'    ,'acc'      ;...
    'right_leg'          ,'right_leg'     ,'right_leg','right_leg'};

right_leg_seqParams.val = left_leg_seqParams.val;

%% Torso
torso_seqParams.labels = {...
    'ctrl'       ,'ctrl'          ,'meas'     ,'meas' ;...
    'pos'        ,'vel'           ,'joint'    ,'acc'  ;...
    'torso'      ,'torso'         ,'torso'    ,'torso'};

gridParams = {...
    'part' ,'jointIdx','qmin','qmax','nbInterv';...
    'torso', 2        ,-18   , 66   , 6        ;...
    'torso', 0        ,-48   , 48   , 6        };

acqVel = 4; transVel = 10;

torso_seqParams.val = setValFromGrid(gridParams,acqVel,transVel,torso_seqParams.labels);

%% Head
head_seqParams.labels = {...
    'ctrl'       ,'ctrl'          ,'meas'     ,'meas'     ,'meas';...
    'pos'        ,'vel'           ,'joint'    ,'joint'    ,'imu' ;...
    'head'       ,'head'          ,'head'     ,'torso'    ,'head'};

gridParams = {...
    'part','jointIdx','qmin','qmax','nbInterv';...
    'head', 2        ,-18   , 66   , 6        ;...
    'head', 0        ,-48   , 48   , 6        };

acqVel = 4; transVel = 10;

head_seqParams.val = setValFromGrid(gridParams,acqVel,transVel,head_seqParams.labels);

%% define sequences for limbs {1} and torso {2} calibration
seqHomeParams{1} = homeCalibLimbs;
seqHomeParams{2} = homeCalibTorso;
seqEndParams     = homeCalibLimbs;

%% Map parts to sequences and params
selector.calibedParts = {...
    'left_arm','right_arm',...
    'left_leg','right_leg',...
    'torso','head'};
selector.calibedSensors = {...
    {'acc'},{'acc'},...
    {'acc'},{'acc'},...
    {'acc'},{'acc'}};
selector.setIdx  = {1,1,1,1,2,1}; % max index must not exceed max index of seqHomePArams
selector.seqParams = {...
    left_arm_seqParams,right_arm_seqParams,...
    left_leg_seqParams,right_leg_seqParams,...
    torso_seqParams,head_seqParams};


%%
%%===================================================================================
% Static local functions
%%===================================================================================

function seqParams = setValFromGrid(gridParams,acqVel,transVel,labels)

% parse the grid parameters (creates vars 'part1','jointIdx1','part2'...)
q1params = cell2struct(gridParams(2,:),gridParams(1,:),2);
q2params = cell2struct(gridParams(3,:),gridParams(1,:),2);
part = labels{3,ismember(labels(1,:),'ctrl') & ismember(labels(2,:),'pos')};
q1params.part = part;
q2params.part = part;

% create sequence where q1 spans once from qmin1 to qmax2 step by step, and
% q2 spans its range in a continuous way.
[seqA.q1,seqA.q2,seqA.dq1,seqA.dq2,seqA.measTag] = ...
    buildGrid(q1params,q2params,acqVel,transVel);

% create sequence where q1 and q2 now have their roles inverted
[seqB.q1,seqB.q2,seqB.dq1,seqB.dq2,seqB.measTag] = ...
    buildGrid(q2params,q1params,acqVel,transVel);

% convatenate...
[q1,q2,dq1,dq2,measTag] = structfun(...
    @(vecA,vecB) [vecA;vecB],...
    seqA,seqB,...
    'UniformOutput',true);

% Reshape the data for setting ['ctrl','pos','<part>'] and ['ctrl','vel','<part>']
% colums of 'seqParams':
% - first init to all zeros
jointsList = RobotModel.jointsListFromPart(part);
ctrlPos = zeros(length(q1),length(jointsList));
ctrlVel = ctrlPos;
% - select columns for the controlled joints
colq1 = ismember(jointsList,q1params.joint);
colq2 = ismember(jointsList,q2params.joint);
% - set values the controlled joints
ctrlPos(colq1) = q1; ctrlVel(:,colq1) = dq1;
ctrlPos(colq2) = q2; ctrlVel(:,colq2) = dq2;
% - reshape as a list and set to 'seqParams'. We don't assume what the
% 'pos','vel' labels order is in 'labels' cell array.
posCols = ismember(labels(1,:),'ctrl') & ismember(labels(2,:),'pos');
seqParams(:,posCols) = num2cell(ctrlPos,2);
velCols = ismember(labels(1,:),'ctrl') & ismember(labels(2,:),'vel');
seqParams(:,velCols) = num2cell(ctrlVel,2);

% Set measurement tags
measCols = ismember(labels(1,:),'meas');
seqParams(:,measCols) = repmat(num2cell(measTag,2),1,sum(measCols));

end

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

% Measurement tags
qAmeasTagsOverGrid = getMeasOnGrid(qAGrid);

% Reshape all matrices to column vectors reordering the elements
% as per 'idxesMat'.
qT(qApathIdxesOverGrid) = qTGrid; qT = qT(:);
qA(qApathIdxesOverGrid) = qAGrid; qA = qA(:);
measTag(qApathIdxesOverGrid) = qAmeasTagsOverGrid; measTag = measTag(:);
% Velocities: the motion in the qT dimension is always a transition motion,
% so qT always moves at 'transVel' speed; the motion in the qA dimension s
% always done while acquiring sensor data, so qA always moves at 'acqVel'
% speed.
dqT = repmat(transVel,size(qT));
dqA = repmat(acqVel,size(qA));

end

function pathIdxesOverGrid = getPathOnGrid(aGrid)

% Define the sequence depicted below (in zigzags):
%
% --> 1  4  5  8  9 12 13 
%     2  3  6  7 10 11 14 --> ...
%
pathIdxesOverGrid = zeros(size(aGrid));
v = [1 2]';
for iter=1:size(aGrid,2)
    pathIdxesOverGrid(:,iter) = v;
    v = flipud(v+2);
end

end

function measTagsOverGrid = getMeasOnGrid(qAGrid)

% Define the sequence depicted below (in zigzags):
%
% --> 0  1  0  1  0  1  0  1
%     1  0  1  0  1  0  1  0 --> ...
%
pathIdxesOverGrid = zeros(size(aGrid));
v = [0 1]';
for iter=1:size(aGrid,2)
    pathIdxesOverGrid(:,iter) = v;
    v = flipud(v);
end

end
