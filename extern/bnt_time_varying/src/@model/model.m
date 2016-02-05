% model is a class for representing articulated rigid body models.
%
% model is a class to represent arbitrary articulated rigid body models. At
% present the class wraps the model used in Featherstone's toolbox
% (http://royfeatherstone.org/spatial/v2/download.html). The class only
% contains two properties corresponding to the number of degrees of freedom
% and the fatherstone's model
%
% PROPERTIES
%    n           - the number of degrees of freedom
%    modelParams - the Featherstone's model (as defined in the toolbox)
%
% Author: Francesco Nori
% Genova, Dec 2014


classdef model
   properties(SetAccess = immutable, GetAccess = public)
      n, S, jn, g
   end
   
   properties(SetAccess = private, GetAccess = public)
      modelParams, sparseParams
   end
   
   methods(Static = true)
      sparseModel = calcSparse(model)
   end
      
   methods
      function a = model(modelParams)
         % deterministicIDsolver Constructor function
         if nargin == 1
            if ~checkModel(modelParams)
               error('You should provide a featherstone-like mdoel')
            end
            a.modelParams  = modelParams;
            a.sparseParams = a.calcSparse(a.modelParams);
            a.n      = modelParams.NB;
            a.S      = cell (a.n, 1);
            a.jn     = zeros(a.n, 1);
            a.g      = get_gravity(modelParams);

            
            for i = 1:a.n
               [~, a.S{i} ] = jcalc( modelParams.jtype{i} , 0);
               [~, a.jn(i)] = size(a.S{i});
            end
            
         else
            error('You should provide a featherstone-like model')
         end
      end
   end
end