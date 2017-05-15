function [iDynObject,sensorFrameName,parentLink,parentLinkIdx,sensorFramePose] = ...
    getSensorProps( iDynTreeSensorsFromURDF,sensorType,sensorIndex )
%getSensorProps Get the sensor properties from iDynTree sensors object
%   Here, we get only the native parameters.

% get sensor object with the specific interface
switch sensorType
    case iDynTree.ACCELEROMETER
        iDynObject = iDynTreeSensorsFromURDF.getAccelerometerSensor(sensorIndex);
    case iDynTree.GYROSCOPE
        iDynObject = iDynTreeSensorsFromURDF.getGyroscopeSensor(sensorIndex);
    otherwise
        error('Unknown sensor type!');
end

% get native parameters
sensorFrameName = iDynObject.getName();
parentLink = iDynObject.getParentLink();
parentLinkIdx = iDynObject.getParentLinkIndex();
sensorFramePose = iDynObject.getLinkSensorTransform();

end
