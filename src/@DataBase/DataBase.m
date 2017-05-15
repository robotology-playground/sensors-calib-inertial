classdef DataBase < handle
    %DataBase This class implements a generic database
    %   It can be used for instance for building a robot model with
    %   multiple mappings between the model parameters.
    
    properties(GetAccess = public, SetAccess = protected)
        propKeyList = {};
        propNameList = {};
        propValueList = {};
        ready = false; % initial database not built
    end
    
    methods(Access = public)
        % Constructor
        function obj = DataBase(varargin)
            % parse input parameters.
            for inputIdx = 1:2:length(varargin)
                % get next parameter
                paramName = varargin{inputIdx};
                paramValue = varargin{inputIdx+1};
                % parse
                switch paramName
                    case 'keys'
                        obj.propKeyList = paramValue;
                    case 'names'
                        obj.propNameList = paramValue;
                    case 'values'
                        obj.propValueList = paramValue;
                    otherwise
                        error('Unknown parameters label');
                end
            end
        end
        
        % Set a list of property names. After this operation, the
        % database is not consistent until the respective property values
        % are appended and the database rebuilt.
        function setPropNameList(obj,propNameList)
            obj.propNameList = propNameList;
            obj.ready = false;
        end
        
        % Set a 2-D list of properties. The first line of the 2-D list
        % is the list of property names, the following lines set the
        % property values.
        % After this operation, the database is not consistent until the
        % database rebuilt.
        function setPropNameNvalueList(obj,propList)
            obj.propNameList = propList(1,:);
            obj.propValueList = propList(2:end,:);
            obj.ready = false;
        end
        
        % Add an entry setting the provided property names. 'propList' has 1
        % line list of property names (matching the property names existing
        % in the database) followed by a line list of property values.
        % The function returns true if the property names actually match
        % the ones existing in the database.
        function success = addEntry(obj,propList)
            success = true;
        end
        
        % Reset list of keys among existing property names. After this operation, the
        % database is not consistent until it is rebuilt.
        function setPropKeyList(obj,propKeyList)
            obj.propKeyList = propKeyList;
            obj.ready = false;
        end
        
        % Rebuild database. If returned value is false, it means the
        % database is not consistent (wrong element types, mismatch between
        % properties list and values list sizes,...).
        success = build(obj);
        
        % Retrieve handles pointing to elements which properties match the
        % input parameters 'inputPropsStruct'.
        elemHandleList = getElemList(obj,inputPropsStruct);
        
        % Retrieve the 'outputPropName' property of elements matching input
        % properties specified in 'inputPropsStruct'.
        propList = getPropList(obj,inputPropsStruct,outputPropName);
        
        % Set to 'propValueToSet' the 'inputPropName' property of elements matching
        % input properties specified in 'inputPropsStruct'.
        success = setProp(obj,inputPropsStruct,inputPropName,propValueToSet);
        
        % Set the 'inputPropName' property of the database elements from
        % 'inputPropKeysToValues'. This table assigns the value to set for
        % each element identified by a key.
        success = setPropList(obj,inputPropKeysToValues,inputPropName);
    end
    
    methods(Access = protected)
    end
    
end

