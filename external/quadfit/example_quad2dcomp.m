function example_quad2dcomp
% Comparison of various ellipse (and general quadratic curve) fits.

% Copyright 2013 Levente Hunyadi

% generate data points
%N = 31;  % sample count
N = 5000;
a = 100;
b = 50;
t = linspace(0, pi/2, N);
x0 = a*cos(t);
y0 = b*sin(t);

% true parameter vector
p0 = [1/a^2 ; 0 ; 1/b^2 ; 0 ; 0 ; -1];

n = 1;  % number of Monte-Carlo simulations

methodcount = 5;
if n > 1
    sigma = linspace(0, 6, 100);
    bias = zeros(methodcount,numel(sigma));
    divergence = zeros(methodcount,numel(sigma));

    for i = 1 : numel(sigma)
        P = zeros(6,n,methodcount);
        for j = 1 : n
            sigma_x = sigma(i);
            sigma_y = sigma(i);
            [P(:,j,1),P(:,j,2),P(:,j,3),P(:,j,4),P(:,j,5)] = quad2dfit_methods(x0, y0, sigma_x, sigma_y, p0);
        end
        [bias(:,i), divergence(:,i)] = bias_variance(P, p0);
    end
    
    figure;
    plot(sigma, bias(1,:), sigma, bias(2,:), sigma, bias(3,:), sigma, bias(4,:), sigma, bias(5,:));
    legend('Direct','Taubin','Kanatani','Koopmans (quad)','Koopmans');

    figure;
    plot(sigma, divergence(1,:), sigma, divergence(2,:), sigma, divergence(3,:), sigma, divergence(4,:), sigma, divergence(5,:));
    legend('Direct','Taubin','Kanatani','Koopmans (quad)','Koopmans');
else
    sigma_x = 6.5;
    sigma_y = 6.5;
    quad2dfit_methods(x0, y0, sigma_x, sigma_y, p0);
end

function [b,d] = bias_variance(U, u0)
% Bias and root-mean-square value for estimated parameters.

b = zeros(size(U,3),1);
d = zeros(size(U,3),1);
u0 = u0 / sqrt(sum(u0.^2));
for k = 1 : size(U,3)
    % normalize parameters to unit length
    nU = bsxfun(@rdivide, U(:,:,k), sqrt(sum(U(:,:,k).^2, 1)));

    % orthogonal projection of p onto the true value of p
    P = eye(6,6) - (u0 * u0');
    dU = P * nU;

    b(k) = norm(sum(dU, 2) / size(dU, 2));
    d(k) = sqrt(sum(sum(dU.^2, 1)) / size(dU, 2));
end

function [p_direct,p_taubin,p_hyper,p_nkquad,p_nkellip] = quad2dfit_methods(x0, y0, sigma_x, sigma_y, p0)
% Fits ellipses to noisy data using various estimation methods.

% pollute with noise
x = x0 + sigma_x * randn(size(x0));
y = y0 + sigma_y * randn(size(x0));

%p_ml = ellipsefit(x,y);
p_direct = ellipsefit_direct(x,y);
p_taubin = quad2dfit_taubin(x,y);
p_hyper = quad2dfit_hyperaccurate(x,y);
p_nkquad = quad2dfit_koopmans(x,y,sigma_x,sigma_y);
p_nkellip = ellipsefit_koopmans(x,y,sigma_x,sigma_y);

if nargout < 1
    if is_ellipse(p_taubin) && is_ellipse(p_hyper)
        figure;
        hold all;
        plot(x,y,'k.')
        imconic(p0);
        line = imconic(p_direct);
        setlinestyle(line, '--');
        line = imconic(p_taubin);
        setlinestyle(line, ':');
        line = imconic(p_hyper);
        setlinestyle(line, '-.');
        line = imconic(p_nkquad);
        setlinestyle(line, '--');
        line = imconic(p_nkellip);
        setlinestyle(line, '--');
        legend('Data','Actual','Direct','Taubin','Kanatani','Koopmans (quad)','Koopmans');
        hold off;
    else
        figure;
        hold all;
        plot(x,y,'k.')
        imconic(p0);
        line = imconic(p_direct);
        setlinestyle(line, '--');
        line = imconic(p_nkellip);
        setlinestyle(line, '--');
        legend('Data','Actual','Direct','Koopmans');
        hold off;
    end
end

function setlinestyle(line, style)

set(findobj(line, '-property', 'LineStyle'), 'LineStyle', style);
