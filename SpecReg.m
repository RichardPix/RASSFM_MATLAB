function [ M ] = SpecReg( S2, PS )
[h, w, B] = size(S2);
[H, W, b] = size(PS);

% Matrix to Vector.
S2_Vec = Mat2Vec(S2, h, w, B);
PS_Vec = Mat2Vec(PS, H, W, b);

% Get the spectral transformation matrix.
M = (S2_Vec*PS_Vec') / (PS_Vec*PS_Vec'); 

clear S2_Vec PS_Vec;

end

