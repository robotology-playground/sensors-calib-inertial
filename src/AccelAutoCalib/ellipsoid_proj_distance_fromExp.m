function [pVec,dVec,dOrient,d] = ellipsoid_proj_distance_fromExp(x,y,z,centre,radii,R)
% Projections and distance of points projected onto an ellipsoid.
%
% Input arguments:
% x, y, z:
%    co-ordinates of data points whose distance from the ellipsoid to measure
% centre,radii,R:
%    parameters of the ellipsoid expressed in explicit form

% projection of the data point on to the ellipsoid surface (shortest
% distance to the surface
[xp,yp,zp] = ellipsoidfit_residuals(x,y,z, centre,radii,R);
pVec = [xp yp zp];
dVec = [x-xp y-yp z-zp];    % normal vector from ellipsoid data point projection

% projection of the residual vector [x-xp,y-yp,z-zp] on to the
% "radius vector". This gives us the sign of "d" w.r.t. the ellipsoid
% surface
radius = [xp yp zp]-repmat(centre',length(xp),1); % vector from ellipsoid centre data point projection
radiusNorm = sqrt(sum(radius.^2,2));
proj = sum(radius.*dVec,2); % projection onto the radius
projSign = proj/abs(proj);
d = sqrt(sum(dVec.^2,2));
dOrient = projSign*d;
