function success = setAllJointsMaxCalibDq0( obj,maxDq0 )
%setAllJointsMaxCalibDq0 Set maximum Dq0 (required by the optimisation solver) for all joints

% build query (input properties to match)
inputProp.queryFormat = 0;
inputProp.queryData = {};

% query data
success = obj.setProp(inputProp,'maxDq0',maxDq0);

end
