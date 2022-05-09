function Correlated_3m = SpecCorr(S2_20mTo3m, PS_3m, gap)

[~, ~, B] = size(S2_20mTo3m);
[H, W, b] = size(PS_3m);
h = H/gap; 
w = W/gap;

PS_20mTo3m = imresize(imresize(PS_3m, [h w], 'box'), [H W], 'bilinear');
CC = zeros(1,b);
Correlated_3m = zeros(H, W, B);
for i = 1 : B 
    for j = 1:b
        cc = corrcoef( S2_20mTo3m(:,:,i), PS_20mTo3m(:,:,j));
        CC(j) = cc(1,2);
    end
    
    [~, id_maxR] = max(CC);
    
    Correlated_3m(:,:,i) = PS_3m(:,:,id_maxR);
end

end