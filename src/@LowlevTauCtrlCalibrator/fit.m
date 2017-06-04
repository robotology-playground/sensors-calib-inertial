function fit( obj,frictionOrKtau )
%PHASE-2a/2b Fitting the model and plotting
%

% 4 - Fit the friction or Ktau model (depending on 'frictionOrKtau'
% parameter). The selection of the calibrated part - joint/motor group -
% friction vs ktau parameters is already set in the task specific
% parameters.
obj.runCalibratorOrDiagnosis(init,model,@obj.calibrateSensors,obj.calibedSensorType);

% 5 - Plot fitted model over acquired data.
% Diagnosis function: doesn't require 'calibedParts' & 'calibedJointsIdxes'.
diagFuncH = @(path,~,sensors,parts,model,taskSpec) ...
    SensorDiagnosis.runDiagnosis(...
    path,sensors,parts,model,taskSpec,... % actual params passed through the func handle
    obj.figuresHandlerMap,obj.task);              % params specific to this calibrator
% Run diagnosis plotters for all acquired data, so for each acquired data accessor.
runCalibratorOrDiagnosis(init,model,diagFuncH,obj.calibedSensorType);

end

