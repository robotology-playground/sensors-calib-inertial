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
            % Check that port is registered
            if system(['yarp name query /' robotName '/' part])
                warning('Port not registered!! skipping...');
                obj.driver = NaN;
            else
                obj.driver = yarp.PolyDriver();
                if (~obj.driver.open(obj.options))
                    error(['AxisInfoCollector: Couldn''t open the driver for part ' part]);
                end
            end
        end
        
        % Destructor
        function delete(obj)
            if ~isnan(obj.driver)
                obj.driver.close();
            end
        end
        
        % Get number of axes
        function nbAxes = getAxes(obj)
            ipos = obj.driver.viewIPositionControl();
            nbAxes = ipos.getAxes();
        end
        
        % Get Axes list
        function axesNames = getAxesNames(obj)
            nbAxes = obj.getAxes();
            iaxis = obj.driver.viewIAxisInfo();
            axesNames = cell(1,nbAxes);
            for axisIdx = 1:nbAxes
                axesNames{1,axisIdx} = iaxis.getAxisName(axisIdx-1);
            end
        end
        
        % Get the digested coupling information
        couplingList = getCouplings(obj);
        
        % Get joints indexes as per the control board server mapping
        [jointsIdxList,matchingBitmap] = getJointsMappedIdxes(obj,jointNameList);
    end
    
    methods(Access=protected)
        % Get the coupling parameters
        rawCouplingInfo = getRawCoupling(obj);
    end
    
end

