classdef (InferiorClasses = {?symvariable}) symvard < symvariable
% Symbolic variable in a symbolic expression with time dynamics.
%
% See also: symvariable

% Copyright 2009-2011 Levente Hunyadi
    properties (SetAccess = protected)
        Shift = 0;
    end
    methods
        function sv = symvard(arg, shift)
            error(nargchk(1, 2, nargin));

            sv@symvariable(arg);

            if nargin > 1
                validateattributes(shift, {'numeric'}, {'scalar','integer'});
                sv.Shift = shift;
            end
        end

        function str = char(sv)
            if sv.Shift ~= 0
                str = sprintf('%s(k%+d)', sv.Name, sv.Shift);
            else
                str = sprintf('%s(k)', sv.Name);
            end
        end

        function [svsorted,ix] = sort(sv)
        % Sort dynamic symbolic variables in an array.
            
            % stable sort for shifts
            [~,ixs] = sort(shifts(sv), 'descend');
            svs = sv(ixs);

            % stable sort for variable names
            [~,ixn] = sort(names(svs));

            % combine results from two sort operations
            ix = ixs(ixn);
            svsorted = sv(ix);
        end

        function s = shifts(sv)
        % Variable time shifts for an array of symbolic variables.
        %
        % Output arguments:
        % shifts:
        %    an array of integers

            s = zeros(numel(sv), 1);
            for k = 1 : numel(sv)
                s(k) = sv(k).Shift;
            end
        end
    end
    methods (Access = protected)
        function tf = scalareq(lhs, rhs)
            if isa(lhs, 'symvard') && isa(rhs, 'symvard')
                tf = scalareq@symvariable(lhs, rhs) && lhs.Shift == rhs.Shift;
            elseif isa(lhs, 'symvard')
                tf = scalareq@symvariable(lhs, rhs) && lhs.Shift == 0;
            elseif isa(rhs, 'symvard')
                tf = scalareq@symvariable(lhs, rhs) && rhs.Shift == 0;
            end
        end
        
        function tf = scalarlt(lhs, rhs)
            if scalarlt@symvariable(lhs, rhs)
                tf = true;
            elseif scalarlt@symvariable(rhs, lhs)
                tf = false;
            elseif isa(lhs, 'symvard') && isa(rhs, 'symvard')
                tf = lhs.Shift < rhs.Shift;
            elseif isa(lhs, 'symvard')
                tf = lhs.Shift < 0;
            elseif isa(rhs, 'symvard')
                tf = 0 < rhs.Shift;
            end
        end
    end
end