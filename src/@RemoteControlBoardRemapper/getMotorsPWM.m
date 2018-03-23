function [ ok,pwmVecMat ] = getMotorsPWM( obj,motorsIdxList )
%Get the PWM values (0-100%) for a set of motor indexes
%   (for calibration purpose).
%   There is no concept of coupled motors in the control board
%   remapper. For the mapping motorIdx <-> jointIdx, refer to the config
%   file hardwareMechanicalsConfig.m

% map a PWM controller
ipwm = obj.driver.viewIPWMControl();

% Read all PWMs
allPwmVec = yarp.Vector();
allPwmVec.resize(length(motorsIdxList));
ok = ipwm.getDutyCycles(allPwmVec.data());

% select sub vector
cLikemotorsIdxList = num2cell(motorsIdxList-1); % C++ like indexes
pwmVec = allPwmVec.subVector(cLikemotorsIdxList{:});
pwmVecMat = RemoteControlBoardRemapper.toMatlab(pwmVec);

end
