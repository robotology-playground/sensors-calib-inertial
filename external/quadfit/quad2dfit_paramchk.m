function [x,y,sigma_x,sigma_y] = quad2dfit_paramchk(filename, varargin)
% Quadratic 2-D fitting parameter check.

% Copyright 2012 Levente Hunyadi

narginchk(1,5);
validateattributes(filename, {'char'}, {'nonempty','row'});
if nargout > 2
    narginchk(2,5);
    switch numel(varargin)
        case 1  % compact syntax with a single 2-D matrix
            [x,y] = quad2dfit_paramchk_matrix(filename, varargin{1});
            sigma_x = 1;
            sigma_y = 1;
        case 2  % verbose syntax with two vectors
            [x,y] = quad2dfit_paramchk_vector(filename, varargin{1:2});
            sigma_x = 1;
            sigma_y = 1;
        case 3  % compact syntax with a single 2-D matrix and standard deviation values
            [x,y] = quad2dfit_paramchk_matrix(filename, varargin{1});
            [sigma_x,sigma_y] = quad2dfit_paramchk_sigma(filename, varargin{2:3});
        case 4
            [x,y] = quad2dfit_paramchk_vector(filename, varargin{1:2});
            [sigma_x,sigma_y] = quad2dfit_paramchk_sigma(filename, varargin{3:4});
    end
else
    narginchk(2,3);
    switch numel(varargin)
        case 1  % compact syntax with a single 2-D matrix
            [x,y] = quad2dfit_paramchk_matrix(filename, varargin{1});
        case 2  % verbose syntax with two vectors
            [x,y] = quad2dfit_paramchk_vector(filename, varargin{1:2});
    end
end
x = x(:);
y = y(:);

function [x,y] = quad2dfit_paramchk_matrix(filename,X)

validateattributes(X, {'numeric'}, {'real','finite','nonnan','nonempty','2d','size',[2,NaN]}, filename, 'X');
x = X(1,:);
y = X(2,:);

function [x,y] = quad2dfit_paramchk_vector(filename,x,y)

validateattributes(x, {'numeric'}, {'real','finite','nonnan','nonempty','vector'}, filename, 'x');
validateattributes(y, {'numeric'}, {'real','finite','nonnan','nonempty','vector'}, filename, 'y');

% verify that both vectors are of the same length (and matching dimensions)
count = numel(x);
validateattributes(y, {'numeric'}, {'numel',count}, filename, 'y');
[rows,cols] = size(x);
validateattributes(y, {'numeric'}, {'size',[rows,cols]}, filename, 'y');

function [sigma_x,sigma_y] = quad2dfit_paramchk_sigma(filename,sigma_x,sigma_y)

validateattributes(sigma_x, {'numeric'}, {'real','nonnegative','scalar'}, filename, 'sigma_x');
validateattributes(sigma_y, {'numeric'}, {'real','nonnegative','scalar'}, filename, 'sigma_y');
