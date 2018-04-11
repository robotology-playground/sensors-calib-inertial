function plotterThreadUpdateFcn( obj )
%Plots current joint torque and velocity

% get motor velocity (rads from the robot interface) and convert it to the
% units defined in the online plotter
motorVel = obj.remCtrlBoardRemap.getMotorEncoderSpeeds(obj.pwmCtrledMotor.idx);
%motorVel = obj.tempPlot.convertFromRad(motorVelrad);

% get the motor torque from the respective coupled joints torques
cpledJointTorques = obj.remCtrlBoardRemap.getJointTorques(obj.couplingJointIdxes);
% We have the coupling matrix Tm2j (motor to joint) and:
% dq_j = Tm2j * dq_m
% Tau_j = Tm2j^{-t} * Tau_m <=> Tau_m = Tm2j^t * Tau_j
% 
% which is also applicable for a gearbox ratio:
% if   dq_j = Gm2j * dq_m
% then Tau_m = Gm2j^t * Tau_j.
% Since Gm2j is a diagonal matrix, then Tau_m = Gm2j * Tau_j.
motorTorq = ...
    obj.coupling.Tm2j(:,obj.pwmCtrledMotorIdxInCouplingMtx)' ...
    * cpledJointTorques(:);
jointVel = motorVel*obj.coupling.gearboxDqM2Jratios{obj.pwmCtrledMotorIdxInCouplingMtx};

% plot the quantities
addpoints(obj.tempPlot.an,jointVel,motorTorq);
drawnow limitrate

end

