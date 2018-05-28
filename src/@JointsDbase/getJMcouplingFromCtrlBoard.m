function [ parentCoupling,idxInCtrlBoardServer,cpldMotorSharingIdx,gearboxDqM2Jratio,fullscalePWM ] = ...
    getJMcouplingFromCtrlBoard( joint2coupling,robotYarpPortPrefix,part,jointName )
%Get the joint/motor coupling info from the control board server.
%   The method stores the respective retrieved objects in the running
%   'joint2coupling', for future queries. It returns the handle of the
%   coupling to which the joint belongs, and the joint index as mapped in
%   the motors control board server.

% Get the coupling info from the control board server if it hasn't been yet
% retrieved
if ~joint2coupling.isKey(jointName)
    % create remote control board and get coupling info
    remoteCtrlBoard = RemoteControlBoard(robotYarpPortPrefix,part);
    if ~isnan(remoteCtrlBoard.driver)
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
                'cpldMotorSharingIdx',coupling.coupledMotors,...
                'gearboxDqM2Jratio',num2cell(coupling.gearboxDqM2Jratios),...
                'fullscalePWM',num2cell(coupling.fullscalePWMs));
            [values.coupling] = deal(coupling);
            % Convert to a list and then add (merge) to the mapping 'joint2coupling'
            [valueCells] = arrayfun(@(elem) elem,values,'UniformOutput',false);
            addedJoints = containers.Map(coupling.coupledJoints,valueCells);
            joint2coupling = concatMap(joint2coupling,addedJoints); % merge mappings
        end
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
    gearboxDqM2Jratio = jointInfo.gearboxDqM2Jratio;
    fullscalePWM = jointInfo.fullscalePWM;
else
    warning(...
        'getJMcouplingFromCtrlBoard: %s doesn''t match any coupling data extracted from the control board server.',...
        jointName);
    parentCoupling = [];
    idxInCtrlBoardServer = [];
    cpldMotorSharingIdx = [];
    gearboxDqM2Jratio = [];
    fullscalePWM = [];
end

end
