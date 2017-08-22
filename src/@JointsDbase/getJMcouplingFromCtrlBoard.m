function parentCoupling = getJMcouplingFromCtrlBoard( ...
    joint2coupling,robotName,part,jointName )
%Get the joint/motor coupling info from the control board server.
%   The method stores the respective retrieved objects in the running
%   'couplingList', for future queries. It returns the handle of the
%   coupling to which the joint belongs.

% Get the coupling info from the control board server if it hasn't been yet
% retrieved
if ~joint2coupling.isKey(jointName)
    % create remote control board and get coupling info
    remoteCtrlBoard = RemoteControlBoard(robotName,part);
    couplingList = remoteCtrlBoard.getCouplings(); % TO BE IMPLEMENTED
    
    % save it to the mapping of joints to couplings
    for idx = 1:numel(couplingList)
        coupledJoints = couplingList{idx}.coupledJoints;
        addedJoints = containers.Map(coupledJoints,repmat({coupling},size(coupledJoints)));
        joint2coupling = [joint2coupling;addedJoints];
    end
    
    % delete the remoteCtrlBoard object
    delete(remoteCtrlBoard);
end

% Get the coupling to which the joint 'jointName' belongs
parentCoupling = joint2coupling(jointName);

end

