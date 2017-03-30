classdef sympoly
% Symbolic polynomial array of multiple variables.
%
% Symbolic polynomials are sums of symbolic terms captured with the syntax
% p = sum( c_i * prod( x_ij^p_ij ) ) + k
% where the summation is over i, and the product over j and
% * c_i is the set of polynomial term coefficients
% * x_ij is a set of symbolic variables
% * p_ij is the (usually integer) exponent of each variable in a term where at
%   least one p_ij ~= 0 for a given i
% * k is the constant term
%
% For a list of supported operations on symbolic polynomials, type
% >> methods sympoly
% For details on a particular operation, type "help sympoly.operation", e.g.
% >> help sympoly.plus

% References:
% John D'Errico, "Symbolic Polynomial Manipulation", MatLab Central File
%    Exchange, http://www.mathworks.com/matlabcentral/fileexchange/9577
%
% This is an extended version of the original implementation using
% new-style MatLab classes (declared with classdef keyword).

% Copyright 2009-2011 Levente Hunyadi

    properties (SetAccess = protected)
        ConstantValue = 0;          % Polynomial constant term.
        Variables = cell(1,0);      % Variable row vector.
        Exponents = zeros(0,0);     % Exponent matrix. Each column corresponds to a variable and each row belongs to a different term.
        Coefficients = zeros(0,1);  % Coefficient column vector. Each element is the coefficient of a different term.
    end
    methods
        function sp = sympoly(varargin)
        % Create a(n array of) symbolic polynomial object(s).
        %
        % Usage:
        %    P = sympoly
        %    P = sympoly(scalar_numeric_variable)
        %    P = sympoly(array_numeric_variable)
        %    P = sympoly('variablename')
        %    P = sympoly(size1, size2, ...)
        %    sympolys varname1 varname2 varname3 ...
        %
        % Input arguments:
        % var:
        %    character string that represents a valid Matlab variable name
        %    (e.g. 'x') or any scalar constant or array of constants
        %
        % Examples:
        % >> P = sympoly          % creates a constant monomial, P(x) = 0
        % >> P = sympoly('x')     % creates a linear monomial, P(x) = x
        % >> P = sympoly(1)       % creates a constant monomial == 1, P(x) = 1
        % >> P = sympoly(hilb(3)) % creates a 3x3 matrix of constant sympoly
        %                           variables, in this case a 3x3 Hilbert matrix
        % >> P = sympoly(3,3)     % creates an array of empty sympoly objects of the
        %                           specified size
        % >> sympolys a b x y     % creates sympoly variables with those names in
        %                           the caller workspace; this call is equivalent
        %                           to 4 separate calls:
        %                              a = sympoly('a')
        %                              b = sympoly('b')
        %                              x = sympoly('x')
        %                              y = sympoly('y')
        % >> syms x y             % creates Symbolic Toolbox variables and...
        % >> P = sympoly(x)       % converts a sym object to a sympoly object
        % >> P = sympoly(4*x^2+y) % converts a symbolic expression to a sympoly object
        % >> Q = sympoly(P)       % copies an existing sympoly
        %
        % See also: sympolys

            switch nargin
                case 0  % sympoly
                    % create a scalar sympoly as a constant
                case 1
                    inp = varargin{1};
                    if isa(inp, 'sympoly')  % copy constructor
                        sp.ConstantValue = inp.ConstantValue;
                        sp.Variables = inp.Variables;
                        sp.Exponents = inp.Exponents;
                        sp.Coefficients = inp.Coefficients;
                    elseif ischar(inp)  % a string that contains the name of a new sympoly
                        if nargout == 0  % assign a variable with this name in the caller workspace
                            assignin('caller', inp, sympoly(inp));
                        else  % create a sympoly, to be returned as an output
                            sp.Variables = {inp};
                            sp.Exponents = [1]; %#ok<NBRAK>
                            sp.Coefficients = [1]; %#ok<NBRAK>
                        end
                    elseif isnumeric(inp)  % a numeric scalar or array
                        if isscalar(inp)
                            sp.ConstantValue = inp;
                        else
                            sz = num2cell(size(inp));
                            if numel(inp) > 0
                                sp(sz{:}) = sympoly;  % initialize object array with empty constructor
                                if nnz(inp) > 0  % if there are nonzero elements to set
                                    for k = 1 : numel(inp)
                                        sp(k).ConstantValue = inp(k);  % use linear indexing in initialization
                                    end
                                end
                            else
                                sp = sympoly.empty(sz{:});
                            end
                        end
                    elseif isa(inp, 'symvariable')  % a symbolic variable name
                        sp.Variables = inp;
                        sp.Exponents = [1]; %#ok<NBRAK>
                        sp.Coefficients = [1]; %#ok<NBRAK>
                    elseif isa(inp, 'sym')
                        sp = sympoly.convertsym(inp);
                    end
                otherwise
                    assert(~iscellstr(varargin), ...  % sympoly x y z  --or--  sympoly('x','y','z')
                        'math:sympolys:ArgumentTypeMismatch', ...
                        'Multiple symbolic polynomials can be created with "sympolys x y z w".');
                    sp = sympoly.empty(0,0);
                    sp(varargin{:}) = sympoly;  % expand sympoly array to specified size
            end
        end

        function tf = eq(sp1, sp2)
        % Test equality of a symbolic polynomial object to another or a numeric value.
        %
        % See also: eq

            if isa(sp1, 'sympoly')
                tf = equals(sp1, sp2);
            else
                tf = equals(sp2, sp1);
            end
        end

        function tf = ne(sp1, sp2)
        % Test inequality of a symbolic polynomial object to another or a numeric value.
        %
        % See also: ne

            tf = ~eq(sp1, sp2);
        end

        function sp = conj(sp)
        % Complex conjugate of the coefficients of a symbolic polynomial.
        %
        % See also: conj

            if isscalar(sp)
                sp.Coefficients = conj(sp.Coefficients);
            else
                for k = 1 : numel(sp)
                    sp(k).Coefficients = conj(sp(k).Coefficients);
                end
            end
        end

        function sp = ctranspose(sp)
        % Complex conjugate transpose of symbolic polynomial array.
        %
        % See also: transpose

            sp = conj(sp.');
        end

        function sp = real(sp)
        % Real part of the coefficients of a symbolic polynomial.
        %
        % See also: real

            if isscalar(sp)
                sp.Coefficients = real(sp.Coefficients);
            else
                for k = 1 : numel(sp)
                    sp(k).Coefficients = real(sp(k).Coefficients);
                end
            end
        end

        function sp = imag(sp)
        % Imaginary part of the coefficients of a symbolic polynomial.
        %
        % See also: imag

            if isscalar(sp)
                sp.Coefficients = imag(sp.Coefficients);
            else
                for k = 1 : numel(sp)
                    sp(k).Coefficients = imag(sp(k).Coefficients);
                end
            end
        end

        function d = double(sp)
        % Convert a constant symbolic polynomial array to a double.
        %
        % See also: double

            if isscalar(sp)
                assert(isempty(sp.Variables), ...
                    'math:sympoly:InvalidOperation', ...
                    'The symbolic polynomial is not a constant, cannot cast to double.');

                d = sp.ConstantValue;
            else
                d = zeros(size(sp));
                for k = 1 : numel(sp)
                    d(k) = sp(k).ConstantValue;
                end
            end
        end

        function sp = uplus(sp)
        % Unary plus for symbolic polynomial.
        end

        function sp = uminus(sp)
        % Unary minus for symbolic polynomial.

            if isscalar(sp)
                sp.Coefficients = -sp.Coefficients;
                sp.ConstantValue = -sp.ConstantValue;
            else
                for k = 1 : numel(sp)
                    sp(k).Coefficients = -sp(k).Coefficients;
                    sp(k).ConstantValue = -sp(k).ConstantValue;
                end
            end
        end

        function sp = plus(sp1, sp2)
        % Addition for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or a numeric array

            if isa(sp1, 'sympoly')
                sp = add(sp1, sp2);
            else
                sp = add(sp2, sp1);
            end
        end

        function sp = minus(sp1, sp2)
        % Subtraction for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or a numeric array

            sp = sp1 + (-sp2);
        end

        function sp = times(sp1,sp2)
        % Elementwise multiplication for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or a numeric array

            if isa(sp1, 'sympoly')
                sp = multiply(sp1, sp2);
            else
                sp = multiply(sp2, sp1);
            end
        end

        function sp = mtimes(sp1,sp2)
        % Elementwise multiplication for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or a numeric array of compatible size

            % matrix multiplication is only defined for scalars, vectors and matrices
            validateattributes(sp1, {'sympoly','numeric'}, {'2d'}, 1);
            validateattributes(sp2, {'sympoly','numeric'}, {'2d'}, 2);

            s1 = numel(sp1);
            s2 = numel(sp2);
            if s1 == 1 || s2 == 1  % one or both are scalars
                sp = sp1 .* sp2;
            else  % both are arrays
                [m1,n1] = size(sp1);
                [m2,n2] = size(sp2);
                assert(n1 == m2, ...
                    'math:sympoly:DimensionMismatch', ...
                    'Matrix multiplication requires compatible matrix sizes.');

                sp = sympoly(zeros(m1,n2));
                for i = 1 : m1
                    for j = 1 : n2
                        lhs = sp1(i,:);
                        rhs = sp2(:,j);
                        lhs = lhs(:);
                        sp(i,j) = sum(lhs .* rhs);
                    end
                end
            end
        end

        function sp = rdivide(sp1, sp2)
        % Elementwise (right) division for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or numeric array

            if isnumeric(sp2)
                validateattributes(sp1, {'sympoly'}, {'2d'}, 1);
                validateattributes(sp2, {'numeric'}, {'2d'}, 2);

                if isscalar(sp1) && isscalar(sp2)
                    sp = sp1;
                    sp.Coefficients = sp.Coefficients ./ sp2;
                    sp.ConstantValue = sp.ConstantValue ./ sp2;
                elseif isscalar(sp2)
                    sp = sympoly(zeros(size(sp1)));
                    for k = 1 : numel(sp)
                        sp(k) = sp1(k);
                        sp(k).Coefficients = sp(k).Coefficients ./ sp2;
                        sp(k).ConstantValue = sp(k).ConstantValue ./ sp2;
                    end
                elseif isscalar(sp1)
                    sp = sympoly(zeros(size(sp2)));
                    for k = 1 : numel(sp)
                        sp(k) = sp1;
                        sp(k).Coefficients = sp(k).Coefficients ./ sp2(k);
                        sp(k).ConstantValue = sp(k).ConstantValue ./ sp2(k);
                    end
                else
                    assert(all(size(sp1) == size(sp2)), ...  % verify if they are compatible in size
                        'math:sympoly:DimensionMismatch', ...
                        'Division of symbolic polynomial array and numeric array of incompatible size.');

                    sp = sympoly(zeros(size(sp1)));
                    for k = 1 : numel(sp)
                        sp(k) = sp1(k);
                        sp(k).Coefficients = sp(k).Coefficients ./ sp2(k);
                        sp(k).ConstantValue = sp(k).ConstantValue ./ sp2(k);
                    end
                end
            elseif isnumeric(sp1)
                sp = sympoly(sp1) ./ sp2;
            else
                validateattributes(sp1, {'sympoly'}, {'2d'}, 1);
                validateattributes(sp2, {'sympoly'}, {'2d'}, 2);

                if isscalar(sp1) && isscalar(sp2)
                    sp = scalardivide(sp1, sp2);
                elseif isscalar(sp2)
                    sp = sympoly(zeros(size(sp1)));
                    for k = 1 : numel(sp)
                        sp(k) = scalardivide(sp1(k), sp2);
                    end
                elseif isscalar(sp1)
                    sp = sympoly(zeros(size(sp2)));
                    for k = 1 : numel(sp)
                        sp(k) = scalardivide(sp1, sp2(k));
                    end
                else
                    assert(all(size(sp1) == size(sp2)), ...  % verify if they are compatible in size
                        'math:sympoly:DimensionMismatch', ...
                        'Synthetic division of symbolic polynomial arrays of incompatible size.');

                    sp = sympoly(zeros(size(sp1)));
                    for k = 1 : numel(sp)
                        sp(k) = scalardivide(sp1(k), sp2(k));
                    end
                end
            end
        end

        function sp = mrdivide(sp1,sp2)
        % Matrix (right) division for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or numeric array

            validateattributes(sp1, {'sympoly','numeric'}, {'2d'}, 1);
            validateattributes(sp2, {'sympoly','numeric'}, {'2d'}, 2);

            if isscalar(sp1) || isscalar(sp2)  % one or both are scalars
                sp = sp1 ./ sp2;
            else
                error('math:sympoly:NotSupported', 'General matrix division is not supported on symbolic polynomials.');
            end
        end

        function sp = ldivide(sp1, sp2)
        % Elementwise (left) division for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or numeric array

            sp = sp2 ./ sp1;
        end

        function sp = mldivide(sp1, sp2)
        % Matrix (left) division for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or numeric array

            sp = sp2 / sp1;
        end

        function [q,r,rflag] = quorem(sp1, sp2)
        % Polynomial division with remainder.
        %
        % Output arguments:
        % q:
        %    quotient symbolic polynomial array of size max(size(sp1),size(sp2))
        % r:
        %    remainder symbolic polynomial array of size max(size(sp1),size(sp2))
        % rflag:
        %    logical array of whether the synthetic division produced a remainder

            validateattributes(sp1, {'sympoly'}, {'2d'}, 1);
            validateattributes(sp2, {'sympoly'}, {'2d'}, 2);

            if isscalar(sp1) && isscalar(sp2)
                [q,r,rflag] = longdivide(sp1, sp2);
            elseif isscalar(sp2)
                q = sympoly(zeros(size(sp1)));
                r = sympoly(zeros(size(sp1)));
                rflag = false(size(sp1));
                for k = 1 : numel(q)
                    [q(k),r(k),rflag(k)] = longdivide(sp1(k), sp2);
                end
            elseif isscalar(sp1)
                q = sympoly(zeros(size(sp2)));
                r = sympoly(zeros(size(sp2)));
                rflag = false(size(sp2));
                for k = 1 : numel(q)
                    [q(k),r(k),rflag(k)] = longdivide(sp1, sp2(k));
                end
            else
                assert(all(size(sp1) == size(sp2)), ...  % verify if they are compatible in size
                    'math:sympoly:DimensionMismatch', ...
                    'Synthetic division of symbolic polynomial arrays of incompatible size.');

                q = sympoly(zeros(size(sp1)));
                r = sympoly(zeros(size(sp1)));
                rflag = false(size(sp1));
                for k = 1 : numel(q)
                    [q(k),r(k),rflag(k)] = longdivide(sp1(k), sp2(k));
                end
            end
        end

        function [q,r,rflag] = syndivide(sp1, sp2)
        % Compatibility method.
        %
        % See also: sympoly.quorem

            [q,r,rflag] = quorem(sp1, sp2);
        end

        function sp = power(sp,n)
        % Raise a symbolic polynomial (elementwise) to a scalar power.
        %
        % If n is a non-negative integer scalar, the power is computed by
        % repeated multiplications. If n is fractional, the symbolic
        % polynomial should be single-term. Constant symbolic polynomials can be
        % raised to any power.

            validateattributes(sp, {'sympoly'}, {});
            validateattributes(n, {'numeric'}, {'real','scalar'});

            % for an array, raise the individual elements to the n-th power
            k = numel(sp);
            if isscalar(sp)  % a scalar symbolic polynomial
                if n == 0  % the zero-th power is 1
                    sp = sympoly(1);
                elseif n == 1
                    % no-op
                elseif isconstant(sp)  % e.g. sympoly(2)^5
                    sp.ConstantValue = sp.ConstantValue.^n;
                elseif real(n) && n == floor(n) && n > 0 && ~ismonomial(sp)  % a positive integer exponent and multiple terms, use multiplication
                    sp1 = sp;
                    k = 1;
                    while (2*k) <= n  % square until near k
                        sp = sp.*sp;
                        k = 2*k;
                    end

                    if k < n
                        for i = (k+1):n
                            sp = sp.*sp1;
                        end
                    end
                else  % a fractional or negative exponent can only be applied to a single term
                    assert(issingleterm(sp), ...
                        'math:sympoly:InvalidOperation', ...
                        'Fractional or negative power requires a polynomial of a single term.');

                    % raise a single term to the n-th power
                    sp.Coefficients = sp.Coefficients.^n;
                    sp.Exponents = sp.Exponents.*n;
                end
            else  % an array; raise each element to the n-th power
                for i = 1:k
                    sp(i) = sp(i).^n;
                end
            end
        end

        function sp = mpower(sp,n)
        % Raise a scalar or matrix symbolic polynomial to a scalar power.

            validateattributes(sp, {'sympoly'}, {});
            validateattributes(n, {'numeric'}, {'real','scalar'});

            if n == 0
                sp = sympoly(eye(size(sp)));
            elseif n == 1  % unit power
                % no-op
            elseif isscalar(sp)  % matrix power and elementwise power are equivalent
                sp = sp .^ n;
            elseif isconstant(sp)
                sp = sympoly(double(sp) ^ n);
            else  % symbolic polynomial array, must be square, and n must be a non-negative integer
                validateattributes(sp, {'sympoly'}, {'2d','size',[size(sp,1),size(sp,1)]});  % ensure it is square
                validateattributes(n, {'numeric'}, {'positive','integer'});  % integer power > 1

                sp1 = sp;

                k = 1;
                while k < n  % repeated squaring until close enough
                    if 2*k <= n
                        sp = sp*sp;
                        k = 2*k;
                    else
                        sp = sp*sp1;
                        k = k+1;
                    end
                end
            end
        end

        function spd = diag(sp)
        % Diagonal of square matrix or diagonal matrix from vector.
        %
        % Input arguments:
        % sp:
        %    a matrix of symbolic polynomials for diagonal extraction, or
        %    a vector of symbolic polynomials for diagonal matrix
        %    construction
        %
        % Examples:
        % >> diag(sympoly(eye(3,3))) % returns [ 1 1 1 ]
        % >> diag(sympoly(eye(2,3))) % returns [ 1 1 ]
        % >> sympolys x y;
        % >> diag([x y])             % returns [ x 0 ; 0 y ]
        %
        % See also: diag

            validateattributes(sp, {'sympoly'}, {'2d','nonempty'});

            [m,n] = size(sp);
            if m == 1 || n == 1  % sp is a vector, build a diagonal matrix from it
                l = numel(sp);
                spd = sympoly(zeros(l,l));
                spd(1 + (0:l-1)*(l+1)) = sp(:);
            else  % sp is a 2d matrix, extract the main diagonal
                p = min(m,n);
                spd = sp(1 + (0:p-1)*(m+1));
            end
        end

        function prodp = prod(sp, varargin)
        % Product of a symbolic polynomial array along a given dimension.
        %
        % Input arguments:
        % dim:
        %    a dimension to sum over, defaults to 1 (for any shape except
        %    row vector) or 2 (for row vector)
        %
        % See also: prod

            dim = operatingdimension(sp, varargin{:});
            np = ndims(sp);
            s = size(sp);

            switch np
                case 2
                    switch dim
                        case 1  % a row vector of product of rows
                            prodp = sympoly(ones(1, s(2)));
                            for k = 1 : s(1)  % enumerate rows
                                prodp = prodp .* sp(k,:);
                            end
                        case 2  % a column vector of product of columns
                            prodp = sympoly(ones(s(1), 1));
                            for k = 1 : s(2)  % enumerate columns
                                prodp = prodp .* sp(:,k);
                            end
                    end
                otherwise  % an n-dimensional array
                    ss = s;       % dimensions of original object
                    ss(dim) = 1;  % dimension to take product over

                    si = cell(1,np);
                    for i = 1:np
                        si{i} = 1:s(i);
                    end

                    if any(ss~=1)  % has non-singleton dimension
                        prodp = repmat(sympoly(1),ss);
                    else
                        prodp = sympoly(1);
                    end
                    for i = 1 : s(dim)
                        si{dim} = i;
                        prodp = prodp .* sp(si{:});
                    end
            end
        end

        function sump = sum(sp, varargin)
        % Sum a symbolic polynomial array along a given dimension.
        %
        % Input arguments:
        % dim:
        %    a dimension to sum over, defaults to 1 (for any shape except
        %    row vector) or 2 (for row vector)
        %
        % See also: sum

            dim = operatingdimension(sp, varargin{:});
            np = ndims(sp);
            s = size(sp);

            switch np
                case 2
                    switch dim
                        case 1  % sum down rows
                            sump = sympoly(zeros(1, s(2)));
                            for k = 1 : s(1)  % enumerate rows
                                sump = sump + sp(k,:);
                            end
                        case 2  % sum across columns
                            sump = sympoly(zeros(s(1), 1));
                            for k = 1 : s(2)  % enumerate columns
                                sump = sump + sp(:,k);
                            end
                    end
                otherwise  % an n-dimensional array
                    ss = s;        % e.g. [2 6 3 6]
                    ss(dim) = 1;   % e.g. [2 6 1 6] with dim = 3

                    si = cell(1,np);  % indexer cell array
                    for i = 1:np
                        si{i} = 1 : s(i);  % e.g. {1:2 1:6 1:3 1:6}
                    end

                    if any(ss~=1)  % has non-singleton dimension
                        sump = repmat(sympoly(0),ss);
                    else
                        sump = sympoly(0);
                    end
                    for i = 1 : s(dim)  % e.g. 1:3
                        si{dim} = i;    % e.g. {1:2 1:6 i 1:6}
                        sump = sump + sp(si{:});
                    end
            end
        end

        function sp = modexpon(sp, p)
        % Reduce the exponents of a symbolic polynomial to modulo p.
        %
        % p:
        %    a positive integer
        %
        % See also: mod, rem

            validateattributes(p, {'numeric'}, {'integer','scalar'});

            for k = 1 : numel(sp)
                sp(k).Exponents = mod(sp(k).Exponents, p);
                cp = clean(cp);
            end
        end

        function sp = sqrt(sp)
            assert(isconstant(sp) || ismonomial(sp), ...
                'math:sympoly:NotSupported', ...
                'Square root of symbolic polynomial with multiple terms is not supported.');

            if isconstant(sp)
                sp.ConstantValue = sqrt(sp.ConstantValue);
            elseif ismonomial(sp)
                sp.Exponents = sp.Exponents / 2;
                sp.Coefficients = sqrt(sp.Coefficients);
            end
        end

        function vars = variables(sp)
        % All variables the symbolic polynomial is a function of.
        %
        % Output arguments:
        % vars:
        %    a cell array of strings or a vector of symvariable objects, depending
        %    on the type of variables in the symbolic polynomial array

            if isscalar(sp)
                vars = sp.Variables;
            else
                vars = sp(1).Variables;
                for k = 2 : numel(sp)
                    vars = union(vars, sp(k).Variables);
                end
            end
        end

        function tf = isconstant(sp)
        % Whether the polynomial or array of polynomials comprises of constant terms.
        %
        % Examples:
        % >> x = sympoly('x');
        % >> isconstant(sympoly(2)) % returns true
        % >> isconstant(sympoly(0)) % returns true
        % >> isconstant(x)          % returns false

            if isscalar(sp)
                tf = isempty(sp.Variables);  % has no variables
            else
                tf = true;
                for k = 1 : numel(sp)
                    if ~isempty(sp(k).Variables)
                        tf = false;
                        return;
                    end
                end
            end
        end

        function tf = islinear(sp)
        % Whether at most linear terms comprise the polynomial or array of polynomials.
        %
        % Examples:
        % >> sympoly x y z;
        % >> islinear(x)          % returns true
        % >> islinear(x+y)        % returns true
        % >> islinear(x+1)        % returns true
        % >> islinear(sympoly(2)) % returns true
        % >> islinear(x^2)        % returns false
        % >> islinear(x^-2)       % returns false

            if isscalar(sp)
                tf = all(all(sp.Exponents >= 0 & sp.Exponents <= 1));
            else
                tf = true;
                for k = 1 : numel(sp)
                    if any(any(sp.Exponents < 0 | sp.Exponents > 1))
                        tf = false;
                        return;
                    end
                end
            end
        end

        function tf = isunivariate(sp)
        % Whether the symbolic polynomial or array of polynomials is univariate.
        % Univariate polynomials are a function of a single variable.
        %
        % See also: poly

            if isscalar(sp)
                tf = numel(sp.Variables) == 1;  % cannot determine variable of zero-degree polynomial
            elseif ~isempty(sp)
                for k = 1 : numel(sp)
                    if numel(sp(k).Variables) >= 2  % one of the array entries is not univariate
                        tf = false;
                        return;
                    end
                end

                vars = variables(sp);
                tf = numel(vars) == 1;
            else  % empty arrays are considered univariate
                tf = true;
            end
        end

        function tf = ismonomial(sp)
        % Whether the symbolic polynomial represents a univariate monomial.
        %
        % Examples:
        % >> sympoly x y;
        % >> ismonomial(x^6)        % returns true
        % >> ismonomial(x*y)        % returns false
        % >> ismonomial(sympoly(2)) % returns false
        % >> ismonomial(x+y)        % returns false
        % >> ismonomial(2*x)        % returns true

            validateattributes(sp, {'sympoly'}, {'scalar'});

            tf = numel(sp.Coefficients) == 1 ...  % single term
                && numel(sp.Variables) == 1 ...   % of a single variable
                && sp.ConstantValue == 0;         % with no constant value
        end

        function tf = issinglevariable(sp)
        % Whether the symbolic polynomial represents a single variable.

            validateattributes(sp, {'sympoly'}, {'scalar'});

            tf = numel(sp.Coefficients) == 1 && sp.Coefficients == 1 ...  % single term with unit coefficient
                && numel(sp.Variables) == 1 ...                           % of a single variable
                && sp.Exponents == 1 ...                                  % of degree one
                && sp.ConstantValue == 0;                                 % with no constant value
        end

        function tf = issingleterm(sp)
        % Whether the symbolic polynomial represents a single term.
        % The term may have an exponent and a coefficient but cannot be
        % the constant term.

            validateattributes(sp, {'sympoly'}, {'scalar'});

            tf = numel(sp.Coefficients) == 1 ...  % single term
                && sp.ConstantValue == 0;         % with no constant value
        end

        function spd = det(sp)
        % Determinant of a symbolic polynomial array.
        %
        % Input arguments:
        % sp:
        %    a square matrix of symbolic polynomials
        %
        % Output arguments:
        % spd:
        %    a scalar symbolic polynomial
        %
        % See also: det

            n = size(sp,1);
            validateattributes(sp, {'sympoly'}, {'2d','size',[n,n]});

            switch n
                case 1  % 1 x 1
                    spd = sp;
                case 2  % 2 x 2
                    spd = sp(1,1).*sp(2,2)-sp(1,2).*sp(2,1);
                case 3  % 3 x 3
                    spd = sp(1,1).*sp(2,2).*sp(3,3) + sp(1,2).*sp(2,3).*sp(3,1) ...
                        + sp(1,3).*sp(2,1).*sp(3,2) - sp(3,1).*sp(2,2).*sp(1,3) ...
                        - sp(3,2).*sp(2,3).*sp(1,1) - sp(3,3).*sp(2,1).*sp(1,2);
                otherwise  % 4 x 4 and higher, use minors to compute the determinant recursively
                    spd = 0;
                    minorsigns = 1;
                    for i = 1 : n
                        j = [1:i-1, i+1:n];
                        spd = spd + minorsigns .* sp(i,1) .* det(sp(j,2:n));
                        minorsigns = -minorsigns;
                    end
            end
        end

        function di = defint(sp, varargin)
        % Definite integral of a symbolic polynomial.
        %
        % Input arguments:
        % intvar:
        %    name of variable to integrate over
        % from, to:
        %    limits of integration
        %
        % Output arguments:
        % di:
        %    definite integral of the polynomial
        %
        % See also: sympoly.int

            error(nargchk(2, 4, nargin, 'struct'));
            switch nargin
                case 2  % defint(sp, [-1,1])
                    intvar = variablename(sp);
                    arg = varargin{end};
                    validateattributes(arg, {'numeric'}, {'real','size',[1,2]});
                    from = arg(1);
                    to = arg(2);
                case 3
                    if isnumeric(varargin{1})  % defint(sp, -1, 1)
                        intvar = variablename(sp);
                        from = varargin{1};
                        to = varargin{2};
                    else  % defint(sp, 'x', [-1,1])
                        intvar = variablename(sp, varargin{1});
                        arg = varargin{end};
                        validateattributes(arg, {'numeric'}, {'real','size',[1,2]});
                        from = arg(1);
                        to = arg(2);
                    end
                case 4  % defint(sp, 'x', -1, 1)
                    intvar = variablename(sp, varargin{1});
                    from = varargin{2};
                    to = varargin{3};
            end
            validateattributes(from, {'numeric'}, {'real','scalar'});
            validateattributes(to, {'numeric'}, {'real','scalar'});

            if isscalar(sp)
                ii = idefint(sp,intvar);  % indefinite integral
                di = subs(ii,intvar,to) - subs(ii,intvar,from);  % substitute at the end points of the interval, then subtract
            else
                di = zeros(size(sp));
                for k = 1 : numel(sp)
                    di(k) = defint(sp(k),intvar,from,to);
                end
            end
        end

        function sp = idefint(sp, varargin)
        % Indefinite integral of symbolic polynomial.
        %
        % Input arguments:
        % intvar (optional):
        %    name of variable to integrate with respect to
        %
        % Output arguments:
        % sp:
        %    symbolic polynomial object containing the integral polynomial
        %
        % See also: sympoly.int

            error(nargchk(1, 2, nargin, 'struct'));
            intvar = variablename(sp, varargin{:});

            if isscalar(sp)
                x = sympoly(intvar);
                sp = unionvars(sp,x);  % ensure that intvar is a variable in this polynomial
                indx = findvar(sp, intvar);

                pow = sp.Exponents(:,indx);  % which variable is it?
                assert(all(pow ~= -1), ...  % ln(x) is not in the sympoly space
                    'math:sympoly:InvalidOperation', ...
                    'Cannot integrate 1/%s.', char(intvar));

                sp.Exponents(:,indx) = sp.Exponents(:,indx) + 1;
                sp.Coefficients = sp.Coefficients ./ (pow+1);

                % add integrand for constant term
                sp.Coefficients = [ sp.Coefficients ; sp.ConstantValue ];
                pow = zeros(1, numel(sp.Variables));
                pow(indx) = 1;
                sp.Exponents = [ sp.Exponents ; pow ];
                sp.ConstantValue = 0;
                sp = clean(sp);
            else
                for k = 1 : numel(sp)
                    sp(k) = int(sp(k),intvar);
                end
            end
        end

        function sp = int(sp, varargin)
        % Integrate symbolic polynomial.
        %
        % Usage:
        %    int(expr)
        %    int(expr, v)
        %    int(expr, a, b)
        %    int(expr, v, a, b)
        %
        % See also: sympoly.defint, sympoly.idefint, sym.int

            error(nargchk(1, 4, nargin, 'struct'));
            switch nargin
                case {1,2}
                    sp = idefint(sp, varargin{:});
                case {3,4}
                    sp = defint(sp, varargin{:});
            end
        end

        function dpdx = diff(sp, varargin)
        % Derivative of symbolic polynomial.
        %
        % Input arguments:
        % var:
        %    variable to differentiate with respect to
        % n:
        %    order of differentiation, defaults to 1
        %
        % See also: sym.diff

            error(nargchk(1, 3, nargin, 'struct'));
            switch nargin
                case 1  % diff(sp)
                    assert(isunivariate(sp), ...
                        'math:sympoly:ArgumentCountMismatch', ...
                        'Variable to differentiate with respect to is unspecified.');
                    dvar = univariatesym(sp);
                    n = 1;  % set the order of differentiation
                case 2
                    if isnumeric(varargin{1})  % diff(sp, 2)
                        assert(isunivariate(sp), ...
                            'math:sympoly:ArgumentCountMismatch', ...
                            'Variable to differentiate with respect to is unspecified.');
                        dvar = univariatesym(sp);  % differentiate with respect to which variable?
                        n = varargin{1};
                    else  % diff(sp, 'x')
                        dvar = variablename(sp, varargin{1});
                        n = 1;  % assume n = 1 as default
                    end
                case 3
                    if isnumeric(varargin{1})  % diff(sp, 2, 'x')
                        dvar = variablename(sp, varargin{2});
                        n = varargin{1};
                    elseif isnumeric(varargin{2})  % diff(sp, 'x', 2)
                        dvar = variablename(sp, varargin{1});
                        n = varargin{2};
                    else
                        error('math:sympoly:ArgumentTypeMismatch', 'Arguments are of invalid type.');
                    end
            end
            validateattributes(n, {'numeric'}, {'nonnegative','integer','scalar'});

            if isscalar(sp)
                dpdx = differentiate(sp, n, dvar);
            else
                dpdx = sp;
                for k = 1 : numel(sp)
                    dpdx(k) = differentiate(sp(k), n, dvar);
                end
            end
        end

        function gradp = gradient(sp)
        % Gradient vector for symbolic polynomial.
        %
        % Output arguments:
        % gradp:
        %    symbolic polynomial vector containing the gradient vector

            validateattributes(sp, {'sympoly'}, {'scalar'});  % gradient vector supported on scalar symbolic polynomials only

            nvar = numel(sp.Variables);
            if nvar == 0  % sympoly had no variables, i.e. it was a constant
                gradp = sympoly(0);
            else  % loop over the variables
                gradp = sympoly(zeros(1,nvar));
                for i = 1 : nvar
                    gradp(i) = differentiate(sp, 1, sp.Variables(i));
                end
            end
        end

        function r = roots(sp)
        % Roots of a univariate symbolic polynomial.
        %
        % See also: poly, roots, poly, polyval

            validateattributes(sp, {'sympoly'}, {'scalar'});
            p = sym2poly(sp);
            r = roots(p);
        end

        function deg = degree(sp, varargin)
        % Degree of a symbolic polynomial w.r.t. a variable.
        %
        % Input arguments:
        % dvar:
        %    variable whose degree is sought, as a symvariable object or string

            error(nargchk(1, 2, nargin, 'struct'));
            dvar = variablename(sp, varargin{:});

            if isscalar(sp)
                indx = findvar(sp, dvar);  % find column index of variable within exponent array
                if ~isempty(indx)
                    deg = max(sp.Exponents(:,indx));
                    assert(min(sp.Exponents(:,indx)) >= 0, ...
                        'math:sympoly:InvalidOperation', ...
                        'Degree is undefined for polynomial with negative exponents.')
                    assert(all(sp.Exponents(:,indx) == floor(sp.Exponents(:,indx))), ...
                        'math:sympoly:InvalidOperation', ...
                        'Degree is undefined for fractional exponents.')
                else
                    deg = 0;
                end
            else
                deg = zeros(size(sp));
                for k = 1 : numel(sp)
                    deg(k) = degree(sp(k), dvar);
                end
            end
        end

        function deg = maxdegree(sp, varargin)
        % Greatest degree of a symbolic polynomial w.r.t. a variable.
        %
        % Input arguments:
        % dvar:
        %    variable whose degree is sought, as a symvariable object or string

            if isscalar(sp)
                error(nargchk(1, 2, nargin, 'struct'));
            else
                error(nargchk(2, 2, nargin, 'struct'));
            end
            dvar = variablename(sp, varargin{:});

            deg = -Inf;
            for k = 1 : numel(sp)
                indx = findvar(sp(k), dvar);  % find column index of variable within exponent array
                if ~isempty(indx)
                    d = max(sp(k).Exponents(:,indx));
                else
                    d = 0;
                end
                if d > deg
                    deg = d;
                end
            end
        end

        function deg = mindegree(sp, varargin)
        % Smallest degree of a symbolic polynomial w.r.t. a variable.
        %
        % Input arguments:
        % dvar:
        %    variable whose degree is sought, as a symvariable object or string

            if isscalar(sp)
                error(nargchk(1, 2, nargin, 'struct'));
            else
                error(nargchk(2, 2, nargin, 'struct'));
            end
            dvar = variablename(sp, varargin{:});

            deg = Inf;
            for k = 1 : numel(sp)
                indx = findvar(sp(k), dvar);  % find column index of variable within exponent array
                if ~isempty(indx)
                    d = min(sp(k).Exponents(:,indx));
                else
                    d = 0;
                end
                if d < deg
                    deg = d;
                end
            end
        end

        function [spterms,spcoeff] = terms(sp)
        % Terms of a symboic polynomial.

            validateattributes(sp, {'sympoly'}, {'scalar'});

            if sp.ConstantValue ~= 0
                spterms = sympoly(zeros(1, numel(sp.Coefficients) + 1));
            else
                spterms = sympoly(zeros(1, numel(sp.Coefficients)));
            end
            if nargout > 1
                spcoeff = zeros(size(spterms));
            end

            for k = 1 : numel(sp.Coefficients)
                if nargout > 1
                    spcoeff(k) = sp.Coefficients(k);
                    spterms(k).Coefficients = 1;
                    spterms(k).Variables = sp.Variables;
                    spterms(k).Exponents = sp.Exponents(k,:);
                    spterms(k) = clean(spterms(k));
                else
                    spterms(k).Coefficients = sp.Coefficients(k);
                    spterms(k).Variables = sp.Variables;
                    spterms(k).Exponents = sp.Exponents(k,:);
                    spterms(k) = clean(spterms(k));
                end
            end
            if sp.ConstantValue ~= 0
                if nargout > 1
                    spcoeff(end) = sp.ConstantValue;
                    spterms(end).ConstantValue = 1;
                else
                    spterms(end).ConstantValue = sp.ConstantValue;
                end
            end
        end

        function [coeff,terms] = coeffterms(sp, powers, varargin)
        % Coefficients of symbolic polynomial w.r.t. a variable.
        %
        % Input arguments:
        % powers:
        %    a numeric vector or a vector of univariate sympoly objects
        % var:
        %    variable a numeric power vector should be interpreter in terms of
        %
        % Output arguments:
        % coeff:
        %    coefficients of the symbolic polynomial w.r.t. the variable
        % terms:
        %    single-variable terms of the form x^p such that sp = coeff * terms

            if isnumeric(powers)
                error(nargchk(2, 3, nargin, 'struct'));
                pow = powers;

                % populate terms
                terms = sympoly(ones(1, numel(pow)));
                var = variablename(sp, varargin{:});
                symvar = sympoly(var);
                for i = 1 : numel(pow)
                    terms(i) = symvar^pow(i);
                end
            else
                error(nargchk(2, 2, nargin, 'struct'));
                terms = powers;
                validateattributes(terms, {'sympoly'}, {'vector'});

                assert(isunivariate(terms), ...
                    'math:sympoly:ArgumentTypeMismatch', ...
                    'A univariate vector of terms is expected.');
                pow = zeros(size(terms));
                for k = 1 : numel(terms)
                    assert(numel(terms(k).Exponents) == 1 && terms(k).ConstantValue == 0 && terms(k).Coefficients == 1 || isempty(terms(k).Exponents) && terms(k).ConstantValue == 1, ...
                        'A vector of powers of a variable is expected, e.g. [x, x^2, x^6, 1].');
                    if ~isempty(terms(k).Exponents)  % may be empty for constant term
                        pow(k) = terms(k).Exponents;  % a single value
                    end
                end
                assert(numel(unique(pow)) == numel(terms), ...
                    'math:sympoly:ArgumentTypeMismatch', ...
                    'A vector of different powers of a variable is expected.');
            end

            % find variable whose powers to extract coefficients of
            for k = 1 : numel(terms)
                if ~isconstant(terms(k))
                    var = variablename(terms(k));
                    break;
                end
            end

            % create coefficient array
            if isvector(sp)
                coeff = sympoly(zeros(numel(pow), numel(sp)));
            else
                coeff = sympoly(zeros([numel(pow), size(sp)]));
            end

            % populate coefficient array
            for k = 1 : numel(sp)
                vindx = findvar(sp(k), var);
                if ~isempty(vindx)  % variable found in symbolic polynomial
                    % term without variable w.r.t. which coefficients are extracted
                    baseterm = sp(k);
                    baseterm.Variables(:,vindx) = [];  % remove variable
                    baseterm.ConstantValue = 0;
                    baseterm.Exponents(:,vindx) = [];  % do not garbage collect yet

                    % exponents of variable in symbolic polynomial
                    exponents = unique(sp(k).Exponents(:,vindx));  % e.g. [0 1 2 4 7]
                    for i = 1 : numel(exponents)
                        cindx = sp(k).Exponents(:,vindx) == exponents(i);  % logical index of where given exponent is found
                        coeffterm = baseterm;
                        coeffterm.Exponents = coeffterm.Exponents(cindx,:);  % take only terms that belong to variable with given exponent (including zero exponent)
                        coeffterm.Coefficients = coeffterm.Coefficients(cindx);
                        pindx = find(exponents(i) == pow, 1);  % index of given exponent in vector of powers for entire symbolic polynomial array
                        coeff(pindx,k) = clean(coeffterm);  % k is a pseudo-linear index for dimensions higher than 1
                    end
                end
                pindx = find(0 == pow, 1);
                if ~isempty(pindx)
                    coeff(pindx,k) = coeff(pindx,k) + sp(k).ConstantValue;
                end
            end
            coeff = shiftdim(coeff, 1);
        end

        function [coeff,terms] = coeffs(sp, varargin)
        % Coefficients of symbolic polynomial w.r.t. a variable.
        %
        % Output arguments:
        % coeff:
        %    coefficients of the symbolic polynomial w.r.t. the variable
        % terms:
        %    single-variable terms of the form x^p such that sp = coeff * terms
        %
        % Examples:
        % >> sympolys x y z;
        % >> [c,t] = coeffs(x^3+y^2+z+1, x)
        % c =
        %    [ y^2 + z + 1  1 ]
        % t =
        %    [ 1  x^3 ]
        % >> [c,t] = coeffs([x^3+y^2+z+1 x^2+x*z ; x+y 1], x);
        % >> t
        % t =
        %    sympoly array of size = [1  4]
        %    [ 1  x  x^2  x^3 ]
        % >> c(:,:,1)
        % ans =
        %    [ y^2 + z + 1  0 ]
        %    [           y  1 ]
        % >> c(:,:,2)
        % ans =
        %    [ 0  z ]
        %    [ 1  0 ]
        %
        % See also: sym.coeffs, coeffterms

            error(nargchk(1, 2, nargin, 'struct'));
            var = variablename(sp, varargin{:});

            % determine the number of different terms
            pow = 0;  % powers of variable in symbolic polynomial array
            for k = 1 : numel(sp)
                vindx = findvar(sp(k), var);
                if ~isempty(vindx)  % variable found in symbolic polynomial
                    pow = union(pow, sp(k).Exponents(:,vindx));  % add powers of variable
                end
            end

            [coeff,terms] = coeffterms(sp, pow, var);
        end

        function sp = subs(sp, old, new)
        % Substitution into symbolic polynomial.
        %
        % Input arguments:
        % old (optional):
        %    symbolic variable or variable name to substitute for
        % new:
        %    symbolic polynomial or numeric value to substitute
        %
        % Examples:
        % >> sympoly x y;           % defines sympolys "x" and "y"
        % >> r = subs(x+1,'x',2*x); % adds 1, substitutes 2*x for x
        % r =
        %    2*x + 1
        % >> r = subs(x^2+1,x^2,y);
        % r =
        %    y + 1

            error(nargchk(2,3,nargin,'struct'));

            if nargin < 3  % only one extra argument, can we do the substitution?
                assert(isunivariate(sp), ...
                    'math:sympoly:ArgumentCountMismatch', ...
                        'Supply a variable to substitute for.');
                new = old;
                old = univariatesym(sp);
            end

            if ischar(old)
                validateattributes(old, {'char'}, {'nonempty','vector'});
                oldsym = sympoly(old);
            elseif isa(old, 'symvariable')
                validateattributes(old, {'symvariable'}, {'scalar'});
                oldsym = sympoly(old);
            elseif isa(old, 'sympoly')
                validateattributes(old, {'sympoly'}, {'scalar'});
                assert(issingleterm(old), ...
                    'math:sympoly:ArgumentTypeMismatch', ...
                    'A single term like c * x^p * y^q * z^r is expected.');
                oldsym = old;
            elseif iscell(old) && iscell(new)
                validateattributes(old, {'cell'}, {'nonempty','vector'}, 2);
                validateattributes(new, {'cell'}, {'nonempty','vector'}, 3);
                assert(numel(old) == numel(new), ...  % verify if they have the same number of elements
                    'math:sympoly:DimensionMismatch', ...
                    'Substitution requires the same number of elements for old and new.');

                for k = 1 : numel(old)
                    sp = subs(sp, sympoly(old{k}), sympoly(new{k}));
                end
                return;
            else
                error('math:sympoly:ArgumentTypeMismatch', ...
                    'Unrecognized type "%s" to substitute for.', class(old));
            end
            if ischar(new)
                validateattributes(new, {'char'}, {'nonempty','vector'});
                newsym = sympoly(new);
            elseif isa(new, 'symvariable')
                validateattributes(new, {'symvariable'}, {'scalar'});
                newsym = sympoly(new);
            else
                validateattributes(new, {'numeric','sympoly'}, {'scalar'});
                newsym = new;
            end

            if isscalar(sp)
                sp = substitute(sp, oldsym, newsym);
            else  % perform substitution for all entries
                for k = 1 : numel(sp)
                    sp(k) = substitute(sp(k), oldsym, newsym);
                end
            end
        end

        function sp = subspower(sp, old, new)
        % Substitution of exact power into symbolic polynomial.
        %
        % Examples:
        % >> sympolys x y;
        % >> r = subspower(x^2+1,x^2,y)
        % r =
        %    y + 2
        % >> r = subspower(x^2+1,x,y)
        % r =
        %    x^2 + 1

            if nargin < 3  % only one extra argument, can we do the substitution?
                assert(isunivariate(sp), ...
                    'math:sympoly:ArgumentCountMismatch', ...
                        'Supply a variable to substitute for.');
                new = old;
                old = univariatesym(sp);
            end

            if ischar(old)
                validateattributes(old, {'char'}, {'nonempty','vector'});
                oldsym = sympoly(name);
            elseif isa(old, 'sympoly')
                validateattributes(old, {'sympoly'}, {'scalar'});
                assert(issingleterm(old) && old.Coefficients == 1, ...
                    'math:sympoly:InvalidOperation', ...
                    'A monomial with unit coefficient (a term like x^p * y^q * z^r) is expected.');
                oldsym = old;
            end

            if isscalar(sp)
                sp = substitutepower(sp, oldsym, new);
            else  % perform substitution for all entries
                for k = 1 : numel(sp)
                    sp(k) = substitutepower(sp(k), oldsym, new);
                end
            end
        end

        function [polymean,polyvar] = errorprop(sp, vars, means, stds)
        % Symbolic mean and variance given normal components.
        %
        % Input arguments:
        % vars:
        %    the (string) name of a variable in the symbolic polynomial or a
        %    symbolic polynomial of a single variable, or a cell array of these, or
        %    a vector of symbolic polynomials if multiple variables are to be
        %    considered
        % means:
        %    a numeric vector or a vector of symbolic polynomials, representing
        %    variable means, one for each element in vars
        % stds:
        %    a numeric vector or a vector of symbolic polynomials, representing
        %    variable standard deviations, one for element in vars
        %
        % Output arguments:
        % polymean:
        %    the expected value of the symbolic polynomial as a symbolic
        %    polynomial, given independent normally distributed variables as given
        %    by the input arguments
        % polyvar:
        %    the variance of the symbolic polynomial as symbolic polynomial
        %
        % Example:
        % 1. Given a unit normal N(0,1) random variable, compute the mean and variance
        % of p(x) = 3*x + 2*x^2 - x^3.
        %
        % >> sympoly x
        % >> errorprop(3*x + 2*x^2 - x^3, x, 0, 1);
        % polymean =
        %    2
        % polyvar =
        %    14
        %
        % 2. Given normal random variables x and y, where x is N(mux,sx^2) and y has
        % parameters N(muy,sy^2), compute the mean and variance of x*y.
        %
        % >> sympoly x y mux muy sx sy
        % >> [polymean,polyvar] = errorprop(x*y, {'x','y'}, [mux,muy], [sx,sy])
        % polymean =
        %    mux*muy
        % polyvar =
        %    mux^2*sy^2 + muy^2*sx^2 + sx^2*sy^2

            validateattributes(sp, {'sympoly'}, {'scalar'});

            if ~iscell(vars)  % was there only one variable provided?
                if isa(vars, 'sympoly')
                    vars = num2cell(vars);
                else  % variable name as string or symvariable object
                    vars = { vars };
                end
            end
            nvars = numel(vars);

            for k = 1 : nvars
                if isa(vars{k}, 'sympoly')
                    validateattributes(vars{k}, {'sympoly'}, {'scalar'});
                    assert(issinglevariable(vars{k}), ...
                        'math:sympoly:InvalidOperation', ...
                        'A single-term degree-one variable with unit coefficient is expected.');
                    vars{k} = univariatesym(vars{k});
                elseif isa(vars{k}, 'symvariable')
                    validateattributes(vars{k}, {'symvariable'}, {'scalar'});
                else
                    validateattributes(vars{k}, {'char'}, {'nonempty','row'});
                end
            end

            if isnumeric(means)
                validateattributes(means, {'numeric'}, {'nonempty','real','vector'});
            else
                validateattributes(means, {'sympoly'}, {'nonempty','vector'});
            end
            means = means(:);

            if isnumeric(stds)
                validateattributes(stds, {'numeric'}, {'nonempty','real','nonnegative','vector'});
            else
                validateattributes(stds, {'sympoly'}, {'nonempty','vector'});
            end
            stds = stds(:);

            validateattributes(means, {'numeric','sympoly'}, {'size',[nvars,1]});
            validateattributes(stds, {'numeric','sympoly'}, {'size',[nvars,1]});

            % compute the expected value polynomial E(x)
            polymean = errormean(sp, vars, means, stds);
            if nargout > 1
                % compute the variance polynomial V(x) = E( (x - E(x))^2 )
                polystd = sp - polymean;
                polyvar = errormean(polystd.*polystd, vars, means, stds);
            end
        end

        function [polymean,polyvar] = polyerrorprop(sp, vars, means, stds)
        % Compatibility method.
        %
        % See also: sympoly.errorprop

            [polymean,polyvar] = errorprop(sp, vars, means, stds);
        end

        function cp = poly(sp, var)
        % Compute characteristic polynomial of symbolic polynomial matrix.

            cp = det(sp - sympoly(var).*eye(size(sp)));
        end

        function sp = renamevars(sp, from, to)
        % Map each variable of a symbolic polynomial to another.
        %
        % Examples:
        % >> x = sympoly('x')
        % >> y = sympoly('y')
        % >> renamevars(x+2*y, {'x'}, {'z'})         % returns 2*y+z
        % >> renamevars(y*x^2, {'x','y'}, {'a','b'}) % returns a^2*b

            if isscalar(sp)
                if ~isempty(sp.Variables)
                    [from,ix] = sort(from);
                    to = to(ix);

                    % test if "from" is a superset of variables in polynomial
                    if iscellstr(sp.Variables)
                        assert(iscellstr(from), ...
                            'math:sympoly:ArgumentTypeMismatch', ...
                            'The set of variables to rename from must the of the same type as those in polynomial.');
                        allvars = union(sp.Variables, from);
                        assert(iscellstr(to) || numel(from) == numel(allvars) && all(strcmp(from, allvars)), ...
                            'math:sympoly:InvalidOperation', ...
                            'Either list all variables or use compatible types for source and target variable sets.');
                    else
                        assert(strcmp(class(from), class(sp.Variables)), ...
                            'math:sympoly:ArgumentTypeMismatch', ...
                            'The set of variables to rename from must the of the same type as those in polynomial.');
                        allvars = union(sp.Variables, from);
                        assert(strcmp(class(from), class(to)) || numel(from) == numel(allvars) && all(from == allvars), ...
                            'math:sympoly:InvalidOperation', ...
                            'Either list all variables or use compatible types for source and target variable sets.');
                    end

                    assert(numel(to) == numel(unique(to)), ...
                        'math:sympoly:InvalidOperation', ...
                        'Variables in new polynomial must be unique.');

                    ix = zeros(size(sp.Variables));  % index of variables in symbolic polynomial within the set "from"
                    for k = 1 : numel(sp.Variables)
                        ixfrom = sympoly.findvarinset(sp.Variables(k), from);
                        if ~isempty(ixfrom)
                            ix(k) = ixfrom;
                        end
                    end
                    if nnz(ix) < numel(ix)  % some variables are missing from "from"
                        sp.Variables(ix > 0) = to(ix(ix > 0));
                    else  % all variables appear in "from"
                        sp.Variables = to(ix);
                    end

                    % restore alphabetic order of variables
                    sp = sortvars(sp);

                    % ensure that all variables are unique
                    uniqueselector = [ true , sp.Variables(2:end) ~= sp.Variables(1:end-1) ].';

                    if ~all(uniqueselector)  % some variables are not unique
                        % form groups of elements, each vector element is a group index
                        grp = cumsum(uniqueselector);

                        % calculate run length for the groups
                        runs = accumarray(grp,1);

                        % add coefficients that have the same set of exponents
                        exponents = zeros(numel(sp.Coefficients),numel(runs));
                        rs = 1;  % range start index
                        for k = 1 : numel(runs)
                            re = rs + runs(k) - 1;  % range end index
                            exponents(:,k) = sum(sp.Exponents(:,rs:re), 2);
                            rs = re + 1;
                        end

                        % normalize variables and set exponent matrix
                        sp.Variables = sp.Variables(uniqueselector);
                        sp.Exponents = exponents;

                        sp = clean(sp);
                    end
                end
            else
                for k = 1 : numel(sp)
                    sp(k) = renamevars(sp(k), from, to);
                end
            end
        end

        function poly = sym2poly(sp)
        % Convert univariate symbolic polynomial to numeric polynomial.
        %
        % Example:
        % >> sym2poly(3*x^4 + x^2 + 6*x + 5)   returns [3 0 1 6 5]
        %
        % See also: sym.sym2poly, polyval, poly, roots

            assert(isunivariate(sp), ...
                'math:sympoly:InvalidOperation', ...
                'Operation supported on univariate polynomials only.');
            assert(all(sp.Exponents == floor(sp.Exponents) & sp.Exponents > 0), ...
                'math:sympoly:InvalidOperation', ...
                'Negative and fractional exponents are not supported.');

            poly = zeros(1, max(sp.Exponents)+1);
            poly(end) = sp.ConstantValue;
            poly(end-sp.Exponents) = sp.Coefficients;
        end

        function [expr,vars] = sym(sp)
        % Convert symbolic polynomial to Symbolic Toolbox sym class.
        %
        % See also: sym

            if isscalar(sp)
                [expr,vars] = symobject(sp);
            else
                assert(nargout < 2, 'math:sympoly:InvalidOperation', 'Two-argument mode supported with scalar symbolic polynomials only.');

                expr = sym(zeros(size(sp)));
                for k = 1 : numel(sp)
                    expr(k) = symobject(sp(k));
                end
            end
        end

        function str = code(sp, varargin)
        % Emit MatLab code that reproduces symbolic polynomial array.
        % The generated code can be passed to the built-in eval function.
        %
        % Input arguments:
        % name (optional):
        %    the name of the variable to assign to
        % aggfun (optional):
        %    the name of an aggregator function to apply to all elements of the
        %    resulting array, e.g. 'sum' or 'mean'
        %
        % See also: eval

            error(nargchk(1, 3, nargin, 'struct'));
            if nargin > 1 && ~isempty(varargin{1})
                name = varargin{1};
                validateattributes(name, {'char'}, {'nonempty','row'}, 1);
            else
                name = '';
            end
            if nargin > 2 && ~isempty(varargin{2})
                if isa(varargin{2}, 'function_handle')
                    aggfun = func2str(varargin{2});
                    assert(~isempty(regexp(aggfun, '^[a-zA-Z][a-zA-Z0-9_]*$','once')), ...
                        'math:sympoly:ArgumentTypeMismatch', ...
                        'Code generation with aggregation expects the name of a function or the handle of a non-inline function.')
                else
                    aggfun = varargin{2};
                    validateattributes(aggfun, {'char'}, {'nonempty','row'}, 2);
                end
            else
                aggfun = '';
            end

            if isempty(sp)
                str = sprintf('%s.empty([%s])', class(sp), int2str(size(sp)));
            elseif ndims(sp) > 2
                assert(~isempty(name), ...
                    'math:sympoly:ArgumentCountMismatch', ...
                    'Code generation for n-d arrays expects a variable name to assign to.');

                s = size(sp);
                s = s(3:end);  % skip first two dimensions
                sk = [0,ones(1,numel(s)-1)];
                strs = cell(1, prod(s));
                for k = 1 : prod(s)
                    % convert linear index to subscript index
                    sk(1) = sk(1)+1;
                    while any(sk > s)
                        i = find(sk > s, 1);  % overflow in a dimension
                        sk(i) = 1;
                        sk(i+1) = sk(i+1)+1;
                    end
                    strs{k} = sprintf('\n%s(:,:,%s) = ...\n%s;', name, strjoin(sk, ','), code(sp(:,:,k), varargin{:}));  % generate code for two-dimensional array
                end
                str = sprintf('%s = %s(zeros(%s));%s', name, class(sp), strjoin(size(sp), ','), cell2mat(strs));
            else
                if ~isempty(aggfun)
                    fun = @(elem) [ aggfun '(' string(elem, 'code') ')' ];  % generate code for a scalar symbolic polynomial using an aggregator function
                else
                    fun = @(elem) string(elem, 'code');
                end
                str = formatmatrix(sp, fun, ',', ';', sprintf(' ...\n'), '[', ']');
            end
        end

        function str = latex(sp)
        % LaTeX representation of a symbolic polynomial array.
        %
        % Examples:
        % >> sympolys x y lambda;
        % >> e = x^-1 - 2*lambda^48;
        % >> latex(e)     % returns '-2 \lambda^{48} + x^{-1}'
        % >> latex([x;y]) % returns '\left[\begin{array}{r} x \\ y \end{array}\right]'

            if isempty(sp)
                str = '';
            elseif ndims(sp) > 2
                error('math:sympoly:DimensionMismatch', ...
                    'Only vectors or matrices may be converted to LaTeX, n-dimensional arrays are not supported.');
            else
                alignment = 'r';
                open = sprintf('\\left[\\begin{array}{%s}\n   ', alignment(ones(1,size(sp,2))));  % e.g. \begin{array}{rrrr}
                close = sprintf('\\end{array}\\right]');
                str = formatmatrix(sp, @(elem) string(elem, 'latex'), ' &', ' \\', sprintf('\n'), open, close);
            end
        end

        function str = string(sp, cformat)
        % Convert symbolic polynomial expression to a string.
        %
        % Input arguments:
        % cformat:
        %    number formatting for coefficients

            if isempty(sp)
                str = '';
                return
            end

            validateattributes(sp, {'sympoly'}, {'scalar'});

            constant = sp.ConstantValue;
            coefficients = sp.Coefficients;
            exponents = sp.Exponents;
            variables = sp.Variables;

            % sort coefficients in human-readable order
            [exponents,ix] = sortrows(exponents, -(1:numel(variables)));
            coefficients = coefficients(ix);

            mapvarname = @(name) name;
            mappower = @num2str;
            cformat = lower(cformat);
            switch cformat
                case 'code'
                    cformat = 'longg';
                    signmul = '.*';
                    signpow = '.^';
                case 'latex'
                    mapvarname = @(name) latexgreek(name);
                    mappower = @(power) ['{' num2str(power) '}'];
                    cformat = 'longg';
                    signmul = ' ';
                    signpow = '^';
                case {'longg','longe','long','shortg','shorte','short','rat','rational'}
                    signmul = '*';
                    signpow = '^';
                otherwise
                    cformat = 'short';
                    signmul = '*';
                    signpow = '^';
            end

            % check to see if its just a constant
            if isempty(variables)  % a constant only
                str = num2string(constant, cformat);
            else  % more than just a scalar constant
                str = '';

                % loop over the terms in the polynomial object
                firstterm = true;
                for i = 1 : numel(coefficients)
                    % build the multinomial part
                    term = '';
                    for j = 1 : numel(variables)
                        if exponents(i,j)~=0
                            term = [term,mapvarname(char(variables(j)))]; %#ok<AGROW>
                        end

                        % check whether explicit exponent is needed
                        if exponents(i,j)~=0 && exponents(i,j)~=1
                            term = [term,signpow,mappower(exponents(i,j))]; %#ok<AGROW>
                        end

                        % insert a '*' between monomial parts
                        if ~isempty(term) && j < numel(variables) && any(exponents(i,(j+1):end)) && ~strcmp(term(end-numel(signmul)+1:end), signmul)
                            term = [term,signmul]; %#ok<AGROW>
                        end
                    end

                    C = coefficients(i);
                    % if this is the first term, then leave the coefficient alone
                    if firstterm  % this is the first term of possibly many terms
                        if C == 0
                            term = '';
                        elseif C == 1 && ~isempty(term)
                            % term is already built
                        elseif C == -1 && ~isempty(term)  % add unary minus
                            term = ['-',term]; %#ok<AGROW>
                        elseif isempty(term)
                            term = num2string(C,cformat);
                        else
                            term = [num2string(C,cformat),signmul,term]; %#ok<AGROW>
                        end
                    else  % there are at least two terms in the expression
                        if C == 0
                            term = '';
                        elseif C == 1 && ~isempty(term)
                            % term is already built, just append a sign
                            term = [' + ',term]; %#ok<AGROW>
                        elseif C == -1 && ~isempty(term)
                            % term is already built, just append a sign
                            term = [' - ',term]; %#ok<AGROW>
                        elseif isempty(term) && (~isreal(C) || (C > 0))
                            term = [' + ',num2string(C,cformat)];
                        elseif isempty(term) && C < 0
                            term = [' - ',num2string(abs(C),cformat)];
                        elseif ~isreal(C) || C > 0
                            term = [' + ',num2string(C,cformat),signmul,term]; %#ok<AGROW>
                        else  % C < 0
                            term = [' - ',num2string(abs(C),cformat),signmul,term]; %#ok<AGROW>
                        end
                    end

                    str = [str, term];  %#ok<AGROW> % accumulate into the overall expression
                    firstterm = false;  % on to the rest of the terms
                end

                if ~isreal(constant) || constant > 0
                    str = [str, ' + ', num2string(constant,cformat)];
                elseif constant < 0
                    str = [str, ' - ', num2string(abs(constant),cformat)];
                end
            end
        end

        function str = char(sp)
        % Convert symbolic polynomial expression to a string representation.

            if isempty(sp)
                str = '';
                return
            end

            str = string(sp, get(0,'format'));
        end

        function disp(sp)
        % Displays a symbolic polynomial object.

            if isempty(sp)
                builtin('disp', sp);
            elseif isscalar(sp)
                disp(char(sp));
            elseif ndims(sp) == 2
                arr = cell(size(sp));
                for j = 1 : size(sp,2)
                    for i = 1 : size(sp,1)
                        arr{i,j} = char(sp(i,j));
                    end
                end
                width = max(cellfun(@length, arr), [], 1);  % find largest column widths, force calculating maximum along rows
                for i = 1 : size(sp,1)
                    fprintf('[');
                    for j = 1 : size(sp,2)
                        fprintf(' %*s ', width(j), arr{i,j});
                    end
                    fprintf(']\n');
                end
            else
                fprintf('[%s %s]\n', strjoin(size(sp), 'x'), class(sp));
            end
        end

        function display(sp)
        % Displays a symbolic polynomial object.

            name = inputname(1);
            if isempty(name)
                name = 'ans';
            end
            fprintf('%s =\n', name);

            s = size(sp);  % is it a scalar or an array?
            if isempty(sp)
                fprintf('empty %s of size = [%s]\n', class(sp), int2str(s));
            elseif any(s > 1)  % an array or vector
                fprintf('%s array of size = [%s]\n', class(sp), int2str(s));
                if ndims(sp) > 2
                    s = s(3:end);  % skip first two dimensions
                    sj = [0,ones(1,numel(s)-1)];
                    for j = 1 : prod(s)
                        % convert linear index to subscript index
                        sj(1) = sj(1)+1;
                        while any(sj > s)
                            k = find(sj > s, 1);  % overflow in a dimension
                            sj(k) = 1;
                            sj(k+1) = sj(k+1)+1;
                        end
                        fprintf('%s(:,:,%s) =\n', name, strjoin(sj, ','));
                        disp(sp(:,:,j));  % display two-dimensional array
                    end
                else
                    disp(sp);
                end
            elseif isscalar(sp)  % a scalar
                fprintf('%s\n', char(sp));
            end
        end
    end
    methods (Static)
        function sp = convertpoly(p, var)
        % Create symbolic polynomial from a numeric vector of coefficients.
        %
        % Input arguments:
        % p:
        %    a vector of coefficients of a univariate polynomial in decreasing order
        %
        % See also: poly, roots

            validateattributes(p, {'numeric'}, {'nonempty','vector'});

            p = p(:);
            sp = sympoly(var);
            sp.Exponents = transpose(numel(p)-1:-1:1);
            sp.Coefficients = p(1:end-1);
            sp.ConstantValue = p(end);
            sp = clean(sp);  % drop powers with zero coefficient
        end

        function sympoly_object = convertsym(sym_object)
        % Create symbolic polynomial from a sym object.
        %
        % See also: sym

            validateattributes(sym_object, {'sym'}, {});

            if isscalar(sym_object)
                sympoly_object = sympoly.convertscalarsym(sym_object);
            else
                sympoly_object = sympoly(zeros(size(sym_object)));
                for k = 1 : numel(sym_object)
                    sympoly_object(k) = sympoly.convertscalarsym(sym_object(k));
                end
            end
        end
    end
    methods (Static, Access = protected)
        function ix = findvarinset(var, vars)
        % Find index of variable in a variable array.

            if ischar(var)
                validateattributes(var, {'char'}, {'nonempty','row'});
                ix = strmatch(var, vars, 'exact');
            elseif iscell(var)
                validateattributes(var, {'cell'}, {'size', [1 1]});
                validateattributes(var{1}, {'char'}, {'nonempty','row'});
                ix = strmatch(var, vars, 'exact');
            else
                validateattributes(var, {'symvariable'}, {'scalar'});
                ix = find(var == vars, 1);
            end
        end
    end
    methods (Access = protected)
        function ix = findvar(sp, var)
        % Find index of variable in the symbolic polynomial variable array.

            ix = sympoly.findvarinset(var, sp.Variables);
        end

        function sp = sortvars(sp)
        % Sort variables in symbolic polynomial to ascending order.

            [sp.Variables, indx] = sort(sp.Variables);  % restore alphabetical (or natural) order of variables
            sp.Exponents = sp.Exponents(:,indx);  % rearrange exponent matrix to match an alphabetical order of variable names
        end

        function [sp1,sp2] = unionvars(sp1, sp2)
        % Ensure that symbolic polynomials use the same set of variables.
        %
        % Example:
        %    [sp1,sp2] = unionvars(sp1,sp2)

            validateattributes(sp1, {'sympoly'}, {'scalar'});
            validateattributes(sp2, {'sympoly'}, {'scalar'});

            % combine the variables
            if isempty(sp2.Variables)  % prevent trying to combine empty cell array with symvariable object
                allvars = sp1.Variables;
                loc1 = 1:numel(sp1.Variables);
                loc2 = [];
            elseif isempty(sp1.Variables)
                allvars = sp2.Variables;
                loc1 = [];
                loc2 = 1:numel(sp2.Variables);
            else
                assert(iscellstr(sp1.Variables) && iscellstr(sp2.Variables) || isa(sp1.Variables, 'symvariable') && isa(sp2.Variables, 'symvariable'), ...
                    'math:sympoly:ArgumentTypeMismatch', ...
                    'Mixing character variables and variables derived from symvariable is not allowed.');
                %allvars = union(sp1.Variables, sp2.Variables);
                [allvars,loc1,loc2] = merge(sp1.Variables, sp2.Variables);
            end
            numvars = numel(allvars);

            % expand variables in sp1
            exp1 = zeros(numel(sp1.Coefficients), numvars);
            if ~isempty(sp1.Variables)
                %[~,loc1] = ismember(sp1.Variables, allvars);
                exp1(:,loc1) = sp1.Exponents;
            end
            sp1.Variables = allvars;
            sp1.Exponents = exp1;

            % expand variables in sp2
            exp2 = zeros(numel(sp2.Coefficients), numvars);
            if ~isempty(sp2.Variables)
                %[~,loc2] = ismember(sp2.Variables, allvars);
                exp2(:,loc2) = sp2.Exponents;
            end
            sp2.Variables = allvars;
            sp2.Exponents = exp2;
        end

        function sp = clean(sp)
        % Clean up a scalar symbolic polynomial.
        % The function coalesces terms and drops excess variables.

            validateattributes(sp, {'sympoly'}, {'scalar'});

            if numel(sp.Coefficients) > 1  % collect any terms that may have coalesced
                % sort exponent vectors in ascending order
                [sp.Exponents,index] = sortrows(sp.Exponents);

                % arrange coefficients to be accumulated in same order
                sp.Coefficients = sp.Coefficients(index);

                % determine which rows are unique
                % when subtracting neighboring rows, unique rows yield nonzero results
                % the first row is always unique
                uniqueselector = [ true ; any(diff(sp.Exponents), 2) ];

                if ~all(uniqueselector)  % some exponent vectors are not unique
                    % form groups of elements, each vector element is a group index
                    grp = cumsum(uniqueselector);

                    % calculate run length for the groups
                    runs = accumarray(grp,1);

                    % add coefficients that have the same set of exponents
                    coeff = zeros(numel(runs),1);
                    rs = 1;  % range start index
                    for k = 1 : numel(runs)
                        re = rs + runs(k) - 1;  % range end index
                        coeff(k) = sum(sp.Coefficients(rs:re));
                        rs = re + 1;
                    end

                    % drop vectors that are not unique
                    sp.Exponents = sp.Exponents(uniqueselector,:);

                    % set new value vector
                    sp.Coefficients = coeff;
                end
            end

            % drop any terms with a zero coefficient, e.g. 0*x*y
            unused = sp.Coefficients == 0;
            sp.Exponents(unused,:) = [];
            sp.Coefficients(unused,:) = [];  % use two indices to keep it n-by-1 with n >= 0

            % accumulate terms with all zero exponents into constant term
            unused = all(sp.Exponents == 0, 2);
            sp.ConstantValue = sp.ConstantValue + sum(sp.Coefficients(unused));
            sp.Exponents(unused,:) = [];
            sp.Coefficients(unused,:) = [];

            % drop any variables that have all zero exponents
            unused = all(sp.Exponents == 0, 1);
            sp.Variables(:,unused) = [];  % use two indices to keep it 1-by-n with n >= 0
            sp.Exponents(:,unused) = [];
        end

        function tf = equals(lhs, rhs)
        % Test equality of a symbolic polynomial object to another or a numeric value.

            if isnumeric(rhs)  % comparing a symbolic polynomial to a number
                consts = zeros(size(lhs));
                for k = 1 : numel(lhs)
                    if ~isempty(lhs(k).Variables)
                        consts(k) = NaN;  % polynomials that contain variables are never equal to pure constants
                    else
                        consts(k) = lhs(k).ConstantValue;
                    end
                end
                tf = consts == rhs;  % fast comparison of symbolic polynomial constants with a numeric array
            elseif isa(rhs, 'sympoly')
                s1 = numel(lhs);
                s2 = numel(rhs);
                if s1 == 1 && s2 == 1  % both are scalars
                    if lhs.ConstantValue ~= rhs.ConstantValue ...
                            || numel(lhs.Variables) ~= numel(rhs.Variables) ...    % not the same number of variables
                            || numel(lhs.Coefficients) ~= numel(rhs.Coefficients)  % not the same number of terms
                        tf = false;
                    else
                        if iscellstr(lhs.Variables) && iscellstr(rhs.Variables)
                            tf = all(strcmp(lhs.Variables, rhs.Variables));  % variable names are always normalized to alphabetical order, can compare pairwise
                        else  % symvariable object variables
                            tf = all(lhs.Variables == rhs.Variables);  % variables are sorted, can compare pairwise
                        end
                        tf = tf ...
                            && all(lhs.Coefficients == rhs.Coefficients) ...  % coefficients are equal
                            && all(lhs.Exponents(:) == rhs.Exponents(:));     % matching exponents are equal
                    end
                elseif s1 > 1 && s2 == 1  % s1 is an array or vector, s2 is a scalar
                    tf = false(size(lhs));
                    for k = 1 : s1
                        tf(k) = lhs(k) == rhs;
                    end
                elseif s1 == 1 && s2 > 1  % s2 is an array or vector, s2 is a scalar
                    tf = false(size(rhs));
                    for k = 1 : s2
                        tf(k) = lhs == rhs(k);
                    end
                else
                    assert(all(size(lhs) == size(rhs)), ...  % verify if they are compatible in size
                        'math:sympoly:DimensionMismatch', ...
                        'Comparison attempted on symbolic polynomial arrays of incompatible size.');

                    tf = false(size(lhs));
                    for k = 1 : s1
                        tf(k) = lhs(k) == rhs(k);
                    end
                end
            else
                error('math:sympoly:InvalidOperation', 'Comparison of symbolic polynomial with type "%s" not supported.', class(rhs));
            end
        end

        function res = add(lhs, rhs)
        % Addition for symbolic polynomials.
        %
        % Input arguments:
        % lhs:
        %    a symbolic polynomial object
        % rhs:
        %    a symbolic polynomial or a numeric array

            s1 = numel(lhs);
            s2 = numel(rhs);
            if isnumeric(rhs)
                if s1 == 1 && s2 == 1  % both are scalars
                    res = lhs;
                    res.ConstantValue = res.ConstantValue + rhs;
                elseif s1 > 1 && s2 == 1  % s1 is an array or vector, s2 is a scalar
                    res = lhs;
                    for k = 1 : numel(res)
                        res(k).ConstantValue = res(k).ConstantValue + rhs;
                    end
                elseif s1 == 1 && s2 > 1  % s2 is an array or vector, s1 is a scalar
                    res = sympoly(zeros(size(rhs)));
                    res(:) = lhs;
                    for k = 1 : numel(res)
                        res(k).ConstantValue = res(k).ConstantValue + rhs(k);
                    end
                else  % s1 > 1 && s2 > 1  % s1 and s2 are both arrays or vectors
                    assert(all(size(lhs) == size(rhs)), ...  % verify if they are compatible in size
                        'math:sympoly:DimensionMismatch', ...
                        'Addition of symbolic polynomial array and numeric array of incompatible size.');

                    res = lhs;
                    for k = 1 : numel(res)
                        res(k).ConstantValue = res(k).ConstantValue + rhs(k);
                    end
                end
            elseif isa(rhs, 'sympoly')
                if s1 == 1 && s2 == 1  % both are scalars
                    [lhs,rhs] = unionvars(lhs,rhs);  % make sure they have compatible variable sets

                    % addition requires appending the arrays, then a consolidation step
                    res = sympoly;
                    res.Variables = lhs.Variables;
                    res.Exponents = [lhs.Exponents;rhs.Exponents];
                    res.Coefficients = [lhs.Coefficients;rhs.Coefficients];
                    res.ConstantValue = lhs.ConstantValue + rhs.ConstantValue;
                    res = clean(res);  % clean up the polynomial
                elseif s1 > 1 && s2 == 1  % s1 is an array or vector, s2 is a scalar
                    res = lhs;
                    for k = 1 : s1
                        res(k) = add(res(k), rhs);
                    end
                elseif s1 == 1 && s2 > 1  % s2 is an array or vector, s1 is a scalar
                    res = rhs;
                    for k = 1 : s2
                        res(k) = add(lhs, res(k));
                    end
                else  % s1 > 1 && s2 > 1  % s1 and s2 are both arrays or vectors
                    assert(all(size(lhs) == size(rhs)), ...  % verify if they are compatible in size
                        'math:sympoly:DimensionMismatch', ...
                        'Addition of symbolic polynomial arrays of incompatible size.');

                    % add elementwise
                    res = lhs;
                    for k = 1 : s1
                        res(k) = add(res(k), rhs(k));
                    end
                end
            end
        end

        function res = multiply(lhs, rhs)
        % Elementwise multiplication for symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial or a numeric array

            s1 = numel(lhs);
            s2 = numel(rhs);
            if isnumeric(rhs)
                if s1 == 1 && s2 == 1  % both are scalars
                    if rhs ~= 0
                        res = lhs;
                        res.Coefficients = res.Coefficients .* rhs;
                        res.ConstantValue = res.ConstantValue .* rhs;
                    else  % multiplication by zero
                        res = sympoly(0);
                    end
                elseif s1 > 1 && s2 == 1  % s1 is an array or vector, s2 is a scalar
                    res = lhs;
                    for k = 1 : numel(res)
                        res(k).Coefficients = res(k).Coefficients .* rhs;
                        res(k).ConstantValue = res(k).ConstantValue .* rhs;
                    end
                elseif s1 == 1 && s2 > 1  % s2 is an array or vector, s1 is a scalar
                    res = sympoly(zeros(size(rhs)));
                    res(:) = lhs;
                    for k = 1 : numel(res)
                        res(k).Coefficients = res(k).Coefficients .* rhs(k);
                        res(k).ConstantValue = res(k).ConstantValue .* rhs(k);
                    end
                else  % s1 > 1 && s2 > 1  % s1 and s2 are both arrays or vectors
                    assert(all(size(lhs) == size(rhs)), ...  % verify if they are compatible in size
                        'math:sympoly:DimensionMismatch', ...
                        'Multiplication of symbolic polynomial array and numeric array of incompatible size.');

                    res = lhs;
                    for k = 1 : numel(res)
                        res(k).Coefficients = res(k).Coefficients .* rhs(k);
                        res(k).ConstantValue = res(k).ConstantValue .* rhs(k);
                    end
                end
            elseif isa(rhs, 'sympoly')
                if s1 == 1 && s2 == 1  % both are scalars
                    [lhs,rhs] = unionvars(lhs,rhs);  % make sure they have compatible variable lists

                    n1 = numel(lhs.Coefficients);
                    n2 = numel(rhs.Coefficients);
                    nv = numel(lhs.Variables);

                    res = sympoly;
                    res.Variables = lhs.Variables;
                    res.Exponents = zeros(n1*n2+n1+n2,nv);
                    res.Coefficients = zeros(n1*n2+n1+n2,1);
                    for i = 1 : n1
                        res.Exponents(1 + (i-1)*n2 : n2 + (i-1)*n2, :) = bsxfun(@plus, rhs.Exponents, lhs.Exponents(i,:));
                        res.Coefficients(1 + (i-1)*n2 : n2 + (i-1)*n2, 1) = rhs.Coefficients * lhs.Coefficients(i,1);
                    end
                    res.Exponents(1 + n1*n2 : n1+n2 + n1*n2, :) = [ lhs.Exponents ; rhs.Exponents ];
                    res.Coefficients(1 + n1*n2 : n1+n2 + n1*n2) = [ lhs.Coefficients * rhs.ConstantValue ; rhs.Coefficients * lhs.ConstantValue ];
                    res.ConstantValue = lhs.ConstantValue * rhs.ConstantValue;
                    res = clean(res);  % clean up the polynomial
                elseif s1 > 1 && s2 == 1  % s1 is an array or vector, s2 is a scalar
                    res = lhs;
                    for k = 1 : s1
                        res(k) = multiply(res(k), rhs);
                    end
                elseif s1 == 1 && s2 > 1  % s2 is an array or vector, s1 is a scalar
                    res = rhs;
                    for k = 1 : s2
                        res(k) = multiply(lhs, res(k));
                    end
                else  % s1 > 1 && s2 > 1  % s1 and s2 are both arrays or vectors
                    assert(all(size(lhs) == size(rhs)), ...  % verify if they are compatible in size
                        'math:sympoly:DimensionMismatch', ...
                        'Multiplication of symbolic polynomial arrays of incompatible size.');

                    % multiply elementwise
                    res = lhs;
                    for k = 1 : s1
                        res(k) = multiply(res(k), rhs(k));
                    end
                end
            end
        end

        function sp = scalardivide(sp1, sp2)
        % Elementwise division for scalar symbolic polynomials.
        %
        % Input arguments:
        % sp1, sp2:
        %    a symbolic polynomial

            if isconstant(sp2)  % e.g. sympoly(2)
                sp = sp1;
                sp.Coefficients = sp.Coefficients ./ sp2.ConstantValue;
                sp.ConstantValue = sp.ConstantValue ./ sp2.ConstantValue;
            elseif ismonomial(sp2)  % e.g. 2*x^4
                % inverse of monomial: 2*x^4 --> 0.5*x^-4
                sp2.Exponents = -sp2.Exponents;
                sp2.Coefficients = 1 ./ sp2.Coefficients;

                % multiply with inverse
                sp = sp1 .* sp2;
            else
                [sp,sprem,remflag] = longdivide(sp1, sp2);
                assert(~remflag, ...
                    'math:sympoly:NonzeroRemainder', ...
                    'Polynomial division of %s with %s resulted in nonzero remainder %s.', char(sp1), char(sp2), char(sprem));
            end
        end

        function [q,r,rflag] = longdivide(lhs, rhs)
        % Polynomial long division.

            if isunivariate(lhs) && isunivariate(rhs)
                assert(all(lhs.Exponents == floor(lhs.Exponents)) && all(rhs.Exponents == floor(rhs.Exponents)), ...
                    'math:sympoly:InvalidOperation', ...
                    'Fractional exponents are not supported.');
                var = univariatesym(lhs);

                % normalize lowest degree to 0
                if isempty(lhs.Exponents)
                    lm = 0;
                else
                    lm = min(lhs.Exponents);
                    if lm > 0 && lhs.ConstantValue ~= 0
                        lm = 0;
                    end
                end
                if isempty(rhs.Exponents)
                    rm = 0;
                else
                    rm = min(rhs.Exponents);
                    if rm > 0 && rhs.ConstantValue ~= 0
                        rm = 0;
                    end
                end
                m = min(lm,rm);

                % convert symbolic polynomial to numeric vector of coefficients
                lhsp = zeros(max(lhs.Exponents)-m+1, 1);  % use column vectors
                lhsp(end) = lhs.ConstantValue;
                lhsp(end-lhs.Exponents+m) = lhs.Coefficients;
                rhsp = zeros(max(rhs.Exponents)-m+1, 1);
                rhsp(end) = rhs.ConstantValue;
                rhsp(end-rhs.Exponents+m) = rhs.Coefficients;

                % perform deconvolution
                [qp,rp] = deconv(lhsp,rhsp);  % returns column vectors

                % create sympoly objects
                q = sympoly(var);  % univariate
                q.Exponents = transpose(numel(qp)-1:-1:0);  % greatest common power m canceled
                q.Coefficients = qp;
                q = clean(q);  % drop powers with zero coefficient and normalize coefficients with all-zero powers
                r = sympoly(var);
                r.Exponents = transpose(numel(rp)-1+m:-1:m);  % reverse normalization by m
                r.Coefficients = rp;
                r = clean(r);

                rflag = numel(rp) ~= 1 || rp ~= 0;
            elseif islinear(sp2)
                [q,r,rflag] = syntheticdivide(lhs, rhs);
            else
                error('math:sympoly:NotSupported', 'Division with nonlinear or polyvariate divisor is not supported.');
            end
        end

        function [q,r,rflag] = syntheticdivide(lhs, rhs) %#ok<STOUT,MANU>
        % Synthetic division with non-degenerate linear univariate term.

            assert(~isconstant(rhs) && ~ismonomial(rhs), ...
                'math:sympoly:InvalidOperation', ...
                'Synthetic division requires a non-degenerate linear term of the form x + c');

            error('math:sympoly:NotImplemented', 'Synthetic division of polyvariate polynomials is not yet implemented.');
        end

        function dpdx = differentiate(sp, n, dvar)
        % Derivative of a scalar symbolic polynomial.

            validateattributes(sp, {'sympoly'}, {'scalar'});
            validateattributes(n, {'numeric'}, {'nonnegative','integer','scalar'});

            if n == 0
                dpdx = sp;  % do nothing
                return;
            elseif n > 1
                % recursive calls for higher-order differentiation
                dpdx = sp;
                for k = 1 : n
                    dpdx = differentiate(dpdx, 1, dvar);
                end
                return;
            end

            indx = findvar(sp, dvar);  % is sp a function of the designated variable?
            if isempty(indx)
                dpdx = sympoly(0);  % sp is not a function of that variable, so the derivative will be zero
            else
                % perform actual differentiation
                dpdx = sp;
                pow = sp.Exponents(:,indx);

                % drop terms where variable has zero power
                dpdx.Exponents(pow==0,:) = [];
                dpdx.Coefficients(pow==0) = [];
                dpdx.ConstantValue = 0;
                pow(pow==0) = [];

                if isempty(pow)  % the derivative is totally zero
                    dpdx = sympoly(0);
                else  % there are some terms that remain
                    dpdx.Exponents(:,indx) = pow-1;
                    dpdx.Coefficients = dpdx.Coefficients.*pow;

                    % clean up the polynomial
                    dpdx = clean(dpdx);  % rows with all-zero exponents become constants with gargbage collection and normalization
                end
            end
        end

        function sp = substitute(sp, old, new)
        % Substitute symbolic term in place of other symbolic term.

            validateattributes(sp, {'sympoly'}, {'scalar'});
            validateattributes(old, {'sympoly'}, {'scalar'});
            validateattributes(new, {'sympoly','numeric'}, {'scalar'});

            assert(ismonomial(old), ...
                'math:sympoly:ArgumentTypeMismatch', ...
                'Substitution expects a univariate monomial to substitute for.');

            % is the symbolic polynomial a function of this variable?
            vindx = findvar(sp, old.Variables);  % index of the variable to substitute for in the expression
            if isempty(vindx)
                return;  % nothing to substitute
            end

            % is "new" a sympoly itself or numeric?
            if isnumeric(new)  % a number, the substitution is easy
                tindx = find(sp.Exponents(:,vindx));  % indices of terms where the variable had nonzero exponent
                pow = sp.Exponents(tindx,vindx);
                sp.Coefficients(tindx) = sp.Coefficients(tindx) ./ old.Coefficients .* new.^(pow ./ old.Exponents);  % compensate with exponent of the substituted variable
                sp.Exponents(:,vindx) = 0;
                sp = clean(sp);  % clean it all up
            elseif ismonomial(new)
                windx = findvar(sp, new.Variables);  % test whether the expression already contains the variable to substitue

                if isempty(windx) || windx ~= vindx  % new variable not in expression
                    sp.Variables(vindx) = new.Variables;  % replace variable
                end

                tindx = find(sp.Exponents(:,vindx));  % indices of terms where the variable to replace had nonzero exponent
                if isempty(tindx)  % a degenerate polynomial, the polynomial is not a function of the variable
                    return;
                end

                pow = sp.Exponents(tindx,vindx);
                sp.Coefficients(tindx) = sp.Coefficients(tindx) ./ old.Coefficients .* new.Coefficients.^(pow ./ old.Exponents);
                sp.Exponents(:,vindx) = sp.Exponents(:,vindx) ./ old.Exponents .* new.Exponents;

                if isempty(windx)
                    % variable to substitute overwrites a previous variable
                    % e.g. y --> z^2 in x^2 + y^3 --> x^2 + z^6
                    sp = sortvars(sp);
                elseif windx ~= vindx
                    % variable to substitute is already in expression
                    % e.g. y --> x^2 in x^2 + y^3 --> x^2 + x^6
                    sp.Exponents(:,windx) = sp.Exponents(:,windx) + sp.Exponents(:,vindx);  % contract exponent matrix
                    sp.Exponents(:,vindx) = [];  % delete overwritten variable (e.g. y), located replacement variable is guaranteed to be in order, no order restoration needed
                    sp.Variables(:,vindx) = [];  % two indices ensure proper structure even for zero variables
                end
            else  % a general symbolic polynomial, hard way
                assert(old.Coefficients == 1, ...
                    'math:sympoly:ArgumentTypeMismatch', ...
                    'Substitution expects a univariate monomial with unit coefficient to substitute for.');

                spsubs = sympoly(0);
                nc = length(sp.Coefficients);
                for i = 1 : nc  % enumerate terms
                    coeff = sp.Coefficients(i);  % extract coefficient from term
                    expon = sp.Exponents(i,:);   % extract exponent of variable to substitute for
                    pow = expon(1,vindx);        % save old value of exponent
                    expon(1,vindx) = 0;          % remove variable to substitute for from the expression

                    % build new term with substituted expression
                    spi = sympoly(0);
                    spi.Coefficients = coeff;
                    spi.Variables = sp.Variables;
                    spi.Exponents = expon;
                    spi = spi .* new.^(pow ./ old.Exponents);  % compensate for original exponent
                    spsubs = spsubs + spi;  % automatically performs garbage collection
                end
                spsubs = spsubs + sp.ConstantValue;
                sp = spsubs;
            end
        end

        function sp = substitutepower(sp, old, new)
        % Substitute exact power of a variable into symbolic polynomial.

            validateattributes(sp, {'sympoly'}, {'scalar'});
            validateattributes(old, {'sympoly'}, {'scalar'});
            validateattributes(new, {'sympoly', 'numeric'}, {'scalar'});

            assert(ismonomial(old), ...
                'math:sympoly:InvalidOperation', ...
                'Substitution expects a univariate monomial to substitute for.');

            % is the symbolic polynomial a function of this variable?
            vindx = findvar(sp, old.Variables);  % index of the variable to substitute for in the expression
            if isempty(vindx)
                return;
            end

            % create a temporary symbolic polynomial in which only those terms with specified power of the variable occur
            tindx = sp.Exponents(:,vindx) == old.Exponents;

            if any(tindx)  % some terms contain the variable raised to the specified power
                temp = sp;
                temp.Exponents(~tindx,vindx) = 0;  % clear those terms that have the variable with a different power
                temp.Coefficients(~tindx) = 0;
                temp = clean(temp);
                temp = substitute(temp, old, new);
                sp.Exponents(tindx,vindx) = 0;  % clear those terms in which the substitutes come from temp
                sp.Coefficients(tindx) = 0;
                sp = sp + temp;
            end
        end

        function polymean = errormean(sp, vars, means, stds)
        % Symbolic mean given normal components.
        %
        % See also: sympoly.errorprop

            polymean = sp;
            nvars = numel(vars);

            % substitute unit normal variables into the polynomial computing the mean
            for i = 1 : nvars
                % substitute x_i = means(i) + stds(i) * u
                tempvarname = ['__', char(vars{i}), '__'];
                if isa(vars{i}, 'symvariable')
                    tempvar = copy(vars{i}, tempvarname);
                else  % variable as string
                    tempvar = tempvarname;
                end
                polymean = subs(polymean, vars{i}, means(i) + stds(i)*sympoly(tempvar));

                % which variable was tempvar in polymean?
                k = findvar(polymean, tempvar);

                % for a unit normal variates, the kth central moment is
                % * zero                    for the odd moments
                % * fact(2*k)/(2^k*fact(k)) for the even moments

                % delete all the terms in polymean with an odd exponent
                oddexp = mod(polymean.Exponents(:,k),2) == 1;
                if any(oddexp)
                    polymean.Exponents(oddexp,:) = [];
                    polymean.Coefficients(oddexp) = [];
                end

                % compute even moments.
                evenexp = polymean.Exponents(:,k) / 2;
                if any(evenexp)
                    varmoment = factorial(2*evenexp)./(2.^evenexp.*factorial(evenexp));
                    polymean.Coefficients = polymean.Coefficients.*varmoment;
                end

                % eliminate temporary variable
                polymean.Exponents(:,k) = 0;

                % perform cleanup
                polymean = clean(polymean);
            end
        end

        function [expr,vars] = symobject(sp)
        % Convert symbolic polynomial scalar to Symbolic Toolbox sym object.
        %
        % See also: sym

            vars = sym(zeros(1,numel(sp.Variables)));
            for k = 1 : numel(sp.Variables)  % create Symbolic Toolbox symbolic variables
                vars(k) = sym(char(sp.Variables(k)));
            end

            expr = sym(sp.ConstantValue);
            for i = 1 : numel(sp.Coefficients)  % iterate over terms
                if sp.Coefficients(i) ~= 0  % omit terms with zero coefficient
                    term = sym(sp.Coefficients(i));
                    for j = 1 : numel(sp.Variables)  % iterate over variables in a term
                        if sp.Exponents(i,j) ~= 0  % omit variables with zero exponent
                            term = term * vars(j)^sp.Exponents(i,j);
                        end
                    end

                    expr = expr + term;
                end
            end
        end

        function str = formatmatrix(sp, fun, colsep, rowsep, linesep, open, close)
        % Format a matrix of polynomials according to the given specifications.
        %
        % Input arguments:
        % fun:
        %    a function to apply to all elements of the array that converts an entry
        %    into a string, e.g. @(elem) char(elem)
        % colsep:
        %    separates columns in a matrix, e.g. ','
        % rowsep:
        %    separates rows in matrix, e.g. ';'
        % open:
        %    starts the matrix expression, e.g. '['
        % close:
        %    ends the matrix expression, e.g. ']'

            validateattributes(fun, {'function_handle'}, {'scalar'});
            validateattributes(colsep, {'char'}, {'nonempty','row'});
            validateattributes(rowsep, {'char'}, {'nonempty','row'});
            validateattributes(linesep, {'char'}, {'nonempty','row'});
            validateattributes(open, {'char'}, {'nonempty','row'});
            validateattributes(close, {'char'}, {'nonempty','row'});

            if isscalar(sp)
                str = fun(sp);
            elseif isvector(sp)
                if size(sp,1) > size(sp,2)  % column vector
                    sep = rowsep;
                else
                    sep = colsep;
                end
                strs = cell(1, numel(sp) + 1);
                k = 1;
                strs{k} = sprintf('%s %s', open, fun(sp(1)));
                for i = 2 : numel(sp)
                    k = k + 1;
                    strs{k} = sprintf('%s %s', sep, fun(sp(i)));
                end
                k = k + 1;
                strs{k} = sprintf(' %s', close);
                str = cell2mat(strs);  % join strings into a single string
            elseif ~isempty(sp) && ndims(sp) <= 2
                arr = cell(size(sp));
                for j = 1 : size(sp,2)
                    for i = 1 : size(sp,1)
                        arr{i,j} = fun(sp(i,j));
                    end
                end
                width = max(cellfun(@length, arr), [], 1);  % find largest column widths, force calculating maximum along rows
                strs = cell(1, numel(sp) + size(sp,1) + 1);  % number of elements + line terminator for each row + end terminator
                k = 1;
                strs{k} = sprintf('%s %*s', open, width(1), arr{1,1});
                for j = 2 : size(sp,2)
                    k = k + 1;
                    strs{k} = sprintf('%s %*s', colsep, width(j), arr{1,j});
                end
                k = k + 1;
                strs{k} = linesep;
                for i = 2 : size(sp,1)
                    k = k + 1;
                    strs{k} = sprintf('%s %*s', rowsep, width(1), arr{i,1});
                    for j = 2 : size(sp,2)
                        k = k + 1;
                        strs{k} = sprintf('%s %*s', colsep, width(j), arr{i,j});
                    end
                    k = k + 1;
                    strs{k} = linesep;
                end
                k = k + 1;
                strs{k} = close;
                str = cell2mat(strs);  % join strings into a single string
            end
        end
    end
    methods (Static, Access = private)
        function sympoly_object = convertscalarsym(sym_object)
        % Create symbolic polynomial based on sym object.
        %
        % See also: sym

            sympoly.symassignincaller(sym_object);    % minimize collision of variable names by invoking a separate function
            sympoly_object = eval(char(sym_object));  % eval uses variables that have been created in this function context
        end

        function symassignincaller(sym_object)
        % Create symbolic polynomial variables in the caller workspace from sym object.
        %
        % See also: sym, symvar

            vars = symvar(sym_object);  % list of symbolic variables in symbolic expression
            for k = 1 : numel(vars)
                var = char(vars(k));  % name of variable as a string
                assignin('caller', var, sympoly(var));  % create symbolic polynomial variable of the same name in the caller workspace
            end
        end
    end
    methods (Access = private)
        function sv = variablename(sp, var)
        % Deduce default variable from context if not explicitly specified.

            if nargin < 2 || isempty(var)   % take default variable
                assert(isunivariate(sp), ...  % only if there is only one variable in the sympoly
                    'math:sympoly:ArgumentCountMismatch', ...
                    'Variable to perform operation with respect to cannot be deduced from the context.');
                sv = univariatesym(sp);
            elseif isa(var, 'sympoly')
                assert(issinglevariable(var), ...
                    'math:sympoly:InvalidOperation', ...
                    'A single-term degree-one variable with unit coefficient is expected.');
                sv = univariatesym(var);
            elseif iscellstr(var) && numel(var) == 1
                sv = var{1};
                if isa(sv, 'symvariable')
                    validateattributes(sv, {'symvariable'}, {'scalar'});
                else
                    validateattributes(sv, {'char'}, {'nonempty','row'});  % check for proper variable name
                end
            else
                sv = var;
                if isa(sv, 'symvariable')
                    validateattributes(sv, {'symvariable'}, {'scalar'});
                else
                    validateattributes(sv, {'char'}, {'nonempty','row'});  % check for proper variable name
                end
            end
        end

        function dim = operatingdimension(sp, dim)
        % Dimension an accumulator operation operates on.

            s = size(sp);
            np = ndims(sp);

            % default for dim is 1, UNLESS sp is a row vector.
            if nargin < 2 || isempty(dim)
                if s(1) == 1 && np == 2  % a row vector
                    dim = 2;
                else  % any other shape array
                    dim = 1;
                end
            else
                validateattributes(dim, {'numeric'}, {'scalar','integer','positive'});
            end
            assert(dim <= np, ...
                'math:sympoly:DimensionMismatch', ...
                'Accumulator would operate on dimension %d but array has only %d dimensions.', dim, np);
        end

        function var = univariatesym(sp)
        % The variable a univariate polynomial is a function of.
        %
        % Output arguments:
        % var:
        %    a variable name as a string or a cell array of variable names

            validateattributes(sp, {'sympoly'}, {'scalar'});
            assert(isunivariate(sp), ...
                'math:sympoly:InvalidOperation', ...
                'Operation supported on univariate polynomials only.');

            if iscell(sp.Variables)
                var = sp.Variables{1};
            else
                var = sp.Variables(1);
            end
        end
    end
end