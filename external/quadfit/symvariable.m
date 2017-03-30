classdef symvariable
% Symbolic variable in a symbolic expression.
%
% Examples:
%    x = symvariable('x')   constructs a new symbolic variable x
%    p = sympoly(x)         constructs a univariate symbolic polynomial of
%                           the symbolic variable x
%    x == copy(x)           returns true
%
% See also: sympoly, symvard

% Copyright 2009-2011 Levente Hunyadi
    properties (SetAccess = protected)
        Name;
    end
    methods
        function sv = symvariable(arg)
        % Create a new symbolic variable for use in a symbolic polynomial.

            validateattributes(arg, {'symvariable','char'}, {'nonempty'});
            if ischar(arg)
                validateattributes(arg, {'char'}, {'nonempty','row'});
                sv.Name = arg;
            elseif isa(arg, 'symvariable')  % copy constructor
                sv.Name = arg.Name;
            end
        end

        function sv = copy(sv, name)
        % Copy and rename a symbolic variable.
        %
        % Inheritor classes do not need to override this method.

            if nargin > 1
                validateattributes(name, {'char'}, {'nonempty','row'});
                sv.Name = name;
            end
        end

        function tf = eq(lhs, rhs)
        % Test whether two objects refer to the same symbolic variable.
        %
        % Inheritor classes do not need to override this method.

            if isscalar(lhs) && isscalar(rhs)
                tf = scalareq(lhs, rhs);
            elseif isscalar(rhs)
                tf = false(size(lhs));
                for k = 1 : numel(lhs)
                    tf(k) = scalareq(lhs(k), rhs);
                end
            elseif isscalar(lhs)
                tf = false(size(rhs));
                for k = 1 : numel(rhs)
                    tf(k) = scalareq(lhs, rhs(k));
                end
            else
                assert(all(size(lhs) == size(rhs)), ...  % verify if they are compatible in size
                    'math:symvariable:DimensionMismatch', ...
                    'Comparison attempted on symbolic variable arrays of incompatible size.');

                tf = false(size(lhs));
                for k = 1 : numel(lhs)
                    tf(k) = scalareq(lhs(k), rhs(k));
                end
            end
        end

        function tf = ne(lhs, rhs)
        % Test whether two objects refer to different symbolic variables.
        %
        % Inheritor classes do not need to override this method.

            tf = ~eq(lhs, rhs);
        end
        
        function tf = lt(lhs, rhs)
        % Inheritor classes do not need to override this method.

            if isscalar(lhs) && isscalar(rhs)
                tf = scalarlt(lhs, rhs);
            elseif isscalar(rhs)
                tf = false(size(lhs));
                for k = 1 : numel(lhs)
                    tf(k) = scalarlt(lhs(k), rhs);
                end
            elseif isscalar(lhs)
                tf = false(size(rhs));
                for k = 1 : numel(rhs)
                    tf(k) = scalarlt(lhs, rhs(k));
                end
            else
                assert(all(size(lhs) == size(rhs)), ...  % verify if they are compatible in size
                    'math:symvariable:DimensionMismatch', ...
                    'Comparison attempted on symbolic variable arrays of incompatible size.');

                tf = false(size(lhs));
                for k = 1 : numel(lhs)
                    tf(k) = scalarlt(lhs(k), rhs(k));
                end
            end
        end

        function [svsorted,ix] = sort(sv)
        % Sort symbolic variables in an array.

            [~,ix] = sort(names(sv));  % stable sort for variable names
            svsorted = sv(ix);
        end
        
        function str = char(sv)
            str = sv.Name;
        end

        function disp(sv)
            if isempty(sv)
                builtin('disp', sv);
            elseif isscalar(sv)
                disp(char(sv));
            elseif ndims(sv) == 2
                arr = cell(size(sv));
                for j = 1 : size(sv,2)
                    for i = 1 : size(sv,1)
                        arr{i,j} = char(sv(i,j));
                    end
                end
                width = max(cellfun(@length, arr), [], 1);  % find largest column widths, force calculating maximum along rows
                for i = 1 : size(sv,1)
                    fprintf('[');
                    for j = 1 : size(sv,2)
                        fprintf(' %*s ', width(j), arr{i,j});
                    end
                    fprintf(']\n');
                end
            else
                dims = cell(1,2*ndims(sv)-1);
                dims(1:2:end) = arrayfun(@int2str, size(sv), 'UniformOutput', false);
                dims(2:2:end) = {'x'};
                fprintf('[%s %s]\n', cell2mat(dims), class(sv));
            end
        end

        function display(sv)
        % Displays a symbolic variable object.

            name = inputname(1);
            if isempty(name)
                name = 'ans';
            end
            fprintf('%s =\n', name);

            s = size(sv);  % is it a scalar or an array?
            if isempty(sv)
                fprintf('empty %s of size = [%s]\n', class(sv), int2str(s));
            elseif any(s > 1)  % an array or vector
                fprintf('%s array of size = [%s]\n', class(sv), int2str(s));
                if ndims(sv) > 2
                    disp('');
                    sj = [0,ones(1,numel(s)-1)];
                    for j = 1 : numel(sv)
                        % convert linear index to subscript index
                        sj(1) = sj(1)+1;
                        while any(sj > s)
                            k = find(sj > s, 1, 'first');
                            sj(k) = 1;
                            sj(k+1) = sj(k+1)+1;
                        end

                        fprintf('%s array element [%s]\n    %s\n', class(sv), int2str(sj), char(sv(j)));
                    end
                else  % two-dimensional
                    disp(sv);
                end
            elseif isscalar(sv)  % a scalar
                fprintf('%s\n', char(sv));
            end
        end

        function n = names(sv)
        % Variable names for an array of symbolic variables.
        %
        % Output arguments:
        % names:
        %    a cell array of strings (row vectors of type char)

            n = cell(numel(sv), 1);
            for k = 1 : numel(sv)
                n{k} = sv(k).Name;
            end
        end
    end
    methods (Access = protected)
        function tf = scalareq(lhs, rhs)
        % Test whether two scalar objects refer to the same variable.
        %
        % Inheritor classes have to override this method.

            tf = strcmp(lhs.Name, rhs.Name);
        end
        
        function tf = scalarlt(lhs, rhs)
        % Inheritor classes have to override this method.

            tf = ~strcmp(lhs.Name, rhs.Name) && issorted({lhs.Name, rhs.Name});
        end
    end
end