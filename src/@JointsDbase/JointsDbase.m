classdef JointsDbase < DataBase
    %JointsDbase Implements a database with joints parameters
    %   Detailed explanation goes here
    
    properties(Constant = true, Access = protected)
        defaultMaxDq0 = 0;
    end
    
    properties(Access = protected)
        iDynTreeModel;
        jointMotorCouplings;
    end
    
    methods(Access = public)
        % Constructor
        function obj = JointsDbase(iDynTreeModelFromURDF)
            % create property names and keys
            propKeyList = {'jointName'};
            propNameList = {'jointName','iDynObject','firstAttachedLink','secondAttachedLink','part','DoF','maxDq0','jmCplgLabel'};
            propValueList = cell(iDynTreeModelFromURDF.getNrOfJoints(),length(propNameList));
            
            % Set 'propValueList' with the properties from the iDynTree model
            jointIdxList = 0:iDynTreeModelFromURDF.getNrOfJoints()-1;
            couplingList = containers.Map('KeyType','char','ValueType','any');
            part2coupling = containers.Map('KeyType','char','ValueType','any');
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
                
                % This joint might be coupled with other joints to a set of motors.
                % Retrieve the respective joints/motors coupling information
                parentCouplingLabel = JointsDbase.getJMcouplingFromCtrlBoard(...
                    couplingList,part2coupling,...
                    part,jointName);
                
                % fill the properties list
                propValueList(propValueLineIdx,:) = {...
                    jointName,iDynObject,firstAttachedLink,...
                    secondAttachedLink,part,DoF,JointsDbase.defaultMaxDq0,parentCouplingLabel};
                
                % increment pointer
                propValueLineIdx = propValueLineIdx+1;
            end
            
            % create and build database
            obj = obj@DataBase('keys',propKeyList,'names',propNameList,'values',propValueList);
            obj.build();
            
            % save iDynTree sensors object and coupling list
            obj.iDynTreeModel = iDynTreeModelFromURDF;
            obj.jointMotorCouplings = couplingList;
        end
        
        % Get joints names from a given part
        jointNameList = getJointNames(obj,part);
        
        % Get the list of joint/motor couplings (labels)
        jmCouplingLabels = getJMcouplingLabels(obj,jointNameList); % TO BE IMPLEMENTED
        
        % Get part name from joint/motor group label
        part = getPartFromJMcplgLabel(obj,jmCplgLabel); % TO BE IMPLEMENTED
        
        % Get joint/motor group info (struct) from a joint/motor group
        jmCoupling = getJMcoupling(obj,jmCplgLabel); % TO BE IMPLEMENTED
        
        % Get the calibration init point Dq0 vector for a given list of joints
        MaxDq0col = getJointsMaxCalibDq0(obj,jointList);
        
        % Get the total DoF from a given list of joints
        DoF = getTotalJointDoF(obj,jointList);
        
        % Set maximum Dq0 (required by the optimisation solver) for all joints
        success = setAllJointsMaxCalibDq0(obj,maxDq0);
    end
    
    methods(Static=true, Access=protected)
        % Get the joint/motor coupling info from the control board server.
        % The method stores the respective retrieved objects in the running
        % 'couplingList', for future queries. It returns the handle of the
        % coupling to which the joint belongs.
        parentCouplingLabel = getJMcouplingFromCtrlBoard(...
            couplingList,part2coupling,...
            part,jointName); % TO BE IMPLEMENTED
    end
end

