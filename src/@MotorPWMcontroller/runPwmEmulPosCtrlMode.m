function ok = runPwmEmulPosCtrlMode(obj,samplingPeriod)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Get the PID parameters
[~,obj.pidGains] = obj.remCtrlBoardRemap.getMotorsPids(obj,'posPID',obj.posCtrledMotors.idx);

% Define and run the position control emulator thread with a discrete PID
% controller.
obj.ctrllerThreadPeriod = samplingPeriod;          % thread period
PIDCtrller = PIDcontroller(obj.pidGains,filter);   % discrete PID controller
startFcn  = @(~,~) obj.ctrllerThreadStartFcn(PIDCtrller);
stopFcn   = @(~,~) obj.ctrllerThreadStopFcn();
updateFcn = @(timerObj,thisEvent,timerStopFcn) ... % update function
    obj.ctrllerThreadUpdateFcn(timerObj,thisEvent,timerStopFcn,samplingPeriod,PIDCtrller);

% Use a timer fully synchronised with Yarp as done by the realtime
% synchronizer in Simulink through the WB-toolbox
obj.ctrllerThread = RateThread(updateFcn,startFcn,stopFcn,'yarp',samplingPeriod,100);
ok = obj.ctrllerThread.run(false); % run and don't wait for thread termination

end
