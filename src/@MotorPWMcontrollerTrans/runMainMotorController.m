function ok = runMainMotorController(obj,threadPeriod,threadTimeout)
%runMainMotorController This method creates a thread for setting the controlled motor PWM following a desired pattern.
%   Define the thread start, stop and update functions:
%   - start: init the time,
%   - stop:  set PWM to 0,
%   - update: use the pattern generator for computing the new PWM value and set the motor pwm accordingly.
% 

startFcn  = @(~,~) obj.mainMotorCtrllerThreadStartFcn();
stopFcn   = @(~,~) obj.mainMotorCtrllerThreadStopFcn();
updateFcn = @(~,~,~) obj.mainMotorCtrllerThreadUpdateFcn();

% Use a timer fully synchronised with Yarp as done by the realtime
% synchronizer in Simulink through the WB-toolbox
obj.mainMotorCtrllerThread = RateThread(updateFcn,startFcn,stopFcn,'yarp',threadPeriod,threadTimeout);
disp('Starting in 5 seconds...');
pause(5);
ok = obj.mainMotorCtrllerThread.run(false); % run and don't wait for thread termination

end

