function success = setAllJointsMaxCalibDq0( obj,maxDq0 )
%setAllJointsMaxCalibDq0 Set maximum Dq0 (required by the optimisation solver) for all joints

% build query (input properties to match)
inputProp.format = 0;
inputProp.data = {};

% query data
success = obj.setProp(inputProp,'maxDq0',maxDq0);

end
