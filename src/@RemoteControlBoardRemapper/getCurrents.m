function [ currVecMat ] = getCurrents( obj,motorsIdxList )
%Get the current value (A) for a set of motor indexes
%   (for calibration purpose).
%   There is no concept of coupled motors in the control board
%   remapper. For the mapping motorIdx <-> jointIdx, refer to the config
%   file hardwareMechanicalsConfig.m

% map a current controller
icurr = obj.driver.viewICurrentControl();

% Read all currents
allCurrVec = yarp.Vector();
allCurrVec.resize(length(obj.motorsList));
icurr.getCurrents(allCurrVec.data());
allCurrVecMat = RemoteControlBoardRemapper.toMatlab(allCurrVec);

% select sub vector
currVecMat = allCurrVecMat(motorsIdxList);

end
