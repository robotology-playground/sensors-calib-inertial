function [ ok ] = runRealtimePidPlotter( obj,threadPeriod,threadTimeout )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% if there is a plotting thread already running shut it down and destroy it
if ~isempty(obj.plotterThread)
    if obj.plotterThread.isRunning()
        obj.plotterThread.stop(true);
    end
    delete(obj.plotterThread);
end

startFcn  = @(~,~) obj.pidPlotterThreadStartFcn();
stopFcn   = @(~,~) [];
updateFcn = @(~,~,~) obj.pidPlotterThreadUpdateFcn();

obj.plotterThread = RateThread(...
    updateFcn,startFcn,stopFcn,'local',...
    threadPeriod,threadTimeout);

% run the new thread
ok = obj.plotterThread.run(false); % run and don't wait for thread termination

end
