function [xp,yp,zp] = ellipsoidfit_residuals(x,y,z, center,radii,R)
% Finds the distance of the point (x,y,z) to the nearest point on the ellipsoid.
%
% References:
% David Eberly, "Distance from a Point to an Ellipsoid", Geometric Tools,
%    http://www.geometrictools.com/, 1998-2008

% Copyright 2011 Levente Hunyadi

validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
validateattributes(z, {'numeric'}, {'real','nonempty','vector'});
isrow = size(x,2) > size(x,1);
x = x(:);
y = y(:);
z = z(:);
validateattributes(center, {'numeric'}, {'real','vector'});
center = reshape(center,1,3);
validateattributes(center, {'numeric'}, {'size',[1,3]});
validateattributes(radii, {'numeric'}, {'nonnegative','real','vector'});
radii = reshape(radii,1,3);
validateattributes(radii, {'numeric'}, {'size',[1,3]});
validateattributes(R, {'numeric'}, {'2d','real','size',[3,3]});

tolerance = 1e-9;

% apply inverse translation and rotation to axis-align data points
Uaa = bsxfun(@minus, [x,y,z], center) / R;

% project points into first quadrant
Uabs = abs(Uaa);
%plot3(Uabs(:,1), Uabs(:,2), Uabs(:,3), '.');

% set semi-axes
a = radii(1);
b = radii(2);
c = radii(3);
tol = tolerance*max([a,b,c]);

Uproj = zeros(size(Uaa));
if 0  % C-style implementation
    for i = 1 : size(Uaa,1);
        u = Uabs(i,1);
        v = Uabs(i,2);
        w = Uabs(i,3);

        % ellipsoid equation substituting normal vector condition:
        % ((a*u)/(t+a^2))^2 + ((b*v)/(t+b^2))^2 + ((c*w)/(t+c^2))^2 = 1
        %
        % equation whose root t we seek:
        % F(t) = (a^2 + t)^2*(b^2 + t)^2*(c^2 + t)^2
        %      - a^2*u^2*(b^2 + t)^2*(c^2 + t)^2
        %      - b^2*v^2*(a^2 + t)^2*(c^2 + t)^2
        %      - c^2*w^2*(a^2 + t)^2*(b^2 + t)^2 = 0

        if u^2/a^2 + v^2/b^2 + w^2/c^2 < 1  % initial value if (u,v,w) is inside the ellipse
            t = 0;
        else  % initial value if (u,v,w) is outside the ellipse
            t = max([a,b,c])*norm([u,v,w]);
        end

        % Newton's method
        for j = 1 : 100
            F = (a^2 + t)^2*(b^2 + t)^2*(c^2 + t)^2 ...
                - a^2*u^2*(b^2 + t)^2*(c^2 + t)^2 ...
                - b^2*v^2*(a^2 + t)^2*(c^2 + t)^2 ...
                - c^2*w^2*(a^2 + t)^2*(b^2 + t)^2;
            dF = (2*a^2 + 2*t)*(b^2 + t)^2*(c^2 + t)^2 ...
                + (2*b^2 + 2*t)*(a^2 + t)^2*(c^2 + t)^2 ...
                + (2*c^2 + 2*t)*(a^2 + t)^2*(b^2 + t)^2 ...
                - a^2*u^2*(2*b^2 + 2*t)*(c^2 + t)^2 ...
                - a^2*u^2*(2*c^2 + 2*t)*(b^2 + t)^2 ...
                - b^2*v^2*(2*a^2 + 2*t)*(c^2 + t)^2 ...
                - b^2*v^2*(2*c^2 + 2*t)*(a^2 + t)^2 ...
                - c^2*w^2*(2*a^2 + 2*t)*(b^2 + t)^2 ...
                - c^2*w^2*(2*b^2 + 2*t)*(a^2 + t)^2;
            r = F / dF;
            if r < tol
                break;
            end
            t = t - r;
        end

        % points projected onto ellipsoid x^2/a^2 + y^2/b^2 + z^2/c^2
        Uproj(i,1) = (a^2*u)/(t+a^2);  % x/a = (a*u)/(t+a^2)
        Uproj(i,2) = (b^2*v)/(t+b^2);  % y/b = (b*v)/(t+b^2)
        Uproj(i,3) = (c^2*w)/(t+c^2);  % z/c = (c*w)/(t+c^2)
    end
else  % vectorized
    u = Uabs(:,1);
    v = Uabs(:,2);
    w = Uabs(:,3);

    t = zeros(size(u));
    f = u.^2/a^2 + v.^2/b^2 + w.^2/c^2 > 1;  % initial value if (u,v,w) is outside the ellipse
    t(f) = max([a,b,c])* sum(Uabs(f,:).^2,2);
    
    % precalculate terms
    a2u2 = a^2*u.^2;
    b2v2 = b^2*v.^2;
    c2w2 = c^2*w.^2;
    
    % Newton's method
    for j = 1 : 100
        a2t = (a^2 + t).^2;
        b2t = (b^2 + t).^2;
        c2t = (c^2 + t).^2;
        F = a2t.*b2t.*c2t ...
            - a2u2.*b2t.*c2t ...
            - b2v2.*a2t.*c2t ...
            - c2w2.*a2t.*b2t;
        da2t = 2*(a^2 + t);
        db2t = 2*(b^2 + t);
        dc2t = 2*(c^2 + t);
        dF = da2t.*b2t.*c2t + db2t.*a2t.*c2t + dc2t.*a2t.*b2t ...
            - a2u2.*db2t.*c2t - a2u2.*dc2t.*b2t ...
            - b2v2.*da2t.*c2t - b2v2.*dc2t.*a2t ...
            - c2w2.*da2t.*b2t - c2w2.*db2t.*a2t;
        r = F ./ dF;
        if max(r) < tol
            break;
        end
        t = t - r;
    end
    
    % points projected onto ellipsoid x^2/a^2 + y^2/b^2 + z^2/c^2
    Uproj(:,1) = (a^2*u)./(t+a^2);  % x/a = (a*u)/(t+a^2)
    Uproj(:,2) = (b^2*v)./(t+b^2);  % y/b = (b*v)/(t+b^2)
    Uproj(:,3) = (c^2*w)./(t+c^2);  % z/c = (c*w)/(t+c^2)
end
%plot3(Uproj(:,1), Uproj(:,2), Uproj(:,3), '.');

% map back into originating quadrant
Uproj(:,1) = sign(Uaa(:,1)) .* Uproj(:,1);
Uproj(:,2) = sign(Uaa(:,2)) .* Uproj(:,2);
Uproj(:,3) = sign(Uaa(:,3)) .* Uproj(:,3);

U = bsxfun(@plus, Uproj * R, center);
xp = U(:,1);
yp = U(:,2);
zp = U(:,3);
if isrow
    xp = transpose(xp);
    yp = transpose(yp);
    zp = transpose(zp);
end
if nargout < 3
    plot3(xp,yp,zp,'.');
end