function [Sx,Sy,S,s] = quad2d_similarity(x,y)
% Translate data to place centroid at origin and apply isotropic scaling.

% Copyright 2012 Levente Hunyadi

validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});

n = numel(x);
mx = mean(x);
my = mean(y);

s = sqrt(2*n / sum((x - mx).^2 + (y - my).^2));  % root mean square (RMS) scaling
S = [ s, 0, -s*mx ; 0, s, -s*my ; 0, 0, 1 ];

Sx = S*x;
Sy = S*y;
