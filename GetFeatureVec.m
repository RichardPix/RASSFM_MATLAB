function [VecCent, VecSimilar, VecSource] = GetFeatureVec(RowCent, ColCent, similar_num, SimilarWin, win_coarse_Sim, win_coarse_S2, win_fine_Sim, PatchSize, WinRadius)
% Extract the center and similar image patches.

r = (PatchSize-1)/2;

% Expand local window for the convenience of extrating image patches.
win_fine_Sim = EdgeMirror(win_fine_Sim, [r, r]);
win_coarse_Sim = EdgeMirror(win_coarse_Sim, [r, r]);
win_coarse_S2 = EdgeMirror(win_coarse_S2, [r, r]);

% Transform pixel coordinates from the non-expanded local window to the expanded local window.
% Center patch.
RowCent = RowCent + r;
ColCent = ColCent + r;
% Similar patches.
[CandRowInd, CandColInd] = find(SimilarWin);
CandRowInd = CandRowInd + r;
CandColInd = CandColInd + r;

[WinRow, WinCol, BandNum] = size(win_fine_Sim);

%% Adjust the image patch size based on the moving window size.
PatchSizeRow = PatchSize;
PatchSizeCol = PatchSize;
if(WinRow < PatchSize)
    PatchSizeRow = WinRow;
end
if(WinCol < PatchSize)
    PatchSizeCol = WinCol;
end

%% Obtain the center image patch.
% Determine the range of the center image patch.
PatchCentRowStart = RowCent - r;
PatchCentRowEnd = RowCent + r;
PatchCentColStart = ColCent - r;
PatchCentColEnd = ColCent + r;
if(PatchCentRowStart < 1) 
    PatchCentRowStart = 1;
    PatchCentRowEnd = PatchCentRowStart + PatchSizeRow - 1;
    if(PatchCentRowEnd > WinRow) 
        PatchCentRowEnd = WinRow;
    end 
end
if(PatchCentRowEnd > WinRow) 
    PatchCentRowEnd = WinRow;
    PatchCentRowStart = PatchCentRowEnd - PatchSize + 1;
    if(PatchCentRowStart < 1) 
        PatchCentRowStart = 1;
    end 
end
if(PatchCentColStart < 1) 
    PatchCentColStart = 1;
    PatchCentColEnd = PatchCentColStart + PatchSize - 1;
    if(PatchCentColEnd > WinCol) 
        PatchCentColEnd = WinCol;
    end 
end
if(PatchCentColEnd > WinCol) 
    PatchCentColEnd = WinCol;
    PatchCentColStart = PatchCentColEnd - PatchSize + 1;
    if(PatchCentColStart < 1) 
        PatchCentColStart = 1;
    end  
end

% High-resolution patch
PatchCent_fine_Sim(:,:,:) = win_fine_Sim(PatchCentRowStart:PatchCentRowEnd, PatchCentColStart:PatchCentColEnd, :);
VecCent_fine_Sim = PatchCent_fine_Sim(:,:); VecCent_fine_Sim = VecCent_fine_Sim(:);

% Low-resolution patch.
PatchCent_coarse_Sim(:,:,:) = win_coarse_Sim(PatchCentRowStart:PatchCentRowEnd, PatchCentColStart:PatchCentColEnd, :);
VecCent_coarse_Sim = PatchCent_coarse_Sim(:,:); VecCent_coarse_Sim = VecCent_coarse_Sim(:);  
PatchCent_S2(:,:,:) = win_coarse_S2(PatchCentRowStart:PatchCentRowEnd, PatchCentColStart:PatchCentColEnd, :);
VecCent_S2 = PatchCent_S2(:,:); VecCent_S2 = VecCent_S2(:); 

