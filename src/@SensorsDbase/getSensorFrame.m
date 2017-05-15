function sensorFrame = getSensorFrame( sensorLabel )
%getSensorFrame Get the sensor frame from a given sensor unique label.
%   The sensor frame is a sensor ID within iDynTree context.
%   ex of returned sensor frame: 'r_upper_leg_mtb_acc_11b3'
%

% build query (input properties to match)
inputProp.queryFormat = 2;
inputProp.queryData = {'sensorLabel',sensorLabel};

% query data
frameList = obj.getPropList(inputProp,'sensorFrameName');
sensorFrame = frameList{1}; % 'frameList' is a list of a single element

end
