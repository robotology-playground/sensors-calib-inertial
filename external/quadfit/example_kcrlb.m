function example_kcrlb()
% Demonstration of fitting algoritm performance compared to KCR-LB.
% KCR-LB stands for Kanatani-Cramer-Rao lower bound.

% Copyright 2013 Levente Hunyadi

% seed random generator (reproducible experiments)
RandStream.setGlobalStream(RandStream('mt19937ar','seed',123));

% experiment parameters
iterationcount = 20;
sigmas = linspace(0, 0.5, 50);
%sigmas = linspace(0.10, 0.20, 50);

% generate data points
if 1
    N = 875;  % sample count
    cx = 12;
    cy = 13;
    a = 4;
    b = 2;
    phi = pi/6;
    [x0,y0] = ellipse(N, cx, cy, a, b, phi);
    %[x0,y0,nx0,ny0] = ellipse(N, 0, 0, 1, 1);

    % confine to range
    f = x0 < 12 & y0 < 12;
    x0 = x0(f);
    y0 = y0(f);
elseif 0
    N = 128;
    cx = 0;
    cy = 0;
    a = 100;
    b = 50;
    phi = 0;
    
    [x0,y0] = ellipse(N, cx, cy, a, b, phi);

    % confine to range
    f = x0 > 0 & y0 > 0;
    x0 = x0(f);
    y0 = y0(f);
    %plot(x0, y0, '.');
end

% true parameter vector
p = ellipse_ex2im(cx,cy,a,b,phi);
u = normalized(p2u(p));

% projection matrix for computing orthogonal projection to parameter vector
Proj = eye(6,6) - u*u';  % projection to true parameter vector

% list of estimators
estimators = {
    estimator('Direct ellipse fit', @(x,y,sigma) ellipsefit_direct(x,y)), ...
    estimator('Taubin fit', @(x,y,sigma) quad2dfit_taubin(x,y)), ...
    estimator('Hyperaccurate fit', @(x,y,sigma) quad2dfit_hyperaccurate(x,y)), ...
    estimator('Constrained fit', @(x,y,sigma) ellipsefit_koopmans(x,y,sigma,sigma)), ...
    ... % estimator('Maximum likelihood fit', @(x,y,sigma) ellipsefit(x,y)), ...
};

D_KCR = zeros(1, numel(sigmas));
for k = 1 : numel(sigmas)
    sigma = sigmas(k);

    % Kanatani-Cramer-Rao lower 
    D_KCR(k) = kcrlb(x0,y0,u,sigma);
end
assignin('base', 'D_KCR', D_KCR);

tic

B = zeros(numel(estimators), numel(sigmas));
D = zeros(numel(estimators), numel(sigmas));
nonconvergent = zeros(numel(estimators), numel(sigmas));
for k = 1 : numel(sigmas)
    sigma = sigmas(k);
    
    % parameter estimates
    P = zeros(numel(u),numel(estimators),iterationcount);
    for j = 1 : iterationcount
        x = x0 + sigma * randn(size(x0));
        y = y0 + sigma * randn(size(y0));

        for i = 1 : numel(estimators)
            estimatorfunction = estimators{i}.function;
            P(:,i,j) = normalized(p2u(estimatorfunction(x,y,sigma)));
        end
        
        if 0
            hold all;
            plot(x,y,'.');
            for i = 1 : numel(estimators)
                imconic(u2p(P(:,i,j)), [], [], 'Color', estimatorcolors{i});
            end
            imconic(p, [], [], 'Color', 'k');
            hold off;
        end
    end

    % discrepancy by the orthogonal component compared to true parameter value
    dP = zeros(size(P));
    nonconv = false(numel(estimators), iterationcount);
    for j = 1 : iterationcount
        for i = 1 : numel(estimators)
            if is_ellipse(u2p(P(:,i,j)))
                dP(:,i,j) = Proj * P(:,i,j);
                nonconv(i,j) = false;
            else
                dP(:,i,j) = NaN;
                nonconv(i,j) = true;
            end
        end
    end

    % bias
    bias = zeros(numel(estimators), 1);
    for i = 1 : numel(estimators)
        bias(i) = norm(nanmean(dP(:,i,:), 3));
    end

    % root mean square error
    dev = zeros(numel(estimators), 1);
    for i = 1 : numel(estimators)
        dev(i) = sqrt(nanmean(sum(dP(:,i,:).^2, 1), 3));
    end
    
    B(:,k) = bias;
    D(:,k) = dev;
    nonconvergent(:,k) = sum(nonconv, 2);
