function plotterThreadUpdateFcn2( obj )
%Plots current joint torque and velocity

% get motor velocity (degrees/s from the robot interface) and convert it to the
% units defined in the online plotter
motorVelDeg = obj.remCtrlBoardRemap.getMotorEncoderSpeeds(obj.pwmCtrledMotor.idx);
motorVel = obj.tempPlot.convertFromDeg(motorVelDeg);

% get the motor torque from the respective coupled joints torques
motorCurr = obj.remCtrlBoardRemap.getCurrents(obj.pwmCtrledMotor.idx);

% plot the quantities
addpoints(obj.tempPlot.an,motorVel,motorCurr);
drawnow limitrate

end

