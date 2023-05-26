function [ PixCent ] = GetCentPix( VecCent, BandNum, PatchSize)
%GetCentPix Summary of this function goes here
%   Get the center pixel of a image patch.
PatchCent = reshape(VecCent, PatchSize,PatchSize,BandNum);

r = (PatchSize-1)/2;
RowCent = r + 1; 
ColCent = r + 1; 
PixCent = PatchCent(RowCent, ColCent,:);

end
