function pathIdxesOverGrid = getPathOnGrid(~,aGrid)

% Define the sequence depicted below (in zigzags):
%
% --> 1  4  5  8  9 12 13 
%     2  3  6  7 10 11 14 --> ...
%
pathIdxesOverGrid = zeros(size(aGrid));
v = [1 2]';
for iter=1:size(aGrid,2)
    pathIdxesOverGrid(:,iter) = v;
    v = flipud(v+2);
end

end
