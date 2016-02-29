% state is a class for storing the measurements on a articulated rigid body.
%
% state stores the measurements values for an articulated rigid body. 
% The values are stored in the property y. Their value can be changed with
% a simple access to the property itslef, which is defined public.
% Dimensions are checked when a new value is assigned.
%
% PROPERTIES
%    y  - measurement value
% 
% METHODS
%    meas.y  =  y - sets the measurements to the value y
%
% Author: Francesco Nori
% Genova, Dec 2014

classdef meas
   properties
      y
   end
   
   properties(SetAccess = immutable, GetAccess = public)
      m
   end
   
   methods
      function a = meas(m)
         if nargin == 1
            if mod(m,1)==0 && m > 0
               a.m  = m;
               a.y  = zeros(m,1);
            else
               error('You should provide a positive integer')
            end
         else
            error('You should provide input dimension')
         end
      end
      
      function obj = set.y(obj,y)
         [a,b] = size(y);
         if (a ~= obj.m) || (b ~= 1)
            error('[ERROR] The input y should be provided as a column vector with meas.m rows');
         end
         obj.y = y;
      end % Set.y      
   end
end