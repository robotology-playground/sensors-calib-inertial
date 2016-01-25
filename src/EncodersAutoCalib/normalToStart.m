function [ adjointStart ] = normalToStart( adjoint )
    adjointStart = inv(adjoint)';
end

