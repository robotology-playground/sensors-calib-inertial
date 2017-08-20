function fit( obj,frictionOrKtau )
%PHASE-2a/2b Fitting the model and plotting
%

% select group of joints and respective part
jointMotorCoupling = obj.jointMotorCouplings{obj.state.currentJMcplgIdx};
part = obj.model.jointsDbase.getPartFromJMcoupling(jointMotorCoupling);

% set init for the selected group of joints and respective part
obj.init.(obj.initSection).taskSpecificParams.jointMotorCoupling = jointMotorCoupling;
obj.init.(obj.initSection).taskSpecificParams.frictionOrKtau = frictionOrKtau;
obj.init.(obj.initSection).calibedParts = {part};

% 4/5 - Fit and plot the friction or Ktau model (depending on 'frictionOrKtau'
% parameter). The selection of the calibrated part - joint/motor group -
% friction vs ktau parameters is already set in the task specific
% parameters.
obj.runCalibratorOrDiagnosis(init,model,@obj.calibrateSensors,obj.calibedSensorType);

end
