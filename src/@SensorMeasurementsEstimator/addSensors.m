function [ sensorIdxes ] = addSensors( obj,aSensorsList )

% Get sensors list in the model
objSensorsList = obj.estimator.sensors;

% Add the input list of sensors
sensorIdxes = zeros(size(aSensorsList));
for idx = 1:numel(aSensorsList)
    idynSensor = aSensorsList{idx};
    sensorType = idynSensor.getSensorType();
    sensorName = idynSensor.getName();
    objSensorsList.addSensor(idynSensor);
    sensorIdxes(idx) = 1 + objSensorsList.getSensorIndex(sensorType,sensorName);
end

% Update the sensors local count
obj.nbFTs = objSensorsList.getNrOfSensors(iDynTree.SIX_AXIS_FORCE_TORQUE);
obj.nbAccs = objSensorsList.getNrOfSensors(iDynTree.ACCELEROMETER);
obj.nbGyros = objSensorsList.getNrOfSensors(iDynTree.GYROSCOPE);
obj.nbThAxAngAccs = objSensorsList.getNrOfSensors(iDynTree.THREE_AXIS_ANGULAR_ACCELEROMETER);
obj.nbThAxFTs = objSensorsList.getNrOfSensors(iDynTree.THREE_AXIS_FORCE_TORQUE_CONTACT);

% update the estimated measurements sink variable
obj.estMeasurements = iDynTree.SensorsMeasurements(objSensorsList);

end
