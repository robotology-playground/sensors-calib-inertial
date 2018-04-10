function [ torqVecMat ] = getJointTorques( obj,jointsIdxList )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% map a PWM controller
itorq = obj.driver.viewITorqueControl();

% Read all PWMs
allTorqVec = yarp.Vector();
allTorqVec.resize(length(obj.jointsList));
itorq.getTorques(allTorqVec.data());
allTorqVecMat = RemoteControlBoardRemapper.toMatlab(allTorqVec);

% select sub vector
torqVecMat = allTorqVecMat(jointsIdxList);

end
