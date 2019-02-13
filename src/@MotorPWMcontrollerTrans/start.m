function ok = start(obj,plotterType)
%start Extends the parent class 'start' method by running the PWM pattern for the calibrated motor.
%   Detailed explanation goes here

obj.start@MotorPWMcontroller(plotterType);

% Load sampling and timeout parameters
config = Init.load('lowLevCtrlCalibratorDevConfig');

% run calibrated motor controller
ok = obj.runMainMotorController(config.posCtrlEmulator.samplingPeriod,config.calibedMotCtrller.timeout);

end

