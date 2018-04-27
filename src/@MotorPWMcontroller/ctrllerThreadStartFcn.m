function [ ok ] = ctrllerThreadStartFcn( obj,PIDCtrller )

% safeguard, update state
obj.running = true;

% For the motors in emulated pos control...
% Save the last position as the reference position to keep
[obj.lastMotorsPosInPrevMode,~] = obj.remCtrlBoardRemap.getMotorEncoders(obj.posCtrledMotors.idx);
% Save the last PWM as the init value for the PID integration term
obj.lastMotorsPwmInPrevMode = obj.remCtrlBoardRemap.getMotorsPWM(obj.posCtrledMotors.idx);

% Set the transition PWM of the PWM controlled motor
obj.pwmCtrledMotor.pwm = obj.remCtrlBoardRemap.getMotorsPWM(obj.pwmCtrledMotor.idx);

% Set all coupled motors to PWM control mode.
ok = obj.remCtrlBoardRemap.setJointsControlMode(obj.couplingMotorIdxes,'pwmctrl');

% Reset PID controller
PIDCtrller.reset(obj.lastMotorsPwmInPrevMode(:));

end
