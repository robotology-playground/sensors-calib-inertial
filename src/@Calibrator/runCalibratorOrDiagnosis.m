function runCalibratorOrDiagnosis(obj,init,model,calibOrDiagFuncH,calibedSensorType)

% Harvest the parameters and runs the calibration task
% 
% [in] init :              application script init config parameters
% [in] acqSensorDataAccessor :    acquired data accessor
% [in] calibedSensor :            sensor modality to be calibrated

% unwrap the parameters specific to the calibration task
Init.unWrap(init.(obj.initSection));
acqSensorDataAccessor = obj.acqSensorDataAccessorMap(obj.task);

% Get data folder path list for joints calibration on required parts.
% If the prior sensor data acquisition was done in N motion sequences
% (it is the case for calibrating the torso which needs a dedicated
% sequence), we get a folder path per sequence, so N paths.
% TEMP SOLUTION FOR CALIB. THE TORSO JOINTS --> set <calibedSensorType> to 'acc'.
[dataFolderPathList,calibedPartsList] = ...
    acqSensorDataAccessor.getFolderPaths4calibedSensor(calibedSensorType,init.dataPath);

% For each sequence, get the logged sensors list and respective
% supporting parts
[measedSensorLists,measedPartsLists] = acqSensorDataAccessor.getMeasedSensorsParts();

% In the case of joint encoders calibration, if the torso has to be
% calibrated, it should be before the arms since their orientation depends
% on the torso. In the below loop processing, 'calibrationMap' (input/output)
% is updated at each call to 'calibrateSensors'.
cellfun(@(folderPath,calibedParts,measedSensorList,measedPartsList) ...
    calibOrDiagFuncH(...
    folderPath,calibedParts,measedSensorList,measedPartsList,... % params we iterate on
    model,taskSpecificParams),...                                % params common to all sequences
    dataFolderPathList,calibedPartsList,measedSensorLists,measedPartsLists); % cellfun iterates over these lists

% Save calibration
if init.saveCalibration
    model.saveCalibToFile();
end

end
