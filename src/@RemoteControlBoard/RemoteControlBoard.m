classdef RemoteControlBoard < handle
    %This class retrieves information from the running control board servers
    %   Detailed explanation goes here
    
    properties(SetAccess = protected, GetAccess = public)
        robotName;
        part;
        jointsList={};
        % YARP objects
        axesNames; axesList; remoteControlBoards; remoteControlBoardsList;
        options;
        driver;
    end
    
    methods(Access=public)
        % Constructor
        function obj = RemoteControlBoard(robotName,part)
            % Create YARP Network device if not yet done, to initialize
            % YARP classes for communication.
            if ~yarp.Network.initialized
                yarp.Network.init();
            end
            % Save parameters
            obj.robotName = robotName;
            obj.part = part;
            
            % Create the remote control board device associated to the
            % robot part 'part', and open the driver.
            obj.options = yarp.Property('(device remote_controlboard)');
            obj.options.put('remote',['/' robotName '/' part]);
            obj.options.put('local',['/AxisInfoCollector/' robotName '/' part]);
            obj.driver = yarp.PolyDriver();
            if (~obj.driver.open(obj.options))
                error(['AxisInfoCollector: Couldn''t open the driver for part ' part]);
            end
        end
        
        % Destructor
        function delete(obj)
            obj.driver.close();
        end
        
        % Get number of axes
        function nbAxes = getAxes(obj)
            ipos = obj.driver.viewIPositionControl();
            nbAxes = ipos.getAxes();
        end
        
        % Get Axes list
        function axesNames = getAxesNames(obj)
            % Get joint names from robot interface
            nbAxes = obj.getAxes();
            iaxis = obj.driver.viewIAxisInfo();
            refAxesNames = cell(1,nbAxes);
            for axisIdx = 1:nbAxes
                refAxesNames{1,axisIdx} = iaxis.getAxisName(axisIdx-1);
            end
            % Get joint names from config file
            axesNames = hardwareMechanicals.(obj.part).jointNames;
            % Through warning if differ from 'refAxesNames'
            if ~strcmp(cell2mat(refAxesNames),cell2mat(axesNames))
                warning(['joint names ordering in the config file differs from ' ...
                'the one given by the robot interface!']);
            end
        end
        
        % Get Motors list from 'mechanicals' config file
        function motorNames = getMotorNames(obj)
            motorNames = hardwareMechanicals.(obj.part).motorNames;
        end
        
        % Get the digested coupling information
        couplingList = getCouplings(obj);
        
        % Get joints indexes as per the control board server mapping
        [jointsIdxList,matchingBitmap] = getJointsMappedIdxes(obj,jointNameList);
    end
    
    methods(Access=protected)
        % Get parameters from 'mechanicals' config file
        rawCouplingInfo = getRawCoupling(obj,hardwareMechanicals);
        
        function fullscalePWMs = getFullscalePWMs(obj,hardwareMechanicals)
            fullscalePWMs = hardwareMechanicals.(obj.part).fullscalePWM;
        end
        
        function gearboxDqM2Jratios = getGearboxDqM2Jratios(obj,hardwareMechanicals)
            gearboxDqM2Jratios = hardwareMechanicals.(obj.part).Gearbox_M2J;
        end
    end
    
end

