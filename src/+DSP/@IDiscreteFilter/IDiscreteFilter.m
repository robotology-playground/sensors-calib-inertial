classdef IDiscreteFilter < handle
    %This class defines the interface of a dicrete filter
    %   This shall be the interface of any low pass, high pass, pass band,
    %   cut band, etc...
    
    methods(Abstract=true)
        % Filter the input signal
        filteredMeas = process(obj,rawMeas);
        % Create a copy of self
        objCpy = copy(obj);
    end
    
end

