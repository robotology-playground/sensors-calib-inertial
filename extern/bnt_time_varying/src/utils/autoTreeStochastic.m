function [ model ] = autoTreeStochastic( model , sModel, sUknown )
%AUTOTREESTOCHASTIC Add stochastic component to a dynamic model
%   This function takes a structure containing an articulated rigid body
%   model (similar to the one created by autoSensSNEA) and adds to the
%   structure some fields that are used to represent the variance of
%   Newton-Euler equations describing the model itself. This function is
%   used to implement some of the ideas described in "BERDY: Bayesian
%   Estimation for Robot Dynamics. A Probabilistic Estimation of Whole-Body
%   Dynamics with Redundant Measurements." The Newton-Euler equations are
%   represented as follows:
%
%                  D(q,dq) d + b(q, dq) = 0               (1)
%
%   D has dimension (19NB, 26NB) being NB the number of rigid bodies in the
%   articulated chain. The 19NB rows are subvided in NB groups of 19 rows
%   and the 19 rows subdivided in groups of 6, 6, 6, and 1. Each of these
%   sub-sub-groups has an associated variance, denoted Sm.a, Sm.fB, Sm.f,
%   and Sm.tau respectively. The global variance for equation (1) is
%   represented in a sparse matrix Sv and its inverse stored in sparse
%   model.Sv_inv. Additional information is stored as a prior on the vector
%   d which has the following structure:
%
%              d_j = [a_j, fB_j, f_j, tau_j, fx_j, d2q_j]
%
%                d = [d_1, ... , d_NB]
%
%  A variance for the prior of fx_j, d2q_j is also represented in the matrices
%  Su.fx and Su.d2q, and the overall covariance matrix Sw represented as a
%  sparse matrix in its inverse model.Sw_inv

if nargin == 1
   sModel  = 1;
   sUknown = 1;
   generateS = @(n)eye(n);
elseif nargin == 2
   sUknown = sModel*1e3;
   generateS = @(n)generateSPDmatrix(n);
else
   generateS = @(n)generateSPDmatrix(n);
end


%% Sv
iSv_s = zeros(4*model.NB,1);
jSv_s = zeros(4*model.NB,1);
for i = 1 : model.NB
   [~, Sq    ] = jcalc( model.jtype{i} , 0);
   [~, jn(i) ] = size(Sq);
   iSv_s((i-1)*4+1 : 4*i, 1) = [6 6 6 jn(i)]';
   jSv_s((i-1)*4+1 : 4*i, 1) = [6 6 6 jn(i)]';
end
model.Sv_inv = submatrixSparse(iSv_s, jSv_s, (1:length(iSv_s))', (1:length(jSv_s))');
model.Sv     = submatrixSparse(iSv_s, jSv_s, (1:length(iSv_s))', (1:length(jSv_s))');

for i = 1 : model.NB
   S = sModel.*generateS(6);
   model.Sv_inv = set(model.Sv_inv, inv(S), (i-1)*4+1, (i-1)*4+1);
   model.Sv     = set(model.Sv    ,     S , (i-1)*4+1, (i-1)*4+1);

   S = sModel.*generateS(6);
   model.Sv_inv = set(model.Sv_inv, inv(S), (i-1)*4+2, (i-1)*4+2);
   model.Sv     = set(model.Sv    ,     S , (i-1)*4+2, (i-1)*4+2);

   S = sModel.*generateS(6);
   model.Sv_inv = set(model.Sv_inv, inv(S), (i-1)*4+3, (i-1)*4+3);
   model.Sv     = set(model.Sv    ,     S , (i-1)*4+3, (i-1)*4+3);

   S = sModel.*generateS(1);
   model.Sv_inv = set(model.Sv_inv, inv(S), (i-1)*4+4, (i-1)*4+4);
   model.Sv     = set(model.Sv    ,     S , (i-1)*4+4, (i-1)*4+4);
end

%% Sw
iSw_s = zeros(2*model.NB,1);
jSw_s = zeros(2*model.NB,1);
for i = 1 : model.NB
   iSw_s((i-1)*2+1 : 2*i, 1) = [6 jn(i)]';
   jSw_s((i-1)*2+1 : 2*i, 1) = [6 jn(i)]';
end
model.Sw_inv = submatrixSparse(iSw_s, jSw_s, (1:length(iSw_s))', (1:length(jSw_s))');
model.Sw     = submatrixSparse(iSw_s, jSw_s, (1:length(iSw_s))', (1:length(jSw_s))');

for i = 1 : model.NB
   S = sUknown.*generateS(6);
   model.Sw_inv = set(model.Sw_inv, inv(S), (i-1)*2+1, (i-1)*2+1);
   model.Sw     = set(model.Sw    ,     S , (i-1)*2+1, (i-1)*2+1);

   S = sUknown.*generateS(1);
   model.Sw_inv = set(model.Sw_inv, inv(S), (i-1)*2+2, (i-1)*2+2);
   model.Sw     = set(model.Sw    ,     S , (i-1)*2+2, (i-1)*2+2);
end

end

function A = generateSPDmatrix(n)
% Generate a dense n x n symmetric, positive definite matrix

A = rand(n,n); % generate a random n x n matrix

% construct a symmetric matrix using either
A = A+A';
% The first is significantly faster: O(n^2) compared to O(n^3)

% since A(i,j) < 1 by construction and a symmetric diagonally dominant matrix
%   is symmetric positive definite, which can be ensured by adding nI
A = A + n*eye(n);

end

