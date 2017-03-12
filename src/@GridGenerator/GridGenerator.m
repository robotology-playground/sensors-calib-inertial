classdef GridGenerator < handle
    %GridGenerator Generates a joint positions sequence following  grid.
    %   The grid motion is defined as 2 orthogonal sets of continuous, evenly
    %   spaced and parallel lines, as we span the space of 2 joint position 
    %   variables q1 and q2. For each set of lines, one of the variables
    %   takes a limited series of values as the other spans a given continuous
    %   range.
    
    methods(Access = public)
        function obj = GridGenerator()
        end
        
        [qT,qA,dqT,dqA,measTag] = buildGrid(obj,qTparams,qAparams,acqVel,transVel);
    end
    
    methods(Access = protected)
        pathIdxesOverGrid = getPathOnGrid(obj,aGrid);
        
        measTag = getMeasTagsFromPaths(obj,qT);
    end
end

