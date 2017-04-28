function saveCalibToFile(obj)
%saveCalibToFile Saves the calibration map to the file name set at the
%                object creation.

calibrationMap = obj.calibrationMap;
save(obj.calibrationMapFile,'calibrationMap');

end

