function Trans_Img = SpecMap( S2, PS )

[h, w, B] = size(S2);
[H, W, b] = size(PS);

% Matrix to Vector.
S2_Vec = Mat2Vec(S2, h, w, B);
% Matrix to Vector.
PS_Vec = Mat2Vec(PS, H, W, b);

% Get the spectral tranformation matrix M.
M = (S2_Vec*PS_Vec') / (PS_Vec*PS_Vec'); 
Trans_Vec = M * PS_Vec;

% Vector to matrix.
Trans_Img = Vec2Mat(Trans_Vec, H, W, B);

end

