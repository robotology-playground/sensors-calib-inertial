function [ model ] = updateVarianceDNEA( model , sigma , dDb_s)
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


%% Sv
cm = dDb_s.cm;
cn = dDb_s.cn;
A = sparse(dDb_s.is, dDb_s.js, ones(size(dDb_s.is)), cm(end), cn(end)); 
E = sum(A == 1, 2);

for i = 1 : model.modelParams.NB
   I = (i-1)*19+1:(i-1)*19+6;
   S = model.modelParams.Sv((i-1)*4+1, (i-1)*4+1) + sigma*diag(E(I, 1));
   model.modelParams.Sv_inv = set(model.modelParams.Sv_inv, inv(S), (i-1)*4+1, (i-1)*4+1);
   model.modelParams.Sv     = set(model.modelParams.Sv    ,     S , (i-1)*4+1, (i-1)*4+1);
   
   I = (i-1)*19+7:(i-1)*19+12;
   S = model.modelParams.Sv((i-1)*4+2, (i-1)*4+2) + sigma*diag(E(I, 1));
   model.modelParams.Sv_inv = set(model.modelParams.Sv_inv, inv(S), (i-1)*4+2, (i-1)*4+2);
   model.modelParams.Sv     = set(model.modelParams.Sv    ,     S , (i-1)*4+2, (i-1)*4+2);
   
   I = (i-1)*19+13:(i-1)*19+18;
   S = model.modelParams.Sv((i-1)*4+3, (i-1)*4+3) + sigma*diag(E(I, 1));
   model.modelParams.Sv_inv = set(model.modelParams.Sv_inv, inv(S), (i-1)*4+3, (i-1)*4+3);
   model.modelParams.Sv     = set(model.modelParams.Sv    ,     S , (i-1)*4+3, (i-1)*4+3);
   
   I = (i-1)*19+19:(i-1)*19+19;
   S = model.modelParams.Sv((i-1)*4+4, (i-1)*4+4) + sigma*diag(E(I, 1));
   model.modelParams.Sv_inv = set(model.modelParams.Sv_inv, inv(S), (i-1)*4+4, (i-1)*4+4);
   model.modelParams.Sv     = set(model.modelParams.Sv    ,     S , (i-1)*4+4, (i-1)*4+4);
end







