classdef JointsDbase < DataBase
    %JointsDbase Implements a database with joints parameters
    %   Detailed explanation goes here
    
    properties(Constant = true, Access = protected)
    end
    
    methods(Access = public)        % Constructor
        function obj = JointsDbase(iDynTreeModelFromURDF)
            % create property names and keys
            propKeyList = {'jointName'};
            propNameList = {'jointName','iDynObject','firstAttachedLink','secondAttachedLink','part','DoF'};
            propValueList = cell(iDynTreeModelFromURDF.getNrOfJoints(),length(propNameList));
            
            % ...
        end
        
        % Get joints names from a given part
        jointNameList = getJointNames(part);
        
        % Get a vector of Dq0 values from a given list of joints
        Dq0vec = getCalibedJointsDq0(jointList);
        
        % Get the total DoF from a given list of joints
        DoF = getTotalJointDoF(jointList);
    end
    
    methods(Static = true, Access = protected)
    end
end

