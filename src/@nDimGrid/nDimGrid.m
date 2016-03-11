classdef nDimGrid < handle
    
    % this class builds a N-dimension grid for specified dimension, range and
    % resolution. It alows to retrieve a vector from that grid through a
    % linear index.
    
    properties (SetAccess = public, GetAccess = public)
        grid;
        dimension = 0;
        nbVectors = 0;
    end
    
    methods
        function obj = nDimGrid(dimension,range,resolution)
            % define grid
            obj.grid = cell(1,dimension);
            obj.dimension = dimension;
            % build output string
            outputString = 'obj.grid{1}';
            for iter = 2:obj.dimension
                outputString = [outputString ',obj.grid{' num2str(iter) '}'];
            end
            %disp(outputString);
            % fill the grid
            eval(['[' outputString '] = ndgrid(' num2str(-range) ':' ...
                                                 num2str(resolution) ':' ...
                                                 num2str(range) ');'])
            % set the total number of vectors that can be generated
            obj.nbVectors = numel(obj.grid{1});
        end
        
        function vector = getVector(obj,idx)
            vector = zeros(obj.dimension,1);
            for iter = 1:obj.dimension
                gridDimIter = obj.grid{iter};
                vector(iter) = gridDimIter(idx);
            end
        end
    end
end
