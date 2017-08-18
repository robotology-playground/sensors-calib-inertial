function [ rawCouplingInfo ] = getRawCoupling( obj )
%This method retrieves the raw coupling parameters through the IRemoteVariables debug interface
%   Detailed explanation goes here

% get coupling parameters
ivar = obj.driver.viewIRemoteVariables();
kinematic_mjVar=yarp.Bottle();
ivar.getRemoteVariable('kinematic_mj',kinematic_mjVar);

% convert them to a matrix
kinematic_mjMatStr = kinematic_mjVar.get(0);
rawCouplingInfo = str2num(kinematic_mjMatStr.toString);

end
