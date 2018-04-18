function pidPlotterThreadUpdateFcn( obj )
%Plots current joint torque and velocity

% get motor position (degrees from the robot interface) and convert it to the
% units defined in the online plotter
motorPosDeg = obj.remCtrlBoardRemap.getMotorEncoders(obj.posCtrledMotors.idx);
motorPos = obj.tempPlot.convertFromDeg(motorPosDeg);

% plot the motor position and PWM quantities
addpoints(...
    obj.tempPlot.an,motorPos(1)*obj.normOfgearboxDqM2Jratios(1),...
    obj.posCtrledMotors.pwm(1));
drawnow limitrate

end

