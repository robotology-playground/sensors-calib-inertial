% submatrix access matrix sub-blocks with arbitrary dimension
%
% This class allows to access a given matrix A subdivided into blocks of
% arbitrary (and not necessarily constant dimension). Lets assume that we
% want to access a matrix A with 'm' rows and 'n' columns. Rows are
% subdivided into M blocks of dimensions m_1, ..., m_M. Columns are
% subdivide into blocks of dimensions n_1, ..., n_N. Of course, we have
% that m = m_1 + ... + m_M and n = n_1 + ... + n_N. The class can be
% instantiated with the following definition:
%
% As = submatrix(A, [m_1 ... m_M], [n_1 ... n_N])
%
% or alternatively
%
% As = submatrix([m_1 ... m_M], [n_1 ... n_N])
%
% in the latter case the matrix being instantiated identically null of
% suitable dimensions given the vectors [m_1 ... m_M], [n_1 ... n_N].
% The submatrix A_ij corresponding to the blocks m_i, n_j can be obtained
% by simply using:
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
% Remarkably, in all the examples above i and j can be vectors.
%
%
% Author: Francesco Nori
% Genova, Dec 2014

classdef submatrix
   properties
      matrix, m, n, cm, cn
   end
   
   methods
      function b = submatrix(m, n, A)
         if nargin == 3
            b.matrix  = A;
            b.m  = m(:)';
            b.n  = n(:)';
            b.cm = [0, cumsum(b.m)];
            b.cn = [0, cumsum(b.n)];
            
            
            [mA, nA] = size(A);
            if mA ~= b.cm(end)
               error('when calling submatrix(m, n, A) the sum(m) should equal the number of rows in A')
            elseif nA ~= b.cn(end)
               error('when calling submatrix(m, n, A) the sum(n) should equal the number of columns in A')
            end
         elseif nargin == 2
            b.m  = m(:)';
            b.n  = n(:)';
            
            b.cm = [0, cumsum(b.m)];
            b.cn = [0, cumsum(b.n)];
            b.matrix = zeros(b.cm(end), b.cn(end));
         end
      end
      
      function B = subsref(obj,S)
         if strcmp(S.type, '()') && length(S.subs) == 2
            [I, J] = obj.indeces(S.subs{1}, S.subs{2});
            B = obj.matrix(I, J);
            % B = submatrix(obj.A(I, J), obj.m(S.subs{1}), obj.n(S.subs{2}));
            % elseif strcmp(S.type, '.') && strcmp(S.subs, 'toDouble')
            % B = obj.A;
         elseif strcmp(S.type, '.')
            eval(['B = obj.' S.subs ';']);
         else
            error('The sumatrix class can be accessed only as A(i,j).')
         end
      end
      
      function [I, J] = indeces(obj, i, j)
         if (length(i)~=1) || (length(j)~=1)
            I  = zeros(sum(obj.m(i)),1);
            ii = [1 cumsum(obj.m(i)) + 1];
            for h = 1 : length(i)
               if i(h) < 0 || i(h) > length(obj.m)
                  error('Trying to access the sumatrix outside its definition')
               else
                  I(ii(h) : ii(h+1)-1,1) = 1 + obj.cm(i(h)) : obj.cm(i(h)+1);
               end
            end
            J  = zeros(sum(obj.n(j)),1);
            jj = [1 cumsum(obj.n(j)) + 1];
            for k = 1 : length(j)
               if j(k) < 0 || j(k) > length(obj.n)
                  error('Trying to access the sumatrix outside its definition')
               else
                  J(jj(k) : jj(k+1)-1,1) = 1 + obj.cn(j(k)) : obj.cn(j(k)+1);
               end
            end
         else
            I = (obj.cm(i)+1:obj.cm(i+1))';
            J = (obj.cn(j)+1:obj.cn(j+1))';
         end
      end
      
      function disp(b)
         for i = 1 : length(b.m)
            fprintf('\n A(%d,*): \n \n', i)
            [I,~] = b.indeces(i, 1);
            for k = 1 : length(I)
               for j = 1 : length(b.n)
                  [I,J] = b.indeces(i, j);
                  for h = 1 : length(J)
                     fprintf('%s ', num2str(b.matrix(I(k),J(h)), '%1.4f  '))
                  end
                  fprintf(' | ')
               end
               fprintf('\n')
            end
         end
      end % disp
      
      
      function obj = set(obj, Aij, i, j)
         [I,J] = obj.indeces(i, j);
         [mAij,nAij] = size(Aij);
         if length(I)~=mAij || length(J)~=nAij
            error('when setting Aij on As its dimension should match the dimensions of I and J in [I, J] = indeces(As, i, j)')
         else
            obj.matrix(I,J) = Aij;
         end
      end
      
   end
end