function sensorGain = getSensorGain( sensorLabel )
%getSensorGain Get the sensor gain from a given sensor unique label.
%   Even if we usually get the same gain for all sensors of a given
%   type, we consider the possibiity to have  specific gain for each
%   sensor (for instance each IMU).
%

% build query (input properties to match)
inputProp.queryFormat = 2;
inputProp.queryData = {'sensorLabel',sensorLabel};

% query data
fullscaleGainList = obj.getPropList(inputProp,'fullscaleGain');
sensorGain = fullscaleGainList{1};  % 'fullscaleGainList' is a list of a single element

end
