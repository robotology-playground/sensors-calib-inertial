function [ ok ] = setJointsControlMode( obj,jointsIdxList,mode )
%Set control mode for a set of joint indexes
%   Supported modes are:
%   Position, Open loop (applicable for PWM, torque, current).
%

% Translate requested mode in vocab
vocab = obj.ctrlMode2vocab(mode);

% Set control mode
iCtrlMode = obj.driver.viewIControlMode2();

% convert parameters to types handled by the bindings API
n_joints = length(jointsIdxList);
jointsIVec = yarp.IVector(n_joints);
modesIVec  = yarp.IVector(n_joints);
jointsIVec.fromMatlab(jointsIdxList-1); % C++ like indexes
modesIVec.assign(n_joints,vocab); % assign n values

% configure mode for specified joints
ok = iCtrlMode.setControlModes(n_joints,jointsIVec,modesIVec);

end
