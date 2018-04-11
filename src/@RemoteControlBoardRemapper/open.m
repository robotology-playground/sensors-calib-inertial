function open(obj,partList,jointsList)

if nargin<=2 % jointsList is missing
    obj.jointsList = {};
    for part = partList
        obj.jointsList = [obj.jointsList obj.robotModel.jointsDbase.getJointNames(part{:})];
        % {:} converts from cell to string
    end
else
    obj.jointsList = jointsList;
end

% Fill the list of the axis names and add it to the options
obj.axesList.clear();
for joint = obj.jointsList
    obj.axesList.addString(joint{:});
end
obj.options.put('axesNames',obj.axesNames.get(0)) % add the pair {'<property name>',<pointer to object>}

% Fill the list of the axis control boards and add it to the options
obj.remoteControlBoardsList.clear();
for part = partList
    obj.remoteControlBoardsList.addString(['/' obj.robotName '/' part{:}]);
end
obj.options.put('remoteControlBoards',obj.remoteControlBoards.get(0));

% Open the driver
obj.driver = yarp.PolyDriver();
if (~obj.driver.open(obj.options))
    error('RemoteControlBoardRemapper: couldn''t open the driver');
end

% Build motor names list for later use
motorsList = obj.robotModel.jointsDbase.getCpldMotorSharingIdx(obj.jointsList);
obj.motorsList = reshape(motorsList,size(obj.jointsList));

end
