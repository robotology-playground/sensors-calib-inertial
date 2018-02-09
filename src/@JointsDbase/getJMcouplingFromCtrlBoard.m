function [ parentCoupling,idxInCtrlBoardServer,cpldMotorSharingIdx ] = getJMcouplingFromCtrlBoard( ...
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
    couplingList = remoteCtrlBoard.getCouplings();
    
    % save it to the mappings:
    % - joint name => coupling/idxInCtrlBoardServer/cpldMotorSharingIdx
    % (Each motor shares the same index as a joint from the coupling)
    for idx = 1:numel(couplingList)
        % Get the coupling and respective joint names, joint and motor indexes
        % (idxInCtrlBoardServer, cpldMotorSharingIdx)
        coupling = couplingList{idx};
        keys = coupling.coupledJoints;
        jointIdxes = num2cell(remoteCtrlBoard.getJointsMappedIdxes(keys));
        % Build array of structures (1 structure per joint)
        values = struct(...
            'idxInCtrlBoardServer',jointIdxes,...
            'cpldMotorSharingIdx',coupling.coupledMotors);
        [values.coupling] = deal(coupling);
        % Convert to a list and then add to the mapping 'joint2coupling'
        [valueCells] = arrayfun(@(elem) elem,values,'UniformOutput',false);
        addedJoints = containers.Map(coupling.coupledJoints,valueCells);
        joint2coupling = concatMap(joint2coupling,addedJoints);
    end
    
    % delete the remoteCtrlBoard object
    delete(remoteCtrlBoard);
end

% Get the coupling to which the joint 'jointName' belongs, and the joint
% index as mapped in the motors control board server.
if joint2coupling.isKey(jointName)
    jointInfo = joint2coupling(jointName);
    parentCoupling = jointInfo.coupling;
    idxInCtrlBoardServer = jointInfo.idxInCtrlBoardServer;
    cpldMotorSharingIdx = jointInfo.cpldMotorSharingIdx;
else
    warning(...
        'getJMcouplingFromCtrlBoard: %s doesn''t match any coupling data extracted from the control board server.',...
        jointName);
    parentCoupling = [];
    idxInCtrlBoardServer = [];
    cpldMotorSharingIdx = [];
end

end
