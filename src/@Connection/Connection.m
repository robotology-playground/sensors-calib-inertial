classdef Connection < handle
    %This class holds the connection configuration between 2 YARP ports
    
    properties(GetAccess=public, SetAccess=protected)
       from@char  = '';  % source port
       to@char    = '';  % sink port
       path@char  = '';  % path to the stored sensor data
       pid@double = [];  % 'yarpdatadumper' process PID that open the port
    end
    
    properties(Constant=true, Access=public)
        connectionList = containers.Map('KeyType','char','ValueType','any');
    end
    
    methods
        % Constructor
        function obj = Connection(from,to,path)
            % get access to the list of created objects
            connectionList = Connection.connectionList;
            % Check if the connection exists in the common list of connections
            if connectionList.isKey([from to])
                % just return the handle of the object
                obj = connectionList([from to]);
                if ~strcmp(obj.path,path)
                    warning('Duplicate connection requested, keeping original one!');
                end
            else
                % Set the properties
                [obj.from,obj.to,obj.path] = deal(from,to,path);
                % save the new object in the common list
                connectionList([from to]) = obj;
                % run yarpdatadumper (it will open the port)
                obj.openPort();
            end
        end
        
        % Destructor
        function delete(obj)
            obj.remove();
        end
        
        % Check if port is not connected
        function isConnected = conn(obj)
            isConnected = yarp.Network.isConnected(obj.from,obj.to);
        end
        
        % Connect port
        function connect(obj)
            % Check if ports to connect are open
            if ~yarp.Network.exists(obj.from) || ~yarp.Network.exists(obj.to)
                error('One of the ports to connect crashed or was unexpectedly closed.');
            end
            % Connect ports
            if ~obj.conn() % if port is not connected
                % 'yarp connect <output port> <input port>
                if ~yarp.Network.connect(obj.from,obj.to)
                    error(['couldn''t connect port ' obj.to '!']);
                end
                disp(['Added connection from port ' obj.from ' to port ' obj.to '.']);
            else
                disp(['Port ' obj.from ' ALREADY connected to port ' obj.to '.']);
            end
        end
        
        function disconnect(obj)
            if obj.conn() % if port is connected
                % 'yarp disconnect <output port> <input port>
                if ~yarp.Network.disconnect(obj.from,obj.to)
                    error(['couldn''t disconnect port ' obj.to '!']);
                end
                disp(['Removed connection from port ' obj.from ' to port ' obj.to '.']);
            else
                disp(['Port ' obj.from ' and port ' obj.to ' ALREADY disconnected.']);
            end
        end
        
        function remove(obj)
            if ~isempty(obj.pid) % if connection was configured
                % Disconnect any ongoing connection
                yarp.Network.disconnect(obj.from,obj.to);
                % Close destination port and stop data dumper
                obj.closePort();
                % Remove entry from connection list
                Connection.connectionList.remove([obj.from obj.to]);
                % Connection not configured
                obj.pid = [];
            end
        end
    end
    
    methods(Access=protected)
        function openPort(obj)
            % run datadumper and get process PID if source port exists and
            % destination port is yet to be open.
            if yarp.Network.exists(obj.from) && ~yarp.Network.exists(obj.to)
                [status,dumperPid]=system(...
                    ['yarpdatadumper ' ...    % run data dumper
                    '--dir ' obj.path ...    % set output folder
                    ' --name ' obj.to ' --type bottle ' ... % yarp port, data type
                    '&> /dev/null & ' ...     % redirect all output to garbage and run process on backgroung
                    'echo $!']);              % get process PID
                if status
                    error('Couldn''t run yarpdatadumper!');
                else
                    disp(['Opened port ' obj.to '.']);
                end
                obj.pid = str2double(dumperPid); % convert and store PID (removes trail spaces)
                % double check that PID is attached to a yarpdatadumper process
                if ~obj.doesPIDmatchDatadumper(obj.pid)
                    error('Wrong yarpdatadumper PID!');
                end
                % check that required port is now open
                if ~SensorDataYarpI.waitPortOpen(obj.to,5)
                    error(['Couldn''t open port ' obj.to ' !!']);
                end
            else
                % Some error occurred
                error(['Source port ' obj.from ' doesn''t exist or destination port ' obj.to ' is already open!!']);
            end
        end
        
        function closePort(obj)
            if system(['kill ' num2str(obj.pid)])
                error(['Couldn''t stop yarpdatadumper!' num2str(obj.pid)]);
            end
            disp(['Stoped yarpdatadumper and closed dumper port ' obj.to '.']);
        end
    end
    
    methods(Static=true, Access=protected)
        function status = doesPIDmatchDatadumper(pid)
            % get the matching process (only the command wo the parameters)
            [status,pidCmdRef] = system(['ps -cp ' num2str(pid)]);
            if status
                warning('Couldn''t verify the PID');
                status = false;
                return;
            end
            % parse the first 4 columns into a 1x4 cell
            pidCmdRef_cols     = textscan(pidCmdRef,'%s %s %s %s');
            % expand cell contents and filter to get the array of cells as follows:
            % PID CMD
            % XXX XXXXX
            pidCmdRef_array    = [pidCmdRef_cols{[1 4]}];
            % expected PID/CMD to compare to
            generatedPidCmd_array = {'PID','CMD';num2str(pid),'yarpdatadumper'};
            similar = cellfun(...
                @(elem1,elem2) strcmp(elem1,elem2),...
                pidCmdRef_array(:),generatedPidCmd_array(:),...
                'UniformOutput',false);
            status = (sum(~[similar{:}]) == 0);
        end
    end
end

