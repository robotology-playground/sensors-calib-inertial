classdef Connection < handle
    %This class holds the connection configuration between 2 YARP ports
    
    properties
       from@char    % source port
       to@char      % sink port
       path@char    % path to the stored sensor data
       conn@logical % true if connected, false if not
       pid@double   % 'yarpdatadumper' process PID that open the port
    end
    
    properties(Constant=true, Access=public)
        connectionList = containers.Map('KeyType','char','ValueType','any');
    end
    
    methods
        function obj = Connection(from,to,path,conn,pid)
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
                [obj.from,obj.to,obj.path,obj.conn,obj.pid] = deal(from,to,path,conn,pid);
                % save the new object in the common list
                connectionList([from to]) = obj;
            end
        end
    end
    
end

