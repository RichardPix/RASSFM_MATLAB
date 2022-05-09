function [SimilarPatches] = FindSimilarPatch(PatchCent, Win, NumPatch, h, r, PatchSize)

[H,W,BandNum] = size(Win);
kernel = fspecial('gaussian', PatchSize, 0.8);
kernel = repmat(kernel,[1 1 BandNum]);

Win_Ext = EdgeMirror(Win, [r, r]);

ind = 1;

WinSize = H*W;
patches = zeros(WinSize,2);
similarity = zeros(WinSize,1);

%% Non-local searching similar patches.
for i = 1+r:1:H+r 
    for j = 1+r:1:W+r 
        Patch = Win_Ext(i-r:i+r,j-r:j+r,:);
        
        difsum = sum(sum(kernel.*(PatchCent-Patch).*(PatchCent-Patch), 1), 2);
        normdifsum = sum(difsum(:) ./ h);
        normdifsum = min(normdifsum, 500);
        
        similarity(ind,:) = exp(-normdifsum); 
        patches(ind,:) = [i-r, j-r]; % Get a similar pixel's coordinates in a non-expanded local window.
        
        ind = ind+1;
    end
end

[~,index] = sort(similarity,1,'descend');
SimilarPatches = patches(index(1: NumPatch),:);% Get the similar patches' coordinates.

end
