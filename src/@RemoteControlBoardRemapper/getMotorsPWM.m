function [ pwmVecMat ] = getMotorsPWM( obj,motorsIdxList )
%Get the PWM values (0-100%) for a set of motor indexes
%   (for calibration purpose).
%   There is no concept of coupled motors in the control board
%   remapper. For the mapping motorIdx <-> jointIdx, refer to the config
%   file hardwareMechanicalsConfig.m

% map a PWM controller
ipwm = obj.driver.viewIPWMControl();

% Read all PWMs
allPwmVec = yarp.Vector();
allPwmVec.resize(length(obj.motorsList));
ipwm.getDutyCycles(allPwmVec.data());
allPwmVecMat = RemoteControlBoardRemapper.toMatlab(allPwmVec);

% select sub vector
pwmVecMat = allPwmVecMat(motorsIdxList);

end
