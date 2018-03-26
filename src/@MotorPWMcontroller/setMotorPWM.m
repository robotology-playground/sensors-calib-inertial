function [ ok ] = setMotorPWM( obj,pwm )
%Set the desired PWM level (Duty cycle) for the currently controlled motor
%   Detailed explanation goes here

obj.pwmCtrledMotor.pwm = pwm;

end

