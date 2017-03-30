function [ model ] = updateVarianceDNEA( model , sigma , dby_s)
%% Increase variance of the equations that involve derivatives
%  In practice, each line of the equations is considered separately
%  and for each derivative we add an independent stochastic variable
%  with variance sigma. This is an example:
%
%  D(x) d + b(x) = 0 ---> D(x) d + b(x) + dDb dx = e
%
%  Taking the i-th row:
%
%  Di(x) d + bi(x) + dDbi dx = ei
%
%  Let mi be the 0-norm of dDbi (non-zero elements):
%
%  Di(x) d + bi(x) + dDbi dx + e_1 + ... + e_mi = ei
%
%  If e has vairance S, we replace it with S + sigma*mi



%% Sy
cm = dby_s.cm;
cn = dby_s.cn;
A = sparse(dby_s.is, dby_s.js, ones(size(dby_s.is)), cm(end), cn(end)); 
E = sum(A == 1, 2);

if isa(model.sensorsParams.Sy_inv, 'submatrixSparse')
   py = 1;
   for i = 1 : model.sensorsParams.ny
      I = py : py + model.sensorsParams.sizes{i,1} - 1;
      S = model.sensorsParams.Sy(i,i) + sigma*diag(E(I, 1));
      model.sensorsParams.Sy_inv = set(model.sensorsParams.Sy_inv, inv(S), i, i);
      model.sensorsParams.Sy     = set(model.sensorsParams.Sy    ,     S , i, i);
      py = py + model.sensorsParams.sizes{i,1};
   end
else
   error('This was not supposed to happen');
   Sy_inv = model.sensorsParams.Sy_inv;
end






