function [R,Rs] = mpolycomps(T)
% Transforms a matrix polynomial into a (symmetric) linearized form.
% The matrix polynomial has the general form
% T_0 + s T_1 + ... + s^{n-1} T_{n-1} + s^n T_n
% while the linearized form is
% R_1 s + R_0
% The transformation preserves symmetry.
%
% Input arguments:
% Ts:
%    a (cell array of) matrix coefficients in the order T_0 ... T_n.
%
% See also: mpolycompan, eig
%
% References:
% E. N. Antoniou and S. Vologiannidis, "Linearizations of polynomial
%    matrices with symmetries and their applications", Electronic Journal
%    of Linear Algebra, Volume 15, pp107--114, February 2006
% E. N. Antoniou and S. Vologiannidis, "A new family of companion forms of
%    polynomial matrices", Electronic Journal of Linear Algebra, Volume 11,
%    pp78--87, April 2004

% Copyright 2008-2009 Levente Hunyadi

[~,~,n] = size(T);
cond0 = rcond(T(:,:,1));
condn = rcond(T(:,:,n));
assert(max(cond0,condn) > eps, ...
    'math:mpolysymlin:InaccurateValue', ...
    'Problem is ill-conditioned: both leading and trailing coefficients cannot be singular.');
rev = cond0 < eps;  % whether to reverse coefficient order
if rev  % ensure that leading coefficient is not singular
    T = T(:,:,end:-1:1);
end

n = n - 1;
if isodd(n)  % no matrix inversion is necessary
    B = m_inv_A_even(T);
    A = -m_A_odd(T);
else
    B = m_inv_A_odd(T);
    A = -m_A_even(T);
end
if rev  % solution to eigenproblem eig(A,B)
    R = A;
    Rs = B;
else  % solution to eigenproblem eig(B,A)
    Rs = A;
    R = B;
end

% Assembles the A_{odd} part of the companion form
% R(s) = s A^{-1}_{even} - A_{odd}  for n odd
% for T(s) using matrix composition.
function A = m_A_odd(T)

[~,p,n] = size(T);
n = n - 1;
%validateattributes(n, {'numeric'}, {'odd','nonnegative','integer'});
A = zeros(n*p, n*p);

for k = 1 : 2 : n-2
    Tk = T(:,:,k+1);  % T_1, T_3, T_5, ...
    Ck = [ -Tk, eye(p,p) ...
         ; eye(p,p), zeros(p,p) ...
         ];
    A((k-1)*p+1:(k+1)*p, (k-1)*p+1:(k+1)*p) = Ck;
end
A((n-1)*p+1:n*p, (n-1)*p+1:n*p) = -T(:,:,n+1);  % T_n  for n odd

% Assembles the A^{-1}_{odd} part of the companion form
% R(s) = s A^{-1}_{odd} - A_{even}  for n even
% for T(s) using matrix composition.
function A = m_inv_A_odd(T)

[~,p,n] = size(T);
n = n - 1;
%validateattributes(n, {'numeric'}, {'even','nonnegative','integer'});
A = zeros(n*p, n*p);

for k = 1 : 2 : n-1
    Tk = T(:,:,k+1);  % T_1, T_3, T_5
    Ck = [ zeros(p,p), eye(p,p) ...  % arrangement corresponding to inverse
         ; eye(p,p), Tk ...
         ];
    A((k-1)*p+1:(k+1)*p, (k-1)*p+1:(k+1)*p) = Ck;
end

% Assembles the A_{even} part of the companion form
% R(s) = s A^{-1}_{odd} - A_{even}  for n even
% for T(s) using matrix composition.
function A = m_A_even(T)

[~,p,n] = size(T);
n = n - 1;
%validateattributes(n, {'numeric'}, {'even','nonnegative','integer'});
A = zeros(n*p, n*p);

A(1:p,1:p) = inv( T(:,:,1) );  % T_0
for k = 2 : 2 : n-2
    Tk = T(:,:,k+1);  % T_2, T_4, T_6, ...
    Ck = [ -Tk, eye(p,p) ...
         ; eye(p,p), zeros(p,p) ...
         ];
    A((k-1)*p+1:(k+1)*p, (k-1)*p+1:(k+1)*p) = Ck;
end
A((n-1)*p+1:n*p, (n-1)*p+1:n*p) = -T(:,:,n+1);  % T_n  for n even

% Assembles the A^{-1}_{even} part of the companion form
% R(s) = s A^{-1}_{even} - A_{odd}  for n odd
% for T(s) using matrix composition.
function A = m_inv_A_even(T)

[~,p,n] = size(T);
n = n - 1;
%validateattributes(n, {'numeric'}, {'odd','nonnegative','integer'});
A = zeros(n*p, n*p);

A(1:p,1:p) = T(:,:,1);  % T_0
for k = 2 : 2 : n-1
    Tk = T(:,:,k+1);  % T_2, T_4, T_6, ...
    Ck = [ zeros(p,p), eye(p,p) ...
         ; eye(p,p), Tk ...
         ];
    A((k-1)*p+1:(k+1)*p, (k-1)*p+1:(k+1)*p) = Ck;
end

function tf = iseven(n) %#ok<DEFNU>

tf = mod(n, 2) == 0;

function tf = isodd(n)

tf = mod(n, 2) == 1;