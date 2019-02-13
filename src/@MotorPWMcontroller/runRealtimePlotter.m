function [ ok ] = runRealtimePlotter( obj,plotterType,threadPeriod,threadTimeout )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% if there is a plotting thread already running shut it down and destroy it
if ~isempty(obj.plotterThread)
    if obj.plotterThread.isRunning()
        obj.plotterThread.stop(true);
    end
    delete(obj.plotterThread);
end

% Set the plotter type
obj.tempPlot.plotterType = plotterType;

switch plotterType
    case 'motorVel2torq' % Motor velocity to torque model
        startFcn  = @(~,~) obj.plotterThreadStartFcn();
        stopFcn   = @(~,~) obj.plotterThreadStopFcn();
        updateFcn = @(~,~,~) obj.plotterThreadUpdateFcn();
        
    case 'motorVel2curr' % Motor velocity to current model
        startFcn  = @(~,~) obj.plotterThreadStartFcn2();
        stopFcn   = @(~,~) obj.plotterThreadStopFcn2();
        updateFcn = @(~,~,~) obj.plotterThreadUpdateFcn2();
        
    case 'motorPwm2Curr' % Motor PWM/position to Current model
        startFcn  = @(~,~) obj.plotterThreadStartFcn3();
        stopFcn   = @(~,~) obj.plotterThreadStopFcn3();
        updateFcn = @(~,~,~) obj.plotterThreadUpdateFcn3();
    otherwise
end

if obj.testMode 
    obj.plotterThread = UT.RateThread_CB(...
        updateFcn,startFcn,stopFcn,'local',...
        threadPeriod,threadTimeout);
else
    obj.plotterThread = RateThread(...
        updateFcn,startFcn,stopFcn,'local',...
        threadPeriod,threadTimeout);
end

% run the new thread
ok = obj.plotterThread.run(false); % run and don't wait for thread termination

end
