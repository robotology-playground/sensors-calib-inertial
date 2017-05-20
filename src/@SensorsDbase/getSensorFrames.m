function sensorFrameList = getSensorFrames( obj,sensorLabelList )
%getSensorFrames Get the sensor frame from a given sensor unique label.
%   The sensor frame is a sensor ID within iDynTree context.
%   ex of returned sensor frame: 'r_upper_leg_mtb_acc_11b3'
%

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'sensorLabel',sensorLabelList};

% query data
sensorFrameList = obj.getPropList(inputProp,'sensorFrameName');

end
