function plotterThreadUpdateFcn( obj )
%Plots current joint torque and velocity

% get motor position (degrees from the robot interface) and convert it to the
% units defined in the online plotter
motorPosDeg = obj.remCtrlBoardRemap.getMotorEncoders(obj.pwmCtrledMotor.idx);
motorPos = obj.tempPlot.convertFromDeg(motorPosDeg);

% get motor PWM
motorPwm = obj.remCtrlBoardRemap.getMotorsPWM(obj.pwmCtrledMotor.idx);

% get the motor torque from the respective coupled joints torques
motorCurr = obj.remCtrlBoardRemap.getCurrents(obj.pwmCtrledMotor.idx);

% plot the quantities
addpoints(obj.tempPlot.an,motorPos,motorPwm,motorCurr);
drawnow limitrate

end