D_Cent = 1 + 0; % Prevent the spatial distance of the center patch to be zero.
SD_Cent = 1 + 0;  % Prevent the spectral difference of the center patch to be zero. 
VecCent = log(abs(VecCent_fine_Sim - VecCent_coarse_Sim) + 1) .* log(abs(VecCent_coarse_Sim - VecCent_S2) + 1) .* ...
    repmat(D_Cent,BandNum*PatchSizeRow*PatchSizeCol,1) .* repmat(SD_Cent,BandNum*PatchSizeRow*PatchSizeCol,1);


%% Obtain similar image patches.
Patches_coarse_Sim = zeros(similar_num, PatchSizeRow, PatchSizeCol, BandNum);
Patches_S2 = zeros(similar_num, PatchSizeRow, PatchSizeCol, BandNum);
Patches_fine_Sim = zeros(similar_num, PatchSizeRow, PatchSizeCol, BandNum);
SpaDist = zeros(similar_num,1); % Spatial distance
for i=1:similar_num   
    % Determine the range of the similar image patches.
    PatchRowStart = CandRowInd(i) - r;
    PatchRowEnd = CandRowInd(i) + r;
    PatchColStart = CandColInd(i) - r;
    PatchColEnd = CandColInd(i) + r;
    if(PatchRowStart < 1)
        PatchRowStart = 1;
        PatchRowEnd = PatchRowStart + PatchSize - 1;
        if(PatchRowEnd > WinRow)
            PatchRowEnd = WinRow;
        end 
    end
    if(PatchRowEnd > WinRow)
        PatchRowEnd = WinRow;
        PatchRowStart = PatchRowEnd - PatchSize + 1;
        if(PatchRowStart < 1) 
            PatchRowStart = 1;
        end 
    end
    if(PatchColStart < 1)
        PatchColStart = 1;
        PatchColEnd = PatchColStart + PatchSize - 1;
        if(PatchColEnd > WinCol) 
            PatchColEnd = WinCol;
        end 
    end
    if(PatchColEnd > WinCol)
        PatchColEnd = WinCol;
        PatchColStart = PatchColEnd - PatchSize + 1;
        if(PatchColStart < 1) 
            PatchColStart = 1;
        end 
    end
    
    Patches_coarse_Sim(i,:,:,:) = win_coarse_Sim(PatchRowStart:PatchRowEnd, PatchColStart:PatchColEnd, :);
    Patches_S2(i,:,:,:) = win_coarse_S2(PatchRowStart:PatchRowEnd, PatchColStart:PatchColEnd, :);
    Patches_fine_Sim(i,:,:,:) = win_fine_Sim(PatchRowStart:PatchRowEnd, PatchColStart:PatchColEnd, :);   
   
    SpaDist(i,1) = 1 + ( ( (double(CandRowInd(i))-double(RowCent))^2 + (double(CandColInd(i))-double(ColCent))^2 )^0.5 ) ./ WinRadius;
end

Vec_coarse_Sim = Patches_coarse_Sim(:,:,:); Vec_coarse_Sim = Vec_coarse_Sim(:,:); Vec_coarse_Sim = Vec_coarse_Sim'; 
Vec_S2 = Patches_S2(:,:,:); Vec_S2 = Vec_S2(:,:); Vec_S2 = Vec_S2';
Vec_fine_Sim = Patches_fine_Sim(:,:,:); Vec_fine_Sim = Vec_fine_Sim(:,:); Vec_fine_Sim = Vec_fine_Sim';

VecSource = Vec_fine_Sim + Vec_S2 - Vec_coarse_Sim; 

Q = log(abs(Vec_fine_Sim - Vec_coarse_Sim) + 1);
F = log(abs(Vec_coarse_Sim - Vec_S2) + 1);
D = repmat(SpaDist',BandNum*PatchSizeRow*PatchSizeCol,1);
SD = log(abs(Vec_fine_Sim - repmat(VecCent_fine_Sim,1,similar_num)) + 1) + 1;

VecSimilar = Q .* F .* D .* SD;
end