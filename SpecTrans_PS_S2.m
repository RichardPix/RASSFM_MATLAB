function Trans_Img = SpecTrans_PS_S2( S2_10m, S2_20m, PS )

[H_10m, W_10m, BandNum_S2_10m] = size(S2_10m);
[H_20m, W_20m, BandNum_S2_20m] = size(S2_20m);
[H_3m, W_3m, BandNum_PS] = size(PS);

BandNum_S2 = BandNum_S2_10m + BandNum_S2_20m; 

PS_10m = imresize(PS, [H_10m W_10m], 'box'); 
M_10m = SpecReg( S2_10m, PS_10m );

PS_20m = imresize(PS, [H_20m W_20m], 'box'); 
M_20m = SpecReg( S2_20m, PS_20m );

M_Hybrid = zeros(BandNum_S2, BandNum_PS);
M_Hybrid([1:3,7], :) = M_10m;
M_Hybrid([4:6,8:10], :) = M_20m;

PS_Vec = Mat2Vec(PS, H_3m, W_3m, BandNum_PS); % Matrix to Vector.
Trans_Vec = M_Hybrid * PS_Vec;

Trans_Img = Vec2Mat(Trans_Vec, H_3m, W_3m, BandNum_S2); % Vector to matrix.

end

