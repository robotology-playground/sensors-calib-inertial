function [ ok ] = ctrllerThreadStopFcn( obj )
% Restore on all coupled motors the control mode used prior the position control emulation.
%   Detailed explanation goes here

ok = obj.remCtrlBoardRemap.setJointsControlMode(obj.couplingMotorIdxes,obj.couplingPrevMode);
obj.running = false;

end

