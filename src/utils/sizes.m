function [ s ] = sizes( varargin )
% Returns the size of each input argument

s = cell(length(varargin),1);

for iter = 1:length(varargin)
    s{iter} = size(varargin{iter});
end

end
