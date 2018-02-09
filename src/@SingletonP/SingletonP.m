classdef SingletonP < handle
    %Class implementing a Singleton pattern
    %   Detailed explanation goes here
    
    properties(Abstract=true, Constant=true, Access=protected)
        singletonObj; % set from the private constructor
    end
    
    methods(Access=protected)
        function obj = SingletonP()
        end
    end
    
    methods(Abstract=true, Static=true, Access=public)
        % this function should initialize properly the shared attribute
        % 'singletonObj' and returns the handler to the caller
        theInstance = instance();
    end
end

