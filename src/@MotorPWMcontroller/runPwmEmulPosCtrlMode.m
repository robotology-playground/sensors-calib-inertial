function ok = runPwmEmulPosCtrlMode(obj,samplingPeriod)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Get indices and current mode of coupled motors
[motorsIdxList,~] = ...
    obj.remCtrlBoardRemap.getMotorsMappedIdxes(ob.coupling.coupledMotors);
[ok1,modes] = obj.remCtrlBoardRemap.getJointsControlMode(motorsIdxList);
obj.couplingPrevMode = modes{1}; % All modes from a coupling are identical

% Get the PID parameters
[~,obj.pidGains] = obj.remCtrlBoardRemap.getMotorsPids(obj,'posPID',motorsIdxList);

% Define and run the position control emulator thread with a discrete PID
% controller.
obj.ctrllerThreadPeriod = samplingPeriod;          % thread period
PIDCtrller = PIDcontroller(obj.pidGains,filter);   % discrete PID controller
startFcn  = @(~,~) obj.ctrllerThreadStartFcn(motorsIdxList);
stopFcn   = @(~,~) obj.ctrllerThreadStopFcn(motorsIdxList);
updateFcn = @(timerObj,thisEvent,timerStopFcn) ... % update function
    obj.ctrllerThreadUpdateFcn(timerObj,thisEvent,timerStopFcn,rateThreadPeriod,PIDCtrller);

% local timer
obj.ctrllerThread = RateThread(updateFcn,startFcn,stopFcn,'yarp',samplingPeriod,100);
ok2 = obj.ctrllerThread.run(false); % run and don't wait for thread termination

ok = ok1 && ok2;

end
