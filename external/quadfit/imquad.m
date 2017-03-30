function kind = imquad(p_im)
% Identify type of quadratic surface.
%
% References:
% Weisstein, Eric W. "Quadratic Surface." From MathWorld--A Wolfram Web Resource.
%    http://mathworld.wolfram.com/QuadraticSurface.html 

% Copyright 2010 Levente Hunyadi

validateattributes(p_im, {'numeric'}, {'nonempty','real','vector'});
p_im = p_im(:);
validateattributes(p_im, {'numeric'}, {'size',[10,1]});

% ax^2+by^2+cz^2+2fyz+2gzx+2hxy+2px+2qy+2rz+d=0
a = p_im(1);
b = p_im(2);
c = p_im(3);
h = 0.5*p_im(4);
g = 0.5*p_im(5);
f = 0.5*p_im(6);
p = p_im(7);
q = p_im(8);
r = p_im(9);
d = p_im(10);

e = [a h g; h b f; g f c];
E = [a h g p; h b f q; g f c r; p q r d];

rho_e = rank(e);
rho_E = rank(E);
evals = svd(e);  % same as evals = eig(e) but sorted in descending order of magnitude

switch rho_e
    case 1
        switch rho_E
            case 1
                kind = 'coincident_planes';
            case 2
                kind = 'parallel_planes';  % real or imaginary
            case 3
                kind = 'parabolic cylinder';
        end
    case 2
        switch rho_E
            case 2
                % test for matching signs of the nonzero eigenvalues
                if prod(evals(1:2)) > 0  % signs of the nonzero eigenvalues are the same
                    kind = 'imaginary_intersecting_planes';
                else
                    kind = 'real_intersecting_planes';
                end
            case 3
                % test for matching signs of the nonzero eigenvalues
                if prod(evals(1:3)) > 0  % signs of the nonzero eigenvalues are the same
                    kind = 'elliptic_cylinder';  % real or imaginary
                else
                    kind = 'hyperbolic_cylinder';
                end
            case 4
                if prod(evals) > 0
                    kind = 'elliptic_paraboloid';
                else
                    kind = 'hyperbolic_paraboloid';
                end
        end
    case 3
        switch rho_E
            case 3
                if prod(evals) > 0
                    kind = 'imaginary_elliptic_cone';
                else
                    kind = 'real_elliptic_cone';
                end
            case 4
                if prod(evals) > 0
                    if det(E) > 0
                        kind = 'imaginary_ellipsoid';
                    else
                        kind = 'real_ellipsoid';
                    end
                else
                    if det(E) > 0
                        kind = 'hyperboloid_of_one_sheet';
                    else
                        kind = 'hyperboloid_of_two_sheets';
                    end
                end
        end
end
