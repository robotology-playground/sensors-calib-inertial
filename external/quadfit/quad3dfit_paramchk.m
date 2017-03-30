function [x,y,z,sigma_x,sigma_y,sigma_z] = quad3dfit_paramchk(filename, varargin)
% Quadratic 2-D fitting parameter check.

% Copyright 2012 Levente Hunyadi

narginchk(1,7);
validateattributes(filename, {'char'}, {'nonempty','row'});
if nargout > 3
    narginchk(2,7);
    switch numel(varargin)
        case 1  % compact syntax with a single 2-D matrix
            [x,y,z] = quad3dfit_paramchk_matrix(filename, varargin{1});
            sigma_x = 1;
            sigma_y = 1;
            sigma_z = 1;
        case 3  % verbose syntax with three vectors
            [x,y,z] = quad3dfit_paramchk_vector(filename, varargin{1:3});
            sigma_x = 1;
            sigma_y = 1;
            sigma_z = 1;
        case 4  % compact syntax with a single 2-D matrix and standard deviation values
            [x,y,z] = quad3dfit_paramchk_matrix(filename, varargin{1});
            [sigma_x,sigma_y,sigma_z] = quad3dfit_paramchk_sigma(filename, varargin{2:4});
        case 6
            [x,y,z] = quad3dfit_paramchk_vector(filename, varargin{1:3});
            [sigma_x,sigma_y,sigma_z] = quad3dfit_paramchk_sigma(filename, varargin{4:6});
        otherwise
            error('MATLAB:narginchk:notEnoughInputs', 'Number of input arguments %d leads to ambiguity.', nargin);
    end
else
    narginchk(2,4);
    switch numel(varargin)
        case 1  % compact syntax with a single 2-D matrix
            [x,y,z] = quad3dfit_paramchk_matrix(filename, varargin{1});
        case 3  % verbose syntax with three vectors
            [x,y,z] = quad3dfit_paramchk_vector(filename, varargin{1:3});
        otherwise
            error('MATLAB:narginchk:notEnoughInputs', 'Number of input arguments %d leads to ambiguity.', nargin);
    end
end

x = x(:);
y = y(:);
z = z(:);

n = norm([sigma_x, sigma_y, sigma_z]);
sigma_x = sigma_x / n;
sigma_y = sigma_y / n;
sigma_z = sigma_z / n;

function [x,y,z] = quad3dfit_paramchk_matrix(filename,X)

validateattributes(X, {'numeric'}, {'real','finite','nonnan','nonempty','2d','size',[3,NaN]}, filename, 'X');
x = X(1,:);
y = X(2,:);
z = X(3,:);

function [x,y,z] = quad3dfit_paramchk_vector(filename,x,y,z)

validateattributes(x, {'numeric'}, {'real','finite','nonnan','nonempty','vector'}, filename, 'x');
validateattributes(y, {'numeric'}, {'real','finite','nonnan','nonempty','vector'}, filename, 'y');
validateattributes(z, {'numeric'}, {'real','finite','nonnan','nonempty','vector'}, filename, 'z');

% verify that both vectors are of the same length
count = numel(x);
validateattributes(x, {'numeric'}, {'size',[count,1]}, filename, 'x');
validateattributes(y, {'numeric'}, {'size',[count,1]}, filename, 'y');
validateattributes(z, {'numeric'}, {'size',[count,1]}, filename, 'z');

function [sigma_x,sigma_y,sigma_z] = quad3dfit_paramchk_sigma(filename,sigma_x,sigma_y,sigma_z)

validateattributes(sigma_x, {'numeric'}, {'real','nonnegative','scalar'}, filename, 'sigma_x');
validateattributes(sigma_y, {'numeric'}, {'real','nonnegative','scalar'}, filename, 'sigma_y');
validateattributes(sigma_z, {'numeric'}, {'real','nonnegative','scalar'}, filename, 'sigma_z');
