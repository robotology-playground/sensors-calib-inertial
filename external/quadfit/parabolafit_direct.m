function p = parabolafit_direct(x,y)
% Direct least squares fitting of parabolas.
%
% Input arguments:
% x,y;
%    x and y coodinates of 2D points
%
% Output arguments:
% p:
%    a 6-parameter vector of the algebraic parabola fit with
%    p(1)*x^2 + p(2)*x*y + p(3)*y^2 + p(4)*x + p(5)*y + p(6) = 0
%
% References:
% Matthew Harker, Paul O'Leary and Paul Zsombor-Murray, "Direct type-specific conic
%    fitting and eigenvalue bias correction", Image and Vision Computing, 26:372-381,
%    2008.

% Copyright 2012 Levente Hunyadi

narginchk(2,2);
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);

% normalize data
mx = mean(x);
my = mean(y);
s = sqrt(0.5*sum((x - mx).^2 + (y - my).^2)/numel(x));  % root mean square (RMS) scaling
sx = s;
sy = s;
x = (x-mx)/sx;
y = (y-my)/sy;

strategy = 'reduced';
switch strategy
    case 'reduced'
        % build design matrix (with dimension reduced)
        D = [ x.^2  x.*y  y.^2  x  y ];
        mD = mean(D, 1);
        D = bsxfun(@minus, D, mD);

        % build scatter matrix
        R = D'*D;

        S1 = R(1:3,1:3);  % quadratic part of the scatter matrix
        S2 = R(1:3,4:5);  % combined part of the scatter matrix
        S3 = R(4:5,4:5);  % linear part of the scatter matrix
        T = -(S3 \ S2');  % for getting a2 from a1
        M = S1 + S2 * T;  % reduced scatter matrix
    case 'full'
        % build design matrix
        D = [ x.^2  x.*y  y.^2  x  y ones(numel(x),1) ];

        % build scatter matrix
        R = D'*D;

        S1 = R(1:3,1:3);  % quadratic part of the scatter matrix
        S2 = R(1:3,4:6);  % combined part of the scatter matrix
        S3 = R(4:6,4:6);  % linear part of the scatter matrix
        T = -(S3 \ S2');  % for getting a2 from a1
        M = S1 + S2 * T;  % reduced scatter matrix
end

theta = parabolafit_directm(M);

% recover parabola coefficients
if min(size(T)) < 3
    p = [ eye(3,3) ; T ; -mD(1:3) ] * theta;
else
    p = [ eye(3,3) ; T ] * theta;
end

% unnormalize
p(:) = ...
[ p(1)*sy*sy ...
; p(2)*sx*sy ...
; p(3)*sx*sx ...
; -2*p(1)*sy*sy*mx - p(2)*sx*sy*my + p(4)*sx*sy*sy ...
; -p(2)*sx*sy*mx - 2*p(3)*sx*sx*my + p(5)*sx*sx*sy ...
; p(1)*sy*sy*mx*mx + p(2)*sx*sy*mx*my + p(3)*sx*sx*my*my - p(4)*sx*sy*sy*mx - p(5)*sx*sx*sy*my + p(6)*sx*sx*sy*sy ...
];

p = p ./ norm(p);
