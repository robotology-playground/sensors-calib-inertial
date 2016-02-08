% sensors is a class for representing sensors on an articulated rigid body.
%
% sensors is a class to represent arbitrary sensors distributed on an
% articulated rigid body. Measurements are represented by specifying 
% the link on which the sensor is positioned (i), the type of sensor (a, f, 
% f_x, tau, d2q), and the position with respect to the link reference
% frame (Xsi). All this information is collected in the property 
% 'sensorsParams', while the overall measurement dimension is in the property
% sotred in the variable 'm'.
% PROPERTIES
%    m           - the number of measurements
%    modelParams - the sensors distribution4
%
% Author: Francesco Nori
% Genova, Dec 2014

classdef sensors
   properties(SetAccess = immutable, GetAccess = public)
      m
   end
   
   properties(SetAccess = private, GetAccess = public)
      sensorsParams
   end
   
   methods
      function a = sensors(sensorsParams)
         % deterministicIDsolver Constructor function
         if nargin == 1
            a.sensorsParams = sensorsParams;
            a.m             = sensorsParams.m;
         else
            error('You should provide a sensor model')
         end
      end
   end
end
