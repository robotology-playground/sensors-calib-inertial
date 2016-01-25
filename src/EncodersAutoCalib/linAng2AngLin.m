function [ out ] = linAng2AngLin( in )
%LINANG2ANGLIN Convert a matrix (or vector) from lin ang to ang lin
    out = zeros(0);
    if( size(in,1) == 6 && size(in,2) == 6 )
        out(1:3,1:3) = in(4:6,4:6);
        out(1:3,4:6) = in(4:6,1:3);
        out(4:6,1:3) = in(1:3,4:6);
        out(4:6,4:6) = in(1:3,1:3);
    end
end
