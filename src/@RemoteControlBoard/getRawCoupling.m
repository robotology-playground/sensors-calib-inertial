function [ rawCouplingInfo ] = getRawCoupling( obj )
%This method retrieves the raw coupling parameters through the IRemoteVariables debug interface
%   Detailed explanation goes here

% get coupling parameters into a yarp bottle
ivar = obj.driver.viewIRemoteVariables();
kinematic_mjVar=yarp.Bottle();
ivar.getRemoteVariable('kinematic_mj',kinematic_mjVar);

% Get the list of matrices invT from the bottle
% T is defined as: dm = invT dq
nbInvT = kinematic_mjVar.size;
listOfInvT = cell(1,nbInvT);
for idx = 1:nbInvT
    % get the idxth element from the bottle s a line matrix
    invTvec = str2num(kinematic_mjVar.get(idx-1).toString);
    % reshape it into a square matrix
    squareMat = reshape(invTvec,round(sqrt(numel(invTvec))),[]);
    % 'reshape' goes through the vector elements columnwise, while the
    % vector was built by reading the original matrix 'kinematic_mj'
    % rowwise.
    invT = squareMat';
    % Fail if the matrix is not square
    if size(invT,1)~=size(invT,2)
        error('getRawCoupling: Coupling matrix invT is not square !!');
    end
    % add to list of coupling matrices
    listOfInvT{1,idx} = invT;
end

% convert the list of matrices invT into a single one by concatenating the
% matrices invT along the diagonal.
rawCouplingInfo = blkdiag(listOfInvT{:});

end
