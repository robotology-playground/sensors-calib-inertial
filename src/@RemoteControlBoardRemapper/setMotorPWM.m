function [ ok ] = setMotorPWM( obj,motorName,pwm )
%Set the desired PWM value (0-100%) for the named motor
%   Detailed explanation goes here

% Procedure success
ok = true;

% Get motors indexes as per the control board remapper mapping
[motorIdx,~] = obj.getMotorsMappedIdxes({motorName});

% Set PWM
ok = obj.setMotorsPWM(motorIdx,pwm);

end

