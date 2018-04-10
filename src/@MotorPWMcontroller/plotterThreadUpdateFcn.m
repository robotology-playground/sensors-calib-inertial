function plotterThreadUpdateFcn( obj )
%Plots current joint torque and velocity

% get motor velocity (rads from the robot interface) and convert it to the
% units defined in the online plotter
motorVelrad = obj.remCtrlBoardRemap.getMotorEncoderSpeeds(obj.pwmCtrledMotor.idx);
motorVel = obj.tempPlot.convertFromRad(motorVelrad);

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
    obj.coupling.gearboxDqM2Jratios{obj.pwmCtrledMotor.idx} ...
    * obj.coupling.Tm2j(:,obj.pwmCtrledMotor.idx)' ...
    * cpledJointTorques(:);

% plot the quantities
figure(obj.tempPlot.figH);
scatter(motorVel,motorTorq,20,'blue','filled');

end

