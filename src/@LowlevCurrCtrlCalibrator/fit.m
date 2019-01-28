function fit( obj,frictionOrKcurr )
%PHASE-2a/2b Fitting the model and plotting
%

% select group of joints and respective part
motorName = obj.expddMotorList{obj.state.currentMotorIdx};
part = obj.model.jointsDbase.getPartFromMotors(motorName);

% set init for the selected group of joints and respective part
obj.init.(obj.initSection).taskSpecificParams.motorName = motorName;
obj.init.(obj.initSection).taskSpecificParams.frictionOrKcurr = frictionOrKcurr;
obj.init.(obj.initSection).calibedParts = part;

% 4/5 - Fit and plot the friction or Kcurr model (depending on 'frictionOrKcurr'
% parameter). The selection of the calibrated part - joint/motor group -
% friction vs kcurr parameters is already set in the task specific
% parameters.
obj.runCalibratorOrDiagnosis(obj.init,obj.model,@obj.calibrateSensors,obj.calibedSensorType);

end
