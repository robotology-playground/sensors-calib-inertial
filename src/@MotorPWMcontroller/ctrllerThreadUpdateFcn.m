function [ ok ] = ctrllerThreadUpdateFcn( obj, ~,~,timerStopFcn,rateThreadPeriod,PIDCtrller )
%Run the PID controller and set the computed PWM values
%   Detailed explanation goes here

% Get the positions and velocities of the emulated pos controlled motors
currentMotorsPos = obj.remCtrlBoardRemap.getMotorEncoders(obj.posCtrledMotors.idx);
currentMotorsVel = obj.remCtrlBoardRemap.getMotorEncoderSpeeds(obj.posCtrledMotors.idx);

% Run the PID controller
[ok,posPwmVec] = PIDCtrller.run(obj.lastMotorsPosInPrevMode,currentMotorsPos,currentMotorsVel);
if ~ok
    % stop the timer with an error
    timerStopFcn(false);
    % throw error
    error('PID processing failed during position control emulation !!');
end

% Set the computed PWM values
ok = obj.remCtrlBoardRemap.setMotorsPWM(obj.posCtrledMotors.idx,posPwmVec);
ok = ok && obj.remCtrlBoardRemap.setMotorsPWM(obj.pwmCtrledMotor.idx,obj.pwmCtrledMotor.pwm);

if ~ok
    % stop the timer with an error
    timerStopFcn(false);
    % throw error
    error('PWM setting failed during position control emulation !!');
end
    
end
