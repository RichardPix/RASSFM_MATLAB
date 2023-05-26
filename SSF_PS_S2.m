function [ FusionImg ] = SSF_PS_S2( Sim_LR, S2, Sim_HR, WinRadius, NumPatch, RspMethod )
%SSF_PS_S2 Summary of this function goes here
%   Blend PS and S2 images based on the similar patches and their weights.

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter setting %%%%%%%%%%%%%%%%%%%%%%%%%%%%
PatchSize = 3; % Image patch size.
r = (PatchSize-1)/2; % Radius of the image patch.
tol = 1e-4; % The regularlizer in case the constrained reression is ill conditioned.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[H, W, ~] = size(Sim_HR);
[m, n, B] = size(Sim_LR);

if H == m && W == n
    Sim_LR_UpRsp = Sim_LR;
    S2_UpRsp = S2;
else
    Sim_LR_UpRsp = imresize(Sim_LR,[H W], RspMethod);
    S2_UpRsp = imresize(S2,[H W], RspMethod);
end

% Adaptive h for non-local searching.
for k = 1:B
    h(k) = std2(S2_UpRsp(:,:,k) - Sim_LR_UpRsp(:,:,k))^2;
end

FusionImg_Init = Sim_HR + (S2_UpRsp - Sim_LR_UpRsp); % Initial prediction.
FusionImg = zeros(H, W, B);

Sim_LR_UpRsp = EdgeMirror(Sim_LR_UpRsp, [WinRadius, WinRadius]);
S2_UpRsp = EdgeMirror(S2_UpRsp, [WinRadius, WinRadius]);
Sim_HR = EdgeMirror(Sim_HR, [WinRadius, WinRadius]);

%% Blending S2 and PS.
for i = 1+WinRadius : H+WinRadius
    for j = 1+WinRadius : W+WinRadius
        % Get the local window range.
        i_start = i-WinRadius;
        i_end = i+WinRadius;
        j_start = j-WinRadius;
        j_end = j+WinRadius;
        
        % Target patch location (center of the moving window).
        cent_i = WinRadius+1;
        cent_j = WinRadius+1;
        
        % Get the data within the moving window.
        win_fine_Sim = Sim_HR(i_start:i_end,j_start:j_end,:);
        win_coarse_Sim = Sim_LR_UpRsp(i_start:i_end,j_start:j_end,:);
        win_coarse_S2 = S2_UpRsp(i_start:i_end,j_start:j_end,:);
        
        % Similar neighbor searching.
        PatchCent_Sim(:,:,:) = win_fine_Sim(cent_i - r:cent_i + r, cent_j - r:cent_j + r, :); % Obtain the center patch.
        [SimilarPatches] = FindSimilarPatch(PatchCent_Sim, win_fine_Sim, NumPatch, h', r, PatchSize); % Obtain similar patches' locations.
        [similar_num,~] = size(SimilarPatches); % The number of similar patches.
        % Transform pixel coordinates to local window indices.
        SimilarWin = zeros((i_end-i_start+1),(j_end-j_start+1));
        Ind = (SimilarPatches(:,2)-1)*(2*WinRadius+1) + SimilarPatches(:,1); 
        SimilarWin(Ind) = 1;
        
        if similar_num ~= 0
            % Constrained regression based on the four weight factors:
            % 1) similar neighbors with higher homogeneity (Q) should have larger weights,
            % 2) similar neighbors with smaller cross-sensor spectral differences (F) should have larger weights,
            % 3) similar neighbors with smaller spatial distances to the central patches (D) should have larger weights,
            % 4) similar neighbors with smaller spectral differences to the central patches (SD).
            [VecCent, VecSimilar, VecSource] = GetFeatureVec(cent_i, cent_j, similar_num, SimilarWin, win_coarse_Sim, win_coarse_S2, win_fine_Sim, PatchSize, WinRadius);
            
            % Constrained linear weight calculation.
            [VecPred] = CalWeight(VecCent, VecSimilar, VecSource, tol, similar_num);
            
            % Extract center pixel.
            PixCent_Pred = GetCentPix( VecPred, B, PatchSize);
        else
            % If no similar patches are found, using the initial result.
            PixCent_Pred = FusionImg_Init(i-WinRadius, j-WinRadius, :); 
        end
        
        FusionImg(i-WinRadius, j-WinRadius, :) = PixCent_Pred;
    end
end

end