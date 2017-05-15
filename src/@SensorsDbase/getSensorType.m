function sensorType = getSensorType( sensorLabel )
%getSensorType Get the sensor type from a given sensor unique label.
%   Known returned sensor types:
%   'mtb_acc','imu_acc','ems_acc','mtb_gyro','ems_gyro'.
%

% build query (input properties to match)
inputProp.queryFormat = 2;
inputProp.queryData = {'sensorLabel',sensorLabel};

% query data
typeList = obj.getPropList(inputProp,'type');
sensorType = typeList{1};  % 'typeList' is a list of a single element

end
