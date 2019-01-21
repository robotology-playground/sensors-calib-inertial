% We support two control modes: position and pwm.
% Before this script is run, 'motor' is set to the joints/motors group
% being calibrated. Here we are running the calibration of the bemf
% friction parameters (2rst phase). The targeted joint is kept in PWM 
% control (PWM = 0).


%% Home single step sequence

% For limbs and torso calibration
homeCalib.labels = {...
    'ctrl','ctrl','ctrl','ctrl','ctrl','ctrl';...
    'pos','pos','pos','pos','pos','pos';
    'left_arm','right_arm','left_leg','right_leg','torso','head'};
homeCalib.val = {...
    [-80 40 0 90 0 0 0],...
    [-80 40 0 90 0 0 0],...
    [0 10 0 0 0 0],...
    [0 10 0 0 0 0],...
    [0 0 0],...
    [0 0 0]};

%% Motion sequences
% (a single sequence is intended to move all defined parts synchronously,
% motions from 2 different sequences should be run asynchronously)
% each calibPart should be calibrated within a single sequence.

% Prompt strings definition
NA = @() []; % no prompt
promptStr = @() [...
    'Calibrating the bemf parameter (Kbemf) of motor ' motor '.\n' ...
    'Move joint back and forth and press any key when done..\n'];

% define tables for each limb
left_arm_seqParams.labels = {...
    'prpt'   ,'mode'   ,'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ,'pwmctrl';...
    'NA'     ,'NA'     ,'pos'                ,'vel'           ,'joint'    ,'curr'    ,'pwm'    ;...
    'NA'     ,'NA'     ,'left_arm'           ,'left_arm'      ,'left_arm' ,'left_arm' ,motor };
left_arm_seqParams.val = {...
    NA       ,'ctrl'   ,homeCalib.val{1}     ,repmat( 4,[1 7]),false      ,false      ,0        ;...
    promptStr,'pwmctrl',homeCalib.val{1}     ,repmat( 4,[1 7]),true       ,true       ,0        };

right_arm_seqParams.labels = {...
    'prpt'   ,'mode'   ,'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ,'pwmctrl';...
    'NA'     ,'NA'     ,'pos'                ,'vel'           ,'joint'    ,'curr'    ,'pwm'    ;...
    'NA'     ,'NA'     ,'right_arm'          ,'right_arm'     ,'right_arm','right_arm',motor };
right_arm_seqParams.val = left_arm_seqParams.val;

left_leg_seqParams.labels = {...
    'prpt'   ,'mode'   ,'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ,'pwmctrl';...
    'NA'     ,'NA'     ,'pos'                ,'vel'           ,'joint'    ,'curr'    ,'pwm'    ;...
    'NA'     ,'NA'     ,'left_leg'           ,'left_leg'      ,'left_leg' ,'left_leg' ,motor };
left_leg_seqParams.val = {...
    NA       ,'ctrl'   ,homeCalib.val{3}     ,repmat( 4,[1 6]),false      ,false      ,0        ;...
    promptStr,'pwmctrl',homeCalib.val{3}     ,repmat( 4,[1 6]),true       ,true       ,0        };

right_leg_seqParams.labels = {...
    'prpt'   ,'mode'   ,'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ,'pwmctrl';...
    'NA'     ,'NA'     ,'pos'                ,'vel'           ,'joint'    ,'curr'    ,'pwm'    ;...
    'NA'     ,'NA'     ,'right_leg'          ,'right_leg'     ,'right_leg','right_leg',motor };
right_leg_seqParams.val = left_leg_seqParams.val;

torso_seqParams.labels = {...
    'prpt'   ,'mode'   ,'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ,'pwmctrl';...
    'NA'     ,'NA'     ,'pos'                ,'vel'           ,'joint'    ,'curr'    ,'pwm'    ;...
    'NA'     ,'NA'     ,'torso'              ,'torso'         ,'torso'    ,'torso'    ,motor };
torso_seqParams.val = {...
    NA       ,'ctrl'   ,homeCalib.val{5}     ,repmat( 4,[1 3]),false      ,false      ,0        ;...
    promptStr,'pwmctrl',homeCalib.val{5}     ,repmat( 4,[1 3]),true       ,true       ,0        };

head_seqParams.labels = {...
    'prpt'   ,'mode'   ,'ctrl'               ,'ctrl'          ,'meas'     ,'meas'     ,'pwmctrl';...
    'NA'     ,'NA'     ,'pos'                ,'vel'           ,'joint'    ,'curr'    ,'pwm'    ;...
    'NA'     ,'NA'     ,'head'               ,'head'          ,'head'     ,'head'     ,motor };
head_seqParams.val = {...
    NA       ,'ctrl'   ,homeCalib.val{6}     ,repmat( 4,[1 3]),false      ,false      ,0        ;...
    promptStr,'pwmctrl',homeCalib.val{6}     ,repmat( 4,[1 3]),true       ,true       ,0        };

% define Home and End sequences for limbs and torso calibration
seqHomeParams{1} = homeCalib;
seqEndParams     = homeCalib;

% Map parts to sequences and params
selector.calibedParts = {...
    'left_arm','right_arm',...
    'left_leg','right_leg',...
    'torso','head'};
selector.calibedSensors = {...
    {'LLCctrl'},{'LLCctrl'},...
    {'LLCctrl'},{'LLCctrl'},...
    {'LLCctrl'},{'LLCctrl'}};
selector.setIdx  = {1,1,1,1,1,1}; % max index must not exceed max index of seqHomePArams
selector.seqParams = {...
    left_arm_seqParams,right_arm_seqParams,...
    left_leg_seqParams,right_leg_seqParams,...
    torso_seqParams,head_seqParams};
