function isModel = checkModel( model )
%CHECKMODEL Check if model is a valid for featherstone's Toolbox
%   This function checks if a given model respects the format of the
%   structure used in featherstone's Toolbox to represent a dynamical
%   model. Currently the proposed implementation only checks if the model
%   has the required fields, nominally 'NB', 'jtype', 'parent', 'Xtree',
%   'I', 'appearance'. A better implementation should check the dimensions
%   of the provided model.
%
%   Genova 6 Dec 2014
%   Author Francesco Nori

fields = isfield(model,{'NB', 'jtype', 'parent', 'Xtree', 'I', 'appearance'});
if sum(fields) == 6
   isModel = 1;
else
   isModel = 0;
end

