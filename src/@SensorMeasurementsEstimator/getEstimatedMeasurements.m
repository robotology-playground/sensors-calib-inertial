function [ FTsMeas,AccsMeas,GyrosMeas,ThAxAngAccsMeas,ThAxFTsMeas ] = getEstimatedMeasurements( obj,q,dq,d2q,gravity )
%Computes the predicted sensor measurements
%   q   : full joints positions vector
%   dq  : full joints velocities vector
%   d2q : full joints accelerations vector

% Fill iDynTree joint vectors.
% Warning!! iDynTree takes in input **radians** based units.
obj.q_idyn.fromMatlab(obj.convertInputToRadians(q));
obj.dq_idyn.fromMatlab(obj.convertInputToRadians(dq));
obj.d2q_idyn.fromMatlab(obj.convertInputToRadians(d2q));
obj.grav_idyn.fromMatlab(gravity);

% Update the kinematics information in the estimator
obj.estimator.updateKinematicsFromFixedBase(...
    obj.q_idyn,obj.dq_idyn,obj.d2q_idyn, ...
    obj.base_link_index,obj.grav_idyn);

% run the estimation
obj.estimator.computeExpectedFTSensorsMeasurements(...
    obj.fullBodyUnknowns,obj.estMeasurements,obj.sink1,obj.sink2);

% Return serialized measurements. Order is FT, Acc, Gyros,
% ThreeAxisAngularAcc, ThreeAxisFT.
obj.estMeasurements.toVector(obj.allMeas_idyn);
allMeas = obj.allMeas_idyn.toMatlab();

% split measurements by type of sensor
splitMeas = mat2cell(...
    allMeas,...
    double([obj.nbFTs,obj.nbAccs,obj.nbGyros,obj.nbThAxAngAccs,obj.nbThAxFTs]).*[6 3 3 3 3],...
    1);
FTsMeas         = reshape(splitMeas{1},[6,obj.nbFTs]);
AccsMeas        = reshape(splitMeas{2},[3,obj.nbAccs]);
GyrosMeas       = reshape(splitMeas{3},[3,obj.nbGyros]);
ThAxAngAccsMeas = reshape(splitMeas{4},[3,obj.nbThAxAngAccs]);
ThAxFTsMeas     = reshape(splitMeas{5},[3,obj.nbThAxFTs]);

% Convert output angular velocities and accelerations
GyrosMeas = obj.convertOutputFromRadians(GyrosMeas);
ThAxAngAccsMeas = obj.convertOutputFromRadians(ThAxAngAccsMeas);

end

