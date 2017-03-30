% submatrixSparse access matrix sub-blocks with sparse structure
%
% This class allows to access a given matrix A subdivided into blocks of
% arbitrary (and not necessarily constant dimension). Lets assume that we
% want to access a matrix A with 'm' rows and 'n' columns. Rows are
% subdivided into M blocks of dimensions m_1, ..., m_M. Columns are
% subdivide into blocks of dimensions n_1, ..., n_N. Of course, we have
% that m = m_1 + ... + m_M and n = n_1 + ... + n_N. The class can be
% instantiated with the following definition:
%
% As = submatrix([m_1 ... m_M], [n_1 ... n_N], [i_1 ... i_S], [j_1 ... j_S])
%
% where (i_s, j_s) for s=1...S are the non-zero blocks to be exploited in
% the sparse representation of the matrix. The submatrix A_ij corresponding
% to the blocks m_i, n_j can be obtained by simply using:
%
% A_ij = As(i,j)
%
% The indeces to access the matrix A_ij are obtained as follows:
%
% [I, J] = indeces(As, i, j);
%
% so that we have A(I,J) = A_ij. Setting the value of A_ij can be obtained
% by running the folllwing command:
%
% As = set(As, A_ij, i, j);
%
% Remarkably, in all the examples above i and j can be vectors. This
% specific class uses a sparse representation of the sparse matrix A. Non
% zero blocks are defined by calling:
%
% As = As.indices(i, j);
%
% Author: Francesco Nori
% Genova, Dec 2014

classdef submatrixSparse < submatrix
   properties
      i      % the row indices of the sparse matrix blocks
      j      % the col indices of the sparse matrix blocks
      is     % the row indices of the sparse matrix
      js     % the col indices of the sparse matrix
      ps     % ps(k) is such that is(ps(k)+1:ps(k+1)) and js(ps(k)+1:ps(k+1))
             % give the indices of the block i(k), j(k)
      ks     % pointer to the k to reach the block i,j
      As     % As(ps(k)+1:ps(k+1)) conatins the values of the block i(k), j(k)
   end
   
   methods
      function b = submatrixSparse(m, n, i, j)
         b    = b@submatrix(m,n);
         [mi, ni] = size(i);
         [mj, nj] = size(j);
         if (ni ~= 1) || (nj ~= 1) || (mi ~= mj)
            if (~isempty(i) && ~isempty(j))
               error('In defining submatrixSparse(m, n, i, j), the arguments i and j should be column vectors of the same length')
            end
         end
         b.i  = i;
         b.j  = j;
         b.is = [];
         b.js = [];
         b.ps = zeros(mi+1, 1);
         b.ks = zeros(b.cm(end), b.cn(end));
         
         b.ps(1) = 0;
         for k = 1 : mi
            [I, J] = b.indeces(i(k), j(k));
            [A, B] = meshgrid(I, J);
            A = A';
            B = B';
            b.is = [b.is; A(:)];
            b.js = [b.js; B(:)];
            b.ps(k+1) = length(b.is);
            b.ks(i(k), j(k)) = k;
         end
         b.As = zeros(size(b.is));
      end
      
      function b = set(b, Aij, i, j)
         k = b.ks(i,j);
         if (k==0)
            error('In calling set(Aij, i,j) the vaues for i and j were not declared in the definition of submatrixSparse(m, n, i, j).')
         end
         b.As(b.ps(k)+1:b.ps(k+1)) = Aij(:);
      end
      
      function b = allocate(b)
         b.matrix = sparse(b.is, b.js, b.As, b.cm(end), b.cn(end));
      end % allocate
      
      function disp(b)
         b = b.allocate;
         % b.matrix = full(b.matrix);
         disp@submatrix(b)
      end

      function B = subsref(b,S)
         if strcmp(S.type, '()') && length(S.subs) == 2
            I = S.subs{1};
            J = S.subs{2};
            if (length(I) ~= 1 || length(J) ~= 1)
               error('In calling As(i,j) the vaues i and j should be scalar.')
            end
            if (b.ks(I,J)==0)
               if I <= length(b.m) && J <= length(b.n)
                  B = zeros(b.m(I), b.n(J));
               else
                  error('In calling As(i,j) the vaues for i and j should be in the valid range')
               end
            else
               k = b.ks(I,J);
               I = b.is(b.ps(k)+1);
               J = b.js(b.ps(k)+1);
               h = b.ps(k)+1:b.ps(k+1);
               B = full(sparse(b.is(h) - I + 1, b.js(h) - J + 1, b.As(h)));
            end
         elseif strcmp(S.type, '.')
            b = b.allocate;
            eval(['B = b.' S.subs ';']);
         else
            error('The sumatrix class can be accessed only as A(i,j).')
         end
      end
      
   end
   
   %
   %       function [I, J] = indeces(obj, i, j)
   %          I  = zeros(sum(obj.m(i)),1);
   %          ii = [1 cumsum(obj.m(i)) + 1];
   %          for h = 1 : length(i)
   %             if i(h) < 0 || i(h) > length(obj.m)
   %                error('Trying to access the sumatrix outside its definition')
   %             else
   %                I(ii(h) : ii(h+1)-1,1) = 1 + obj.cm(i(h)) : obj.cm(i(h)+1);
   %             end
   %          end
   %          J  = zeros(sum(obj.n(j)),1);
   %          jj = [1 cumsum(obj.n(j)) + 1];
   %          for k = 1 : length(j)
   %             if j(k) < 0 || j(k) > length(obj.n)
   %                error('Trying to access the sumatrix outside its definition')
   %             else
   %                J(jj(k) : jj(k+1)-1,1) = 1 + obj.cn(j(k)) : obj.cn(j(k)+1);
   %             end
   %          end
   %       end
   %
   %       function disp(b)
   %          for i = 1 : length(b.m)
   %             fprintf('\n A(%d,*): \n \n', i)
   %             [I,~] = b.indeces(i, 1);
   %             for k = 1 : length(I)
   %                for j = 1 : length(b.n)
   %                   [I,J] = b.indeces(i, j);
   %                   for h = 1 : length(J)
   %                      fprintf('%s ', num2str(b.matrix(I(k),J(h)), '%1.4f  '))
   %                   end
   %                   fprintf(' | ')
   %                end
   %                fprintf('\n')
   %             end
   %          end
   %       end % disp
   %
   %
   %
   %    end
end