% state is a class for storing the state of an articulated rigid body.
%
% state stores the state of articulated rigid body. The state contains the
% position (q) and the velocity (dq) of all the joints of the articulated
% rigid body. The number of joints is stored in the property 'n'. The
% values of q and dq are public and can be changed with simple property
% access. Dimension check is performed. 
%
% PROPERTIES
%    q  - joint position
%    dq - joint velocity
%    n  - number of joints
% 
% METHODS
%    model.q  =  q - sets the state position to the value q
%    model.dq = dq - sets the state velocity to the value dq
%
% Author: Francesco Nori
% Genova, Dec 2014

classdef state
   properties
      q, dq
   end
   
   properties(SetAccess = immutable, GetAccess = public)
      n
   end
   
   methods
      function a = state(n)
         if nargin == 1
            if mod(n,1)==0 && n > 0
               a.n  = n;
               a.q  = zeros(n,1);
               a.dq = zeros(n,1);
            else
               error('You should provide a positive integer')
            end
         else
            error('You should provide state dimension')
         end
      end
      
      function obj = set.q(obj,q)
         [a,b] = size(q);
         if (a ~= obj.n) || (b ~= 1)
            error('[ERROR] The input q should be provided as a column vector with model.NB rows');
         end
         obj.q = q;
      end % Set.q
      
      function obj = set.dq(obj,dq)
         [a,b] = size(dq);
         if (a ~= obj.n) || (b ~= 1)
            error('[ERROR] The input dq should be provided as a column vector with model.NB rows');
         end
         obj.dq = dq;
      end % Set.dq      
      
   end
end