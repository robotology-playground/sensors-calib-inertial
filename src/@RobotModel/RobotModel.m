classdef RobotModel < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
        
    properties(Constant = true, GetAccess = public)
        jointsListFromPart = RobotModel.buildJointsLists();
    end
    
    methods(Static = true)
        jointsList = buildJointsLists()
    end
end

