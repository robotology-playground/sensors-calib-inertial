function [ a ] = initColumnPermutation( a )
%INITCOLUMNPERMUTATION Summary of this function goes here
%   Detailed explanation goes here
NB = a.IDmodel.n;

%% Compute indeces for accessing columns Dx and Dy from D
id = zeros(6*NB,1);
for i = 1:NB
   id(       (i-1)*4+1 :        4*i, 1) = [6 6 6 a.IDmodel.jn(i)]';
   id(4*NB + (i-1)*2+1 : 4*NB + 2*i, 1) = [6 a.IDmodel.jn(i)]';
end

d_sm = submatrix(id, 1, zeros(26*NB,1));

d_ind = zeros(6*NB,1);
for i = 1 : NB
   d_ind((i-1)*6+1:(i-1)*6+4, 1) =        (i-1)*4+1:       i*4;
   d_ind((i-1)*6+5:(i-1)*6+6, 1) = 4*NB + (i-1)*2+1:4*NB + i*2;
end

[a.id, ~] = indeces(d_sm, d_ind,1);

%% Compute indeces for accessing rows a, fB, tau and f from D
iD = zeros(4*NB,1);
for i = 1:NB
   iD(       (i-1)*4+1 :        4*i, 1) = [6 6 6 a.IDmodel.jn(i)]';
end

D_sm = submatrix(iD, 1, zeros(19*NB,1));

% row-indeces for the components ai
a.ia   = indeces(D_sm, 1 : 4 : 4*NB,1);
% row-indeces for the components fBi
a.ifB  = indeces(D_sm, 2 : 4 : 4*NB,1);
% row-indeces for the components taui
a.iF   = indeces(D_sm, 3 : 4 : 4*NB,1);
% row-indeces for the components fi
a.itau = indeces(D_sm, 4 : 4 : 4*NB,1);

%% Compute indeces for accessing columns a, fB, tau and f from D
jD = zeros(6*NB,1);
for i = 1:NB
   jD(       (i-1)*4+1 :        4*i, 1) = [6 6 6 a.IDmodel.jn(i)]';
   jD(4*NB + (i-1)*2+1 : 4*NB + 2*i, 1) = [6 a.IDmodel.jn(i)]';
end

D_sm = submatrix(jD, 1, zeros(26*NB,1));

% col-indeces for the components ai
a.ja   = indeces(D_sm, 1 : 4 : 4*NB,1);
% col-indeces for the components fBi
a.jfB  = indeces(D_sm, 2 : 4 : 4*NB,1);
% col-indeces for the components fi
a.jF   = indeces(D_sm, 3 : 4 : 4*NB,1);
% col-indeces for the components taui
a.jtau = indeces(D_sm, 4 : 4 : 4*NB,1);
% col-indeces for the components fxi
a.jfx  = indeces(D_sm, (1 : 2 : 2*NB) + 4*NB,1) ;
% col-indeces for the components d2qi
a.jd2q = indeces(D_sm, (2 : 2 : 2*NB) + 4*NB,1);



