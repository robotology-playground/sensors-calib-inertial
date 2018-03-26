function [ ok ] = switchCtrlledMotor( obj,motorName )
% Select new motor to control in explicit PWM mode.
%   The position control emulation is turned off for this motor.

% Switching configuration is only allowed when the controller is not
% running.
if obj.running
    ok = false;
    warning('Position control emulator is running !!');
    return;
end

% Is considered a valid selection only a motor among the current coupled
% motors list.
if(ismember(motorName,obj.coupling.coupledMotors))
    % set position (emulated) and PWM controlled motor settings
    obj.pwmCtrledMotor.name = motorName;
    obj.pwmCtrledMotor.idx = remCtrlBoardRemapper.getMotorsMappedIdxes({motorName});
    obj.pwmCtrledMotor.pwm = 0;
    obj.posCtrledMotors.idx = setdiff(obj.couplingMotorIdxes,obj.pwmCtrledMotor.idx,'stable');
    obj.posCtrledMotors.pwm = zeros(size(obj.posCtrledMotors.idx));
    ok = true;
else
    ok = false;
    error([motorName ' is not in the current coupled motors set being calibrated!!']);
end

end
