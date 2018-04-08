function [ ok ] = setMotorPWM( obj,pwm )
%Set the desired PWM level (Duty cycle) for the currently controlled motor
%   Detailed explanation goes here

obj.pwmCtrledMotor.pwm = pwm;

% If the emulator is running and handling the other coupled motors, it will
% send the PWM setting itself, otherwise...
if ~obj.running
    obj.remCtrlBoardRemap.setMotorsPWM(obj.pwmCtrledMotor.idx,obj.pwmCtrledMotor.pwm);
end

end

