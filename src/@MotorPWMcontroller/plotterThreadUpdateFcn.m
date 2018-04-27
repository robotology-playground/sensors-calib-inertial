function plotterThreadUpdateFcn( obj )
%Plots current joint torque and velocity

% get motor velocity (degrees/s from the robot interface) and convert it to the
% units defined in the online plotter
motorVelDeg = obj.remCtrlBoardRemap.getMotorEncoderSpeeds(obj.pwmCtrledMotor.idx);
motorVel = obj.tempPlot.convertFromDeg(motorVelDeg);

% get the motor torque from the respective coupled joints torques
cpledJointTorques = obj.remCtrlBoardRemap.getJointTorques(obj.couplingJointIdxes);
% Refer to ../../src/@LowlevTauCtrlCalibrator/calibrateSensors.m
motorTorq = ...
    obj.coupling.Tm2j(:,obj.pwmCtrledMotorBitmapInCoupling)' ...
    * cpledJointTorques(:);
jointVel = motorVel*obj.coupling.gearboxDqM2Jratios{obj.pwmCtrledMotorBitmapInCoupling};

% plot the quantities
addpoints(obj.tempPlot.an,jointVel,motorTorq);
drawnow limitrate

end

