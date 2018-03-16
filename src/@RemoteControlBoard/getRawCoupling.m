function [ rawCouplingInfo ] = getRawCoupling( obj,hardwareMechanicals )
%This method retrieves the raw coupling parameters from a local config file
%   As there is currently no API method for retrieving these
%   parameters from the robot interface, the coupling parameters are
%   retrieved from a local configuration file instead of the
%   IRemoteVariables debug interface.

%% Retrieve the raw coupling parameters from the robot interface
% (skipped for now since read of remote variable 'matrixM2J' is not
% implemented yet).
% 
% % get coupling parameters into a yarp bottle
% ivar = obj.driver.viewIRemoteVariables();
% matrixM2Jvar=yarp.Bottle();
% ivar.getRemoteVariable('matrixM2J',matrixM2Jvar);
% 
% % Get the list of matrices invT from the bottle
% % T is defined as: dm = invT dq
% nbT = matrixM2Jvar.size;
% listOfT = cell(1,nbT);
% for idx = 1:nbT
%     % get the idxth element from the bottle as a line matrix
%     Tvec = str2num(matrixM2Jvar.get(idx-1).toString);
%     % reshape it into a square matrix
%     squareMat = reshape(Tvec,round(sqrt(numel(Tvec))),[]);
%     % 'reshape' goes through the vector elements columnwise, while the
%     % vector was built by reading the original matrix 'kinematic_mj'
%     % rowwise.
%     T = squareMat';
%     % Fail if the matrix is not square
%     if size(T,1)~=size(T,2)
%         error('getRawCoupling: Coupling matrix invT is not square !!');
%     end
%     % add to list of coupling matrices
%     listOfT{1,idx} = T;
% end
% 
% % convert the list of matrices invT into a single one by concatenating the
% % matrices invT along the diagonal.
% refRawCouplingInfo = blkdiag(listOfT{:});

% Get the list of raw coupling matrices from a local config file, and
% convert it into a single one by concatenating the matrices T along the
% diagonal.
listOfT = hardwareMechanicals.(obj.part).matrixM2J;
rawCouplingInfo = blkdiag(listOfT{:});

end
