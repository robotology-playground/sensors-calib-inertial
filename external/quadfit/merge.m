function [c,ia,ib] = merge(a, b)
% Merge two sorted arrays.
%
% Input arguments:
% a, b:
%    a sorted array with the comparison operator lt defined on its members
%
% Output arguments:
% c:
%    the merged array
% ia:
%    indices of a in c such that all c(ia) == a
% ib:
%    indices of b in c such that all c(ib) == b
%
% See also: lt, issorted

if iscellstr(a) && iscellstr(b)
    c = union(a, b);
    if nargout > 1
        [~,ia] = ismember(a, c);
        [~,ib] = ismember(b, c);
    end
else
    na = numel(a);
    nb = numel(b);

    ia = zeros(1,na);
    ib = zeros(1,nb);

    ka = 1;
    kb = 1;
    k = 1;
    while ka <= na && kb <= nb  % merge until we run out of elements in either a or b
        if a(ka) < b(kb)  % take element from a
            ia(ka) = k;
            ka = ka + 1;
        elseif a(ka) == b(kb)  % take element from both a and b
            ia(ka) = k;
            ib(kb) = k;
            ka = ka + 1;
            kb = kb + 1;
        else  % b(kb) < a(ka)  % take element from b
            ib(kb) = k;
            kb = kb + 1;
        end
        k = k + 1;
    end
    ia(ka:end) = k:k+na-ka;  % copy remaining elements from a
    ib(kb:end) = k:k+nb-kb;  % copy remaining elements from b

    c([ia ib]) = [a b];  % create c
end