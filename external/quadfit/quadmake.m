function quadmake(kind)
% Builds covariance matrices for quadratic forms.

% Copyright 2010 Levente Hunyadi

if nargin > 0
    validateattributes(kind, {'char'}, {'nonempty','row'});
else
    kind = {'2d','2d_reduced','3d','3d_koopmans','3d_taubin'};
end

%filepath = mfilename('fullpath');
%path = fileparts(filepath);
%fullfile(path, 'quad2dcov.m')

% variables
variable_x = symvariable('x');
variable_y = symvariable('y');
variable_z = symvariable('z');
x = sympoly(variable_x);
y = sympoly(variable_y);
z = sympoly(variable_z);
mx2 = sympoly(symvariable('mx2'));
mxy = sympoly(symvariable('mxy'));
my2 = sympoly(symvariable('my2'));

% projection to ellipse
if any(strcmp('2d', kind))
    % 2D covariance matrix
    phi = [x^2 x*y y^2 x y 1];
    C = symcrosscov(phi, phi);
    code(C, [], @mean)

    % 2D covariance matrix polynomial
    s = sympoly(symvariable('s'));
    sx = sympoly(symvariable('sx'));
    sy = sympoly(symvariable('sy'));
    C = subs(C, {sympoly(symvariable('sigma_x')),sympoly(symvariable('sigma_y'))}, {s*sx,s*sy});
    Cp = coeffterms(C, 0 : 2 : maxdegree(C, s), s);  % coefficients for terms [1,s.^2,s.^4]
    code(Cp, 'C', @mean)
end

if any(strcmp('2d_reduced', kind))
    % 2D reduced covariance matrix
    phi = [x^2-mx2, x*y-mxy, y^2-my2, x, y, 1];  % we assume mean(x) == 0 and mean(y) == 0
    C = symcrosscov(phi, phi, [variable_x, variable_y]);
    C = subs(C, {mx2,my2}, {mx2-sympoly(symvariable('sigma_x'))^2,my2-sympoly(symvariable('sigma_y'))^2});
    code(C, [], @mean)

    % 2D reduced covariance matrix polynomial
    s = sympoly(symvariable('s'));
    sx = sympoly(symvariable('sx'));
    sy = sympoly(symvariable('sy'));
    C = subs(C, {sympoly(symvariable('sigma_x')),sympoly(symvariable('sigma_y'))}, {s*sx,s*sy});
    Cp = coeffterms(C, 0 : 2 : maxdegree(C, s), s);  % coefficients for terms [1,s.^2,s.^4]
    code(Cp, 'C', @mean)
end

if any(strcmp('3d', kind))
    % 3D covariance matrix
    phi = [x^2 y^2 z^2 x*y x*z y*z x y z 1];
    C = symcrosscov(phi, phi);
    code(C, [], @mean)

    % 3D covariance matrix polynomial
    s = sympoly(symvariable('s'));
    sx = sympoly(symvariable('sx'));
    sy = sympoly(symvariable('sy'));
    sz = sympoly(symvariable('sz'));
    C = subs(C, {sympoly(symvariable('sigma_x')),sympoly(symvariable('sigma_y')),sympoly(symvariable('sigma_z'))}, {s*sx,s*sy,s*sz});
    Cp = coeffterms(C, 0 : 2 : maxdegree(C, s), s);  % coefficients for terms [1,s.^2,s.^4]
    code(Cp, 'C', @mean)
end

if any(strcmp('3d_koopmans', kind))
    % 3D covariance matrix for direct least squares fitting
    phi = [x^2 y^2 z^2 2*y*z 2*x*z 2*x*y 2*x 2*y 2*z 1];
    C = symcrosscov(phi, phi);
    code(C, [], @mean)

    % 3D covariance matrix polynomial for Koopmans direct fit
    s = sympoly(symvariable('s'));
    sx = sympoly(symvariable('sx'));
    sy = sympoly(symvariable('sy'));
    sz = sympoly(symvariable('sz'));
    C = subs(C, {sympoly(symvariable('sigma_x')),sympoly(symvariable('sigma_y')),sympoly(symvariable('sigma_z'))}, {s*sx,s*sy,s*sz});
    Cp = coeffterms(C, 0 : 2 : maxdegree(C, s), s);  % coefficients for terms [1,s.^2,s.^4]
    code(Cp, 'C', @mean)
end

if any(strcmp('3d_taubin', kind))
    % 3D covariance matrix for Taubin fit
    dx = [2*x, 0, 0, y, z, 0, 1, 0, 0, 0];
    dy = [0, 2*y, 0, x, 0, z, 0, 1, 0, 0];
    dz = [0, 0, 2*z, 0, x, y, 0, 0, 1, 0];
    grad = dx.^2 + dy.^2 + dz.^2;
    C = symcrosscov(grad, grad);
    code(C, [], @mean)
end