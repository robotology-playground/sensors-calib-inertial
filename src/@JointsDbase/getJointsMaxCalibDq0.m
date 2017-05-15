function MaxDq0col = getJointsMaxCalibDq0( obj,jointList )
%getJointsMaxCalibDq0 Get the calibration init point Dq0 vector for a given list of joints

% build query (input properties to match)
inputProp.queryFormat = 2;
inputProp.queryData = {'jointName',jointList};

% query data
MaxDq0col = obj.getPropList(inputProp,'maxDq0');
MaxDq0col = MaxDq0col(:)';

end
