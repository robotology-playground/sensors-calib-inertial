function [ ok ] = start( obj )
%Set the controlled motor obj.ctrledMotor in PWM control mode.
%   Handle the coupled Motors keeping their control mode and state
%   unchanged. If this is not supported by the YARP
%   remoteControlBoardRemapper, emulate it. We can only emulate position
%   control.

if obj.running
    ok = false;
    warning('Position control emulator is running !!');
    return;
end

% Get indices and current mode of coupled motors
[ok,modes] = obj.remCtrlBoardRemap.getJointsControlMode(obj.couplingMotorIdxes);
obj.couplingPrevMode = modes{1}; % All modes from a coupling are identical

if (length(obj.couplingMotorIdxes) == 1)
    % Simple case, no coupling. Set single motor to PWM control mode
    ok = obj.remCtrlBoardRemap.setJointsControlMode(obj.couplingMotorIdxes,'pwmctrl');
else
    % Processing depending on the mode
    switch couplingPrevMode
        case 'ctrl'
            % Run the position control emulator
            config = Init.load('lowLevTauCtrlCalibratorDevConfig');
            ok = obj.runPwmEmulPosCtrlMode(config.samplingPeriod);
        otherwise
            warningMessage = [...
                'setMotorPWMcontrolMode: previous mode was %s. For that mode we ' ...
                'don''t  support setting one single motor to PWM control while ' ...
                'emulating the previous mode for the others!'];
            warning(warningMessage,couplingPrevMode);
            % Set all coupled motors to PWM control mode
            ok = obj.remCtrlBoardRemap.setJointsControlMode(obj.couplingMotorIdxes,'pwmctrl');
    end
end

end
