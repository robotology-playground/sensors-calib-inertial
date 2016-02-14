function e = costFunctionSigma(Dq, part, jointsToCalibrate, data, subsetVec_idx, estimator)
%COSTFUNCTIONSIGMA Summary of this function goes here
%   Detailed explanation goes here

%% Prepare inputs for updating the kinematics information in the estimator
% 
% Compute the kinematics information necessary for the accelerometer
% sensor measurements estimation. We assume the robot root link is fixed to
% the ground (steady kart pole). We then assume to know the gravity (ground
% truth) projected on the frame (base_link) fixed to the root link. For more 
% info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions.
%
% MOVE ALL INIT VARIABLES TO PERSISTENT

% Gravity
grav_idyn = iDynTree.Vector3();
grav = [0.0;0.0;-9.81];
grav_idyn.fromMatlab(grav);

% Get joint information: DOF
dofs = estimator.model().getNrOfDOFs();

% create joint position iDynTree objects
% Note: 'JointPosDoubleArray' is a special type for future evolution which
% will handle quaternions. But for now the type has the format as 
% 'JointDOFsDoubleArray'.
qi_idyn   = iDynTree.JointPosDoubleArray(dofs); 
dqi_idyn  = iDynTree.JointDOFsDoubleArray(dofs);
d2qi_idyn = iDynTree.JointDOFsDoubleArray(dofs);

% Base link index for later applying forward kynematics
base_link_index = estimator.model().getFrameIndex('base_link');

%% Specify unknown wrenches

% We need to set the location of the unknown wrench. We express the unknown
% wrench at the origin of the l_sole frame
unknownWrench = iDynTree.UnknownWrenchContact();
unknownWrench.unknownType = iDynTree.FULL_WRENCH;

% the position is the origin, so the conctact point wrt to base_link is zero
unknownWrench.contactPoint.zero();

% The fullBodyUnknowns is a class storing all the unknown external wrenches
% acting on a class: we consider the pole reaction on the base link as the only 
% external force.
% Build an empty list.
fullBodyUnknowns = iDynTree.LinkUnknownWrenchContacts(estimator.model());
fullBodyUnknowns.clear();
fullBodyUnknowns.addNewContactInFrame(estimator.model(),base_link_index,unknownWrench);

% Print the unknowns to make sure that everything is properly working
fullBodyUnknowns.toString(estimator.model())


%% The estimated FT sensor measurements
% `estimator.sensors()` gets used sensors (returns `SensorList`)
% ex: `estimator.sensors.getNrOfSensors(iDynTree.ACCELEROMETER)`
%     `estimator.sensors.getSensor(iDynTree.ACCELEROMETER,1)`
estMeasurements = iDynTree.SensorsMeasurements(estimator.sensors());

% Memory allocation for output variables
estJointTorques = iDynTree.JointDOFsDoubleArray(dofs);
estContactForces = iDynTree.LinkContactWrenches(estimator.model());


%% compute predicted measurements

% Build the joint vectors.
% FOR NOW, WE ASSUME MODEL AND MEASUREMENTS ONLY DEPICT RIGHT_LEG.
q0i = data.q(:,subsetVec_idx);
dqi = data.dq(:,subsetVec_idx);
d2qi = data.d2q(:,subsetVec_idx);

% Build sensor list for the current part (part: right_leg, left_arm,...).
% This is a list of indexes, that will be later used for retrieving the
% sensor predicted measurements.
sensorsIdxList = [];
for frame = 1:length(data.frames)
    if strcmp(data.parts(frame),jointsToCalibrate.parts(part))...
            && strcmp(data.type(frame),'inertialMTB')
        sensorsIdxList = [sensorsIdxList ...
                          estimator.sensors.getSensorIndex(iDynTree.ACCELEROMETER,...
                                                           char(data.frames(frame)))];
    end
end

%% 
for s = 1:length(subsetVec_idx)
    
    % Fill iDynTree joint vectors. (right_leg, in radians)
    % Warning!! iDynTree takes in input **radians** based units,
    % while the iCub port stream **degrees** based units.
    qi_s = q0i(s) + Dq;
    qi_idyn.fromMatlab(qi_s);
    dqi_idyn.fromMatlab(dqi(s));
    d2qi_idyn.fromMatlab(d2qi(s));
    
    % Update the kinematics information in the estimator
    estimator.updateKinematicsFromFixedBase(qi_idyn,dqi_idyn,d2qi_idyn,base_link_index,grav_idyn);
    
    % run the estimation
    estimator.computeExpectedFTSensorsMeasurements(fullBodyUnknowns,estMeasurements,estContactForces,estJointTorques);
    
    % Get predicted measurements for each sensor referenced in 'sensorsIdxList'
    

end

e=0;

end

