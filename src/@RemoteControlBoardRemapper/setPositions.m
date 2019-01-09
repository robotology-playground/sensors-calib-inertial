function [ ok ] = setPositions(obj,desiredPositions)
% desiredVelocities: desired velocities to set

% Concatenate desired velocities matrices, as per IVelocityControl interface 
% specification. Same for the reference accelerations.
desiredPositions = [desiredPositions{:}];

if length(desiredPositions) ~= length(obj.jointsList)
    error('wrong input vector size!');
end

% Set desired velocities and run the motion
obj.yarpVector.fromMatlab(desiredPositions);
ok = obj.ipdr.setPositions(obj.yarpVector.data());

end
