function cadType = frame2cadType( sensorFrameName )

% pattern to extract the sensor type
pat = char(join(SensorsDbase.sensorCADtypes,'|',2));

% extract type by matching pattern
cadTypeC = regexp(sensorFrameName,pat,'match');
cadType = cell2mat(cadTypeC);

end
