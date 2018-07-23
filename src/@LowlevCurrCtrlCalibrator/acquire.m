function acquire( obj,frictionOrKcurr )
%PHASE-1a/2a Acquire data for friction or Kcurr parameters calibration
% 
% 1 - Friction (phase 1a): set PWM to 0 for the selected joints/motors group
%     Kcurr     (phase 2a): reset calibrated joints/motors to position control
%     
%     In both cases, this behaviour is selected through the 
%     'frictionOrKcurr' parameter sent to the acquisition procedure.
%     Calibrated joints/motors coupling label to use = pointed motorName
%
% 2 - move selected joints and acquire data:
%     Friction (phase 1a), acquired data are:
% 	  => selected motors velocity
% 	  => selected joints measured currents
%     Kcurr (phase 2a), acquired data are:
% 	  => selected motors PWM
% 	  => selected joints measured currents
%     
%     In both cases this is defined in the acquisition profile, and selected
%     through the 'frictionOrKcurr' parameter.
%
% 3 - Run diagnosis on acquired data
% 

% select motor and respective part
motorName = obj.expddMotorList{obj.state.currentMotorIdx};
part = obj.model.jointsDbase.getPartFromMotors(motorName);

% 1 - set init for the selected motor and respective part
obj.init.(obj.initSection).taskSpecificParams.motorName = motorName;
obj.init.(obj.initSection).taskSpecificParams.frictionOrKcurr = frictionOrKcurr;
obj.init.(obj.initSection).calibedParts = part;

% 2 - Get or acquire sensor data
obj.getOrAcquireData(obj.init,obj.model,obj.lastAcqSensorDataAccessorMap);

% Save eventual changes of last acquired data accessors to file
lastAcqSensorDataAccessorMap = obj.lastAcqSensorDataAccessorMap;
save('lastAcqSensorDataAccessorMap.mat','lastAcqSensorDataAccessorMap');

% 3 - Run diagnosis on acquired data.
% Diagnosis function: doesn't require 'calibedParts' & 'calibedJointsIdxes'.
diagFuncH = @(path,~,sensors,parts,model,taskSpec) ...
    obj.plotTrainingData(...
    path,sensors,parts,model,taskSpec); % actual params passed through the func handle
% Run diagnosis plotters for all acquired data, so for each acquired data accessor.
obj.runCalibratorOrDiagnosis(obj.init,obj.model,diagFuncH,obj.calibedSensorType);

end

