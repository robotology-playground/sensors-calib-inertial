function open(obj,partList)

obj.jointsList = {};
for part = partList
    obj.jointsList = [obj.jointsList RobotModel.jointsListFromPart(part{:})];
    % {:} converts from cell to string
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
    error('Couldn''t open the driver');
end

end
