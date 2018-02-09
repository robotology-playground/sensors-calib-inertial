function [ ok,modes ] = getJointsControlMode( obj,jointsIdxList )
%Set control mode for a set of joint indexes
%   Supported modes are:
%   Position, Open loop (applicable for PWM, torque, current).
%

% Set control mode
iCtrlMode = obj.driver.viewIControlMode2();

% convert parameters to types handled by the bindings API
n_joints = length(jointsIdxList);
jointsIVec = yarp.IVector(n_joints);
modesIVec  = yarp.IVector(n_joints);
jointsIVec.fromMatlab(jointsIdxList-1); % C++ like indexes
modesIVec.zero();

% configure mode for specified joints
ok = iCtrlMode.getControlModes(n_joints,jointsIVec,modesIVec);

% Translate retrieved mode from vocab
modes = arrayfun(...
    @(vocab) obj.vocab2ctrlMode(vocab),...
    modesIVec.toMatlab,...
    'UniformOutput',false);

end
