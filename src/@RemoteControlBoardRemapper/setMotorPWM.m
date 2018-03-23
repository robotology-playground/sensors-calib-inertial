function [ ok ] = setMotorPWM( obj,motorName,pwm )
%Set the desired PWM value (0-100%) for the named motor
%   Detailed explanation goes here

% Procedure success
ok = true;

% Get the selected motor index
jointName = obj.robotModel.jointsDbase.getCpldJointSharingIdx({motorName});
motorIdx = obj.getJointsMappedIdxes(jointName);

% Set PWM
ok = obj.setMotorsPWM(motorIdx,pwm);

end

