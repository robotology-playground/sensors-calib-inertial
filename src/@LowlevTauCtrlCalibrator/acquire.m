function acquire( obj,frictionOrKtau )
%PHASE-1a/2a Acquire data for friction or Ktau parameters calibration
% 
% 1 - Friction (phase 1a): set PWM to 0 for the selected joints/motors group
%     Ktau     (phase 2a): reset calibrated joints/motors to position control
%     
%     In both cases, this behaviour is selected through the 'frictionOrKtau'
%     parameter sent to the acquisition procedure.
%     Calibrated joints/motors coupling label to use = pointed jointMotorCouplingLabel
%
% 2 - move selected joints and acquire data:
%     Friction (phase 1a), acquired data are:
% 	  => selected motors velocity
% 	  => selected joints measured torques
%     Ktau (phase 2a), acquired data are:
% 	  => selected motors PWM
% 	  => selected joints measured torques
%     
%     In both cases this is defined in the acquisition profile, and selected
%     through the 'frictionOrKtau' parameter.
%
% 3 - Run diagnosis on acquired data
% 

% select group of joints and respective part
jointMotorCouplingLabel = obj.jointMotorCouplingLabels{obj.state.currentJMcplgIdx};
part = obj.model.jointsDbase.getPartFromJMcplgLabel(jointMotorCouplingLabel);

% 1 - set init for the selected group of joints and respective part
obj.init.(obj.initSection).taskSpecificParams.jointMotorGroup = jointMotorCouplingLabel;
obj.init.(obj.initSection).taskSpecificParams.frictionOrKtau = frictionOrKtau;
obj.init.(obj.initSection).calibedParts = {part};

% 2 - Get or acquire sensor data
obj.getOrAcquireData(obj.init,obj.model,obj.lastAcqSensorDataAccessorMap);

% Save eventual changes of last acquired data accessors to file
lastAcqSensorDataAccessorMap = obj.lastAcqSensorDataAccessorMap;
save('lastAcqSensorDataAccessorMap.mat','lastAcqSensorDataAccessorMap');

% 3 - Run diagnosis on acquired data.
% Diagnosis function: doesn't require 'calibedParts' & 'calibedJointsIdxes'.
diagFuncH = @(path,~,sensors,parts,model,taskSpec) ...
    obj.plotTrainingData(...
    path,sensors,parts,model,taskSpec);              % params specific to this calibrator
% Run diagnosis plotters for all acquired data, so for each acquired data accessor.
runCalibratorOrDiagnosis(init,model,diagFuncH,obj.calibedSensorType);

end

