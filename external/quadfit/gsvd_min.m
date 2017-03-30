function [p, s] = gsvd_min(d, c)
% Singular vector belonging to smallest singular value.
%
% Input arguments:
% d:
%     an N-by-n matrix
% c:
%     an n-by-n matrix
%
% Output arguments:
% p:
%     generalized singular vector belonging to smallest singular value
% s:
%     smallest generalized singular value

% Copyright 2008-2009 Levente Hunyadi

[ug,vg,xg,cg,sg] = gsvd(d, c, 0); %#ok<ASGLU>
p = [1, -xg(1, 2 : end) / xg(2 : end, 2 : end)]';
if nargout > 1
    s = cg(1,1) / sg(1,1);  % smallest generalized singular value
end
