function sensorTypeList = getSensorCadTypes( obj,sensorLabelList )
%getSensorCadTypes Get the sensor type from a given sensor unique label.
%   Known returned sensor types:
%   'mtb_acc','imu_acc','ems_acc','mtb_gyro','ems_gyro'.
%

% build query (input properties to match)
inputProp.format = 2;
inputProp.data = {'sensorLabel',sensorLabelList};

% query data
sensorTypeList = obj.getPropList(inputProp,'cadType');

end
