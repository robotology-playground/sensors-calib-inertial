classdef JointsDbase < DataBase
    %JointsDbase Implements a database with joints parameters
    %   Detailed explanation goes here
    
    properties(Constant = true, Access = protected)
        defaultMaxDq0 = 0;
    end
    
    properties(Access = protected)
        iDynTreeModel;
    end
    
    methods(Access = public)        % Constructor
        function obj = JointsDbase(iDynTreeModelFromURDF)
            % create property names and keys
            propKeyList = {'jointName'};
            propNameList = {'jointName','iDynObject','firstAttachedLink','secondAttachedLink','part','DoF','maxDq0'};
            propValueList = cell(iDynTreeModelFromURDF.getNrOfJoints(),length(propNameList));
            
            % Set 'propValueList' with the properties from the iDynTree model
            jointIdxList = 0:iDynTreeModelFromURDF.getNrOfJoints()-1;
            propValueLineIdx = 1;
            for jointIdx = jointIdxList
                % get native parameters
                iDynObject = iDynTreeModelFromURDF.getJoint(jointIdx);
                jointName = iDynTreeModelFromURDF.getJointName(jointIdx);
                firstAttachedLink = iDynTreeModelFromURDF.getLinkName(iDynObject.getFirstAttachedLink());
                secondAttachedLink = iDynTreeModelFromURDF.getLinkName(iDynObject.getSecondAttachedLink());
                DoF = iDynObject.getNrOfDOFs();
                
                % determine to which part the parent link is attached to
                part = RobotModel.link2part(secondAttachedLink);
                
                % fill the properties list
                propValueList(propValueLineIdx,:) = {...
                    jointName,iDynObject,firstAttachedLink,...
                    secondAttachedLink,part,DoF,JointsDbase.defaultMaxDq0};
                
                % increment pointer
                propValueLineIdx = propValueLineIdx+1;
            end
            
            % create and build database
            obj = obj@DataBase('keys',propKeyList,'names',propNameList,'values',propValueList);
            obj.build();
            
            % save iDynTree sensors object
            obj.iDynTreeModel = iDynTreeModelFromURDF;
        end
        
        % Get joints names from a given part
        jointNameList = getJointNames(obj,part);
        
        % Get the calibration init point Dq0 vector for a given list of joints
        MaxDq0col = getJointsMaxCalibDq0(obj,jointList);
        
        % Get the total DoF from a given list of joints
        DoF = getTotalJointDoF(obj,jointList);
        
        % Set maximum Dq0 (required by the optimisation solver) for all joints
        success = setAllJointsMaxCalibDq0(obj,maxDq0);
    end
end

