function [ parentCoupling,idxInCtrlBoardServer ] = getJMcouplingFromCtrlBoard( ...
    joint2coupling,robotName,part,jointName )
%Get the joint/motor coupling info from the control board server.
%   The method stores the respective retrieved objects in the running
%   'joint2coupling', for future queries. It returns the handle of the
%   coupling to which the joint belongs, and the joint index as mapped in
%   the motors control board server.

% Get the coupling info from the control board server if it hasn't been yet
% retrieved
if ~joint2coupling.isKey(jointName)
    % create remote control board and get coupling info
    remoteCtrlBoard = RemoteControlBoard(robotName,part);
    couplingList = remoteCtrlBoard.getCouplings(); % TO BE IMPLEMENTED
    
    % save it to the mapping of joints to couplings
    for idx = 1:numel(couplingList)
        coupling = couplingList{idx};
        keys = coupling.coupledJoints;
        jointIdxes = remoteCtrlBoard.getJointsMappedIdxes(keys);
        [values(1:length(keys)).coupling] = deal(coupling);
        [values.idxInCtrlBoardServer] = deal(jointIdxes);
        addedJoints = containers.Map(coupling.coupledJoints,values);
        joint2coupling = concatMap(joint2coupling,addedJoints);
    end
    
    % delete the remoteCtrlBoard object
    delete(remoteCtrlBoard);
end

% Get the coupling to which the joint 'jointName' belongs, and the joint
% index as mapped in the motors control board server.
jointInfo = joint2coupling(jointName);
parentCoupling = jointInfo.coupling;
idxInCtrlBoardServer = jointInfo.idxInCtrlBoardServer;

end
