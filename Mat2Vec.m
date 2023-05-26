function [Img_Vec] = Mat2Vec(Img_Mat, H, W, B)
% Reshape matrix to vector.

Img_Vec = zeros(B, H*W);
for i=1:B
    Img_Vec(i,:)=reshape(Img_Mat(:,:,i)',[1,H*W])';
end

end