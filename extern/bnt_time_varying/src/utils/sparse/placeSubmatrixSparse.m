function [ i, j, s ] = placeSubmatrixSparse( h, k, A)
%SUBMATRIXSPARSE build indeces for placing a submatrix in a sparse matrix 
%   This function takes a non-sparse matrix A and gives the indeces (i,j)
%   and the values (s) which can be used to place the same matrix
%   within a bigger matrix at position (h,k).

[g, l] = size(A);
[a, b] = meshgrid(h-1+(1:g),k-1+(1:l));
i = a';   j = b';   s = A(:);

non_zero_ind = find(s);
i = i(non_zero_ind);
j = j(non_zero_ind);
s = s(non_zero_ind);

end

