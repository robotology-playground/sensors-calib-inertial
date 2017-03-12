classdef Init < handle
    %Init Wrap/unwrap init parameters
    %   Build input structure init from a script, wrapping the
    %   parameters in a structure 'init'.
    %   Unwraps init structures to variables named as their fields
    
    properties
    end
    
    methods(Static = true,Access = public)
        function init = load(initScript)
            % Builds input structure init from a script, embedding
            % the parameters from the script 'initScript' in the init
            % structure 'init'. This is for a safer use running scripts
            % inside other scripts, avoiding variable overrides.
            
            % run init script
            run(initScript);
            
            % get created variables list (cell array of strings)
            clear initScript;
            inputVars(1,:) = who;
            
            % embed the vaiables in the 'init' structure
            Init.wrap(inputVars,'init');
        end
        
        function wrap(variableNames,wrappedVars)
            % embed the variables in a structure and return it
            for cField = variableNames
                field = cell2mat(cField);            % field string
                evalin('caller',[wrappedVars '.' field '=' field ';']); % set field with respective variable
            end
        end
        
        function unWrap(aStruct)
            for cField = fieldnames(aStruct)'
                field = cell2mat(cField);  % field string
                assignin('caller',field,aStruct.(field));
            end
        end
        
        function unWrap_n(aStruct,n)
            for cField = fieldnames(aStruct)'
                field = cell2mat(cField);  % field string
                assignin('caller',[field n],aStruct.(field));
            end
        end
    end
end