end

toc
nonconvergent

% plot bias for all estimators
plot_results(sigmas, B, 'Bias');

% plot root means square error for all estimators
plot_results(sigmas, D, 'Root mean square error');

assignin('base', 'B', B);
assignin('base', 'D', D);
assignin('base', 'nonconvergent', nonconvergent);

function S = estimator(name, fun)

S = struct('name', name, 'function', fun);

function D = kcrlb(x,y,u,sigma)
% Compute the Kanatani-Cramer-Rao (KCR) lower bound.
%
% Input arguments:
% x,y;
%    noise-free x and y coodinates of 2D points
% u:
%    true parameter vector corresponding to terms x^2, 2xy, y^2, 2x, 2y and 1
%
% Output arguments:
% D:
%    Kanatani-Cramer-Rao lower bound

% References:
% Kenichi Kanatani, "Ellipse Fitting with Hyperaccuracy", IEICE
%    Transactions on Information and Systems, vol. E89–D, no. 10, October 2006
%    2653--2660

C = zeros(6,6);
for k = 1 : numel(x)
    epsilon = [ x(k)^2 ; 2*x(k)*y(k) ; y(k)^2 ; 2*x(k) ; 2*y(k) ; 1 ];
    V = ...
        [    x(k)^2,     x(k)*y(k),         0, x(k),    0, 0 ...
        ; x(k)*y(k), x(k)^2+y(k)^2, x(k)*y(k), y(k), x(k), 0 ...
        ;         0,     x(k)*y(k),    y(k)^2,    0, y(k), 0 ...
        ;      x(k),          y(k),         0,    1,    0, 0 ...
        ;         0,          x(k),      y(k),    0,    1, 0 ...
        ;         0,             0,         0,    0,    0, 0 ];

    C = C + (epsilon * epsilon') / (u' * V * u);
end
D = 2 * sigma * sqrt(trace(pinv(C)));

function pn = normalized(p)

pn = p ./ norm(p) * sign(p(1));

function u = p2u(p)

u = [ p(1); 0.5*p(2); p(3); 0.5*p(4); 0.5*p(5); p(6) ];

function p = u2p(u)

p = [ u(1); 2*u(2); u(3); 2*u(4); 2*u(5); u(6) ];

function M = cmean(A,dim)
% Compute corrected mean value, ignoring the smallest and largest values.

B = sort(A,dim);
idx = repmat({':'}, 1, ndims(A));
idx{dim} = (1+5) : (size(A,dim)-5);  % discard 5 smallest and largest values
M = mean(B(idx{:}),dim);

function m = nanmean(x,dim)
% Compute mean value, ignoring NaNs.

% find NaNs and set them to zero
nans = isnan(x);
x(nans) = 0;

switch nargin
    case 1  % let the function sum figure out which dimension to use
        % count up non-NaNs
        n = sum(~nans);
        n(n==0) = NaN;  % prevent divideByZero warnings
        % sum up non-NaNs and divide by the number of non-NaNs
        m = sum(x) ./ n;
    otherwise
        % count up non-NaNs
        n = sum(~nans,dim);
        n(n==0) = NaN;  % prevent divideByZero warnings
        % sum up non-NaNs, and divide by the number of non-NaNs
        m = sum(x,dim) ./ n;
end