function f = nntrifaces(F, nn, x, y, z)
% Nearest-neighbor triangle face vertex indices.
%
% Input arguments:
% x, y, z:
%    coordinates of points the nearest neighbors of which to seek
% F:
%    a 3x3xn array of face vertex coordinates
%
% Output arguments:
% f:
%    an nx1 logical vector that selects elements of the face vertex array

% Copyright 2011 Levente Hunyadi

validateattributes(F, {'numeric'}, {'real','finite','size',[3,3,NaN]});
validateattributes(nn, {'numeric'}, {'real','positive','integer','scalar'});
validateattributes(x, {'numeric'}, {'real','finite','nonempty','vector'});
n = numel(x);
validateattributes(y, {'numeric'}, {'real','finite','nonempty','vector','numel',n});
validateattributes(z, {'numeric'}, {'real','finite','nonempty','vector','numel',n});

f = false(size(F,3),1);  % faces to select
if exist('kdtree', 'file')  % approach using a kd-tree
    tree = kdtree(transpose(reshape(F, 3, numel(F)/3)));  % build kd-tree of points grouped by threes
    for k = 1 : numel(x)
        ix = tree.k_nearest_neighbors([x(k),y(k),z(k)], nn);
        nnf = false(size(f));
        nnf(floor((ix+2) / 3)) = true;  % include all points of the triangle, map groups of threes to face index
        f = f | nnf;
    end
else  % approach using standard MatLab
    M = reshape(F, 3, numel(F)/3);
    for k = 1 : numel(x)
        dist = sum(bsxfun(@minus, M, [x(k);y(k);z(k)]).^2, 1);
        [~,ix] = sort(dist);
        nnf = false(size(f));
        nnf(floor((ix(1:nn)+2) / 3)) = true;  % include all points of the triangle, map groups of threes to face index
        f = f | nnf;
    end
end