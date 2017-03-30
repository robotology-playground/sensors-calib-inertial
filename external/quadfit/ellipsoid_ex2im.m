function p = ellipsoid_ex2im(center, radii, R)
% Cast ellipsoid defined with explicit parameters to implicit vector form.
%
% Examples:
%    p = ellipse_ex2im([xc,yc,zc],[xr,yr,zr],eye(3,3));

% Copyright 2011 Levente Hunyadi

if nargin > 0
    xc = center(1);
    yc = center(2);
    zc = center(3);
    
    xrr = 1/radii(1);
    yrr = 1/radii(2);
    zrr = 1/radii(3);
    
    r11 = R(1);
    r21 = R(2);
    r31 = R(3);
    r12 = R(4);
    r22 = R(5);
    r32 = R(6);
    r13 = R(7);
    r23 = R(8);
    r33 = R(9);

    x = 1;
    y = 1;
    z = 1;
    
    % terms collected from symbolic expression
    p = [ ...
        ; r11^2*x^2*xrr^2 + r21^2*x^2*yrr^2 + r31^2*x^2*zrr^2 ... % x^2
        ; r12^2*xrr^2*y^2 + r22^2*y^2*yrr^2 + r32^2*y^2*zrr^2 ... % y^2
        ; r13^2*xrr^2*z^2 + r23^2*yrr^2*z^2 + r33^2*z^2*zrr^2 ... % z^2
        ; 2*r11*r12*x*xrr^2*y + 2*r21*r22*x*y*yrr^2 + 2*r31*r32*x*y*zrr^2 ... % x*y
        ; 2*r11*r13*x*xrr^2*z + 2*r21*r23*x*yrr^2*z + 2*r31*r33*x*z*zrr^2 ... % x*z
        ; 2*r12*r13*xrr^2*y*z + 2*r22*r23*y*yrr^2*z + 2*r32*r33*y*z*zrr^2 ... % y*z
        ; (-2)*x*(r11^2*xc*xrr^2 + r21^2*xc*yrr^2 + r31^2*xc*zrr^2 + r11*r12*xrr^2*yc + r11*r13*xrr^2*zc + r21*r22*yc*yrr^2 + r21*r23*yrr^2*zc + r31*r32*yc*zrr^2 + r31*r33*zc*zrr^2) ... % x
        ; (-2)*y*(r12^2*xrr^2*yc + r22^2*yc*yrr^2 + r32^2*yc*zrr^2 + r11*r12*xc*xrr^2 + r21*r22*xc*yrr^2 + r12*r13*xrr^2*zc + r31*r32*xc*zrr^2 + r22*r23*yrr^2*zc + r32*r33*zc*zrr^2) ... % y
        ; (-2)*z*(r13^2*xrr^2*zc + r23^2*yrr^2*zc + r33^2*zc*zrr^2 + r11*r13*xc*xrr^2 + r12*r13*xrr^2*yc + r21*r23*xc*yrr^2 + r22*r23*yc*yrr^2 + r31*r33*xc*zrr^2 + r32*r33*yc*zrr^2) ... % z
        ; r11^2*xc^2*xrr^2 + 2*r11*r12*xc*xrr^2*yc + 2*r11*r13*xc*xrr^2*zc + r12^2*xrr^2*yc^2 + 2*r12*r13*xrr^2*yc*zc + r13^2*xrr^2*zc^2 + r21^2*xc^2*yrr^2 + 2*r21*r22*xc*yc*yrr^2 + 2*r21*r23*xc*yrr^2*zc + r22^2*yc^2*yrr^2 + 2*r22*r23*yc*yrr^2*zc + r23^2*yrr^2*zc^2 + r31^2*xc^2*zrr^2 + 2*r31*r32*xc*yc*zrr^2 + 2*r31*r33*xc*zc*zrr^2 + r32^2*yc^2*zrr^2 + 2*r32*r33*yc*zc*zrr^2 + r33^2*zc^2*zrr^2 - 1 ...
    ];
else
	sympolys x y z xc yc zc xrr yrr zrr r11 r12 r13 r21 r22 r23 r31 r32 r33;
    
    % scaling
    S = diag([xrr yrr zrr].^2); %#ok<NODEF> % reciprocal of axes lengths
    
    % rotation
    R = [ r11 r12 r13 ...
        ; r21 r22 r23 ...
        ; r31 r32 r33 ]; %#ok<NODEF>
    
    % translation
    T = sympoly(eye(4,4));
    T(1:3, 4) = -[xc yc zc]; %#ok<NODEF>
    
    % scale and rotate
    RSR = sympoly(zeros(4,4));
    RSR(1:3,1:3) = R' * S * R;
    RSR(4,4) = -1;

    % translate to the center
    Q = T' * RSR * T;
    
    % build quadratic form
    p = [x y z 1] * Q * [x;y;z;1]; %#ok<NODEF>
end