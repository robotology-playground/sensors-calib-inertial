function [ l ] = lengths( varargin )
% Returns the size of each input argument

l = zeros(length(varargin),1);

for iter = 1:length(varargin)
    l(iter) = length(varargin{iter});
end

end
