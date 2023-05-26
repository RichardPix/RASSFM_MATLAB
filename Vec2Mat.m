function [Img_Mat]= Vec2Mat(Img_Vec, H, W, B)
% Reshape vector to matrix.

Img_Mat = zeros(H, W, B);
for i=1:B
    Img_Mat(:,:,i)=reshape(Img_Vec(i,:),[W,H])';
end

end
