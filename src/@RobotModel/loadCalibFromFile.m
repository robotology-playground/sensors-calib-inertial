function loadCalibFromFile(obj)
%loadCalibFromFile Loads the calibration map from the file name set at the
%                  object creation.

% Load existing sensors calibration (joint encoders, inertial & FT sensors, etc)
if exist(obj.calibrationMapFile,'file') == 2
    load(obj.calibrationMapFile,'calibrationMap');
end

if ~exist('calibrationMap','var')
    warning('calibrationMap not found');
    calibrationMap = containers.Map('KeyType','char','ValueType','any');
end
obj.calibrationMap = calibrationMap;

end

