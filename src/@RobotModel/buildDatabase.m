function buildDatabase( obj )
%buildDatabse Rebuild the databases from the current loaded parameters 
%   The databases allow to query elements matching specified
%   properties. This function rebuilds:
%   - the joints database (initially created from iDynTree model parameters)
%   - the sensors database (initially created from iDynTree model parameters)
%

% Joints database built from iDynTree model parameters
obj.jointsDbase.build();

% Sensors database built from iDynTree model parameters
obj.sensorsDbase.build();


end

