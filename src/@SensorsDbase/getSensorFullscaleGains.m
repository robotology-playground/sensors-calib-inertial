function fullscaleGainList = getSensorFullscaleGains( obj,sensorLabelList )
%getSensorFullscaleGains Get the sensor gain from a given sensor unique label.
%   Even if we usually get the same gain for all sensors of a given
%   type, we consider the possibiity to have  specific gain for each
%   sensor (for instance each IMU).
%

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'sensorLabel',sensorLabelList};

% query data
fullscaleGainList = obj.getPropList(inputProp,'fullscaleGain');

end
