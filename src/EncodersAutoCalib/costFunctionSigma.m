function e = costFunctionSigma(data, vec_idx, estimator)
%COSTFUNCTIONSIGMA Summary of this function goes here
%   Detailed explanation goes here

%% Prepare inputs for updating the kinematics information in the estimator
% 
% Compute the kinematics information necessary for the accelerometer
% sensor measurements estimation. We assume the robot root link is fixed to
% the ground (steady kart pole). We then assume to know the gravity (ground
% truth) on the frame (base_link) fixed to the root link For more info on iCub 
% frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions.

% Gravity
grav_idyn = iDynTree.Vector3();
grav = [0.0;0.0;-9.81];
grav_idyn.fromMatlab(grav);

% Get joint information: DOF
dofs = estimator.model().getNrOfDOFs();

% create joint position iDynTree objects
q0i_idyn   = iDynTree.JointPosDoubleArray(dofs);
dqi_idyn  = iDynTree.JointDOFsDoubleArray(dofs);
d2qi_idyn = iDynTree.JointDOFsDoubleArray(dofs);

% Base link index for later applying forward kynematics
base_link_index = estimator.model().getFrameIndex('base_link');

% Unknown wrenches: we consider there are no external forces.
% (the fullBodyUnknowns is a class storing all the unknown external wrenches
% acting on a class)
% Build an empty list.
fullBodyUnknowns = iDynTree.LinkUnknownWrenchContacts(estimator.model());
fullBodyUnknowns.clear();

% The estimated FT sensor measurements
% `estimator.sensors()` gets used sensors (returns `SensorList`)
% ex: `estimator.sensors.getNrOfSensors(iDynTree.ACCELEROMETER)`
%     `estimator.sensors.getSensor(iDynTree.ACCELEROMETER,1)`
estMeasurements = iDynTree.SensorsMeasurements(estimator.sensors());

% Init empty dynamic variables (default inputs we don't need but 
% have to provide to the estimator)
estJointTorques = iDynTree.JointDOFsDoubleArray(dofs);
estContactForces = iDynTree.LinkContactWrenches(estimator.model());


%% compute predicted measurements
    % Build the joint vectors
    q0i = data.q(:,subsetVec_idx)';
    dqi = data.dq(:,subsetVec_idx)';
    d2qi = data.d2q(:,subsetVec_idx)';
    % Fill iDynTree joint vectors
    q0i_idyn.fromMatlab(q0i);
    dqi_idyn.fromMatlab(dqi);
    d2qi_idyn.fromMatlab(d2qi);

    % Update the kinematics information in the estimator
    estimator.updateKinematicsFromFixedBase(q0i_idyn,dqi_idyn,ddqi_idyn,base_link_index,grav_idyn);

% Warning!! iDynTree takes in input **radians** based units,
% while the iCub port stream **degrees** based units.


end

