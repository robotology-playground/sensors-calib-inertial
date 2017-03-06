classdef GridGeneratorWOsuspend < GridGenerator
    %GridGeneratorWOpause This class generates the same grid as
    %   GridGenerator, but the acquisition is never suspended during
    %   transition motions.
    
    methods(Access = public)
        function obj = GridGeneratorWOsuspend()
        end
    end
    
    methods(Access = protected)
        measTag = getMeasTagsFromPaths(obj,qT);
    end
    
end

