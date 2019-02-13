function [ ok ] = start( obj,plotterType )
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

% Load sampling and timeout parameters
config = Init.load('lowLevCtrlCalibratorDevConfig');

if (length(obj.couplingMotorIdxes) == 1)
    % Simple case, no coupling. Set single motor to PWM control mode
    ok = obj.remCtrlBoardRemap.setJointsControlMode(obj.couplingMotorIdxes,'pwmctrl');
else
    % Processing depending on the mode
    switch obj.couplingPrevMode
        case 'ctrl'
            % Run the position control emulator
            ok = obj.runPwmEmulPosCtrlMode(config.posCtrlEmulator.samplingPeriod,config.posCtrlEmulator.timeout);
        otherwise
            warningMessage = [...
                'setMotorPWMcontrolMode: previous mode was %s. For that mode we ' ...
                'don''t  support setting one single motor to PWM control while ' ...
                'emulating the previous mode for the others!'];
            warning(warningMessage,obj.couplingPrevMode);
            % Set all coupled motors to PWM control mode
            ok = obj.remCtrlBoardRemap.setJointsControlMode(obj.couplingMotorIdxes,'pwmctrl');
    end
end

% Run the real-time plotter
ok = obj.runRealtimePlotter(plotterType,config.plotterThread.samplingPeriod,config.plotterThread.timeout);
%ok = obj.runRealtimePidPlotter(config.plotterThread.samplingPeriod,config.plotterThread.timeout);

% Controller is ready now
obj.controllerReady = true;

end
