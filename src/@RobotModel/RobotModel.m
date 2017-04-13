classdef RobotModel < handle
    %RobotModel This class holds all the properties of the model
    %   The class constructor retrieves the model parameters from the URDF
    %   file: joints list, links list, sensor frames and types, DOFs of
    %   each joint. For that purpose, an iDynTree model 'iDynTree::Model'
    %   could be created and populated by 
    %   It then associates the sensor frames to labels as an abstraction
    %   between the model specific frame names and the names used in the
    %   application interface.
    %   It then creates the associations 'part/limb' <--> (sensor frames,
    %   joints list, part DOF, ...)
    %   For the accelerometers calibration, we need to retrieve the sensor
    %   frame names from the URDF model for a later association to the
    %   'iDynTree.ExtWrenchesAndJointTorquesEstimator' for computing the
    %   predicted link accelerations.
    %   The model also holds the sensor calibration parameters and the
    % joint/motor parameters (PWM to torque rate, friction parameters, ...).
    
    properties(Constant = true, GetAccess = public)
        jointsListFromPart = RobotModel.buildJointsLists();
    end
    
    properties(GetAccess = public, SetAccess = protected)
        robotName = '';
        urdfModelFile = '';
        calibrationMapFile = '';
        calibrationMap;
        estimator; % iDynTree.ExtWrenchesAndJointTorquesEstimator
    end
    
    methods(Access = public)
        function obj = RobotModel(robotName,urdfModelFile,calibrationMapFile)
            % Set parameters from environment if needed
            if isempty(robotName)
                robotName = getenv('YARP_ROBOT_NAME');
            end
            if isempty(urdfModelFile)
                % Let Yarp resource finder get the model path for 'robotName'. Trash the
                % error/warning output and get only the result path
                [status,path] = system('yarp resource --find model.urdf 2> /dev/null');
                if status
                    error('robot model not found !!');
                end
                path = strip(path); % remove spaces from the sides of the string
                urdfModelFile = strip(path,'"'); % remove the quotation marks
            end
            
            % set class attributes
            obj.robotName = robotName;
            obj.urdfModelFile = urdfModelFile;
            obj.calibrationMapFile = calibrationMapFile;
            
            % Load existing sensors calibration (joint encoders, inertial & FT sensors, etc)
            obj.loadCalibFromFile();
            
            %% Create the iDynTree estimator and model...
            %
            % Create an estimator class, load the respective model from URDF file and
            % set the robot state constant parameters
            
            % Create estimator class
            obj.estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();
            
            % Load model and sensors from the URDF file
            obj.estimator.loadModelAndSensorsFromFile(urdfModelFile);
            
            % Check if the model was correctly created by printing the model
            obj
        end
        
        loadCalibFromFile(obj);
        
        saveCalibToFile(obj);
        
        display(obj);
    end
    
    methods(Static = true, Access = protected)
        jointsList = buildJointsLists();
    end
end

