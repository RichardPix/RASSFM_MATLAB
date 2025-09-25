%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Source code of the Robust and Adaptive Spatial-Spectral image Fusion Model (RASSFM) - Yongquan Zhao, The Ohio State University, Columbus.
% Code summary: this code package is for blending the four PlanetScope (PS) 3-m bands (Blue, Green, Red, NIR)
% and the ten Sentinel-2 (S2) 10-m&20-m bands (Blue, Green, Red, RE1, RE2, RE3, NIR, NNIR, SWIR1, SWIR2) to generate the synthetic ten 3-m bands.
% 
% Version 1.0: April 22, 2023.
% 
% Reference for version 1.0: Yongquan Zhao, Desheng Liu. 2022. A robust and adaptive spatial-spectral fusion model 
% for PlanetScope and Sentinel-2 imagery. GIScience & Remote Sensing, 59(1), 520-546.
% 
% 
% Inputs from RASSFM_Path.txt:
% (1) fname_PS:  The file name of the input PS image;
% (2) fname_S2_10m: The file name of the input S2 10-m bands (Blue, Green, Red, NIR);
% (3) fname_S2_20m: The file name of the input S2 20-m bands (RE1, RE2, RE3, NNIR, SWIR1, SWIR2);
% (4) fname_fusion: The file name of the fusion result image.
% 
% Input data requirements:
% (1) the 3-m PS bands are stacked in the order of: Blue, Green, Red, NIR;
% (2) the 10-m S2 bands are stacked in the order of: Blue, Green, Red, NIR;
% (3) the 20-m S2 bands are stacked in the order of: RE1, RE2, RE3, NNIR, SWIR1, SWIR2;
% (4) the surface reflectance value ranges of PS and S2 images are 0 - 10000;
% (5) the PS and S2 images should have the same geographic coverage and projection (e.g., UTM); 
% (6) the PS and S2 images should be geometrically matched. 
% (7) This code package is for spatial-spectral fusion, so the PS and S2 images
%     should be acquired on the same or very close date(s).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

%%%%%%%%%%%%%%%%%%%%% Load your PS and S2 data here.  %%%%%%%%%%%%%%%%%%%%%
% 3m PS image path.
[fname_PS ] = textread('RASSFM_Path.txt', '%s', 1); % read one line. 
fname_PS = char(fname_PS); % cell to char.

% 10m S2 image path.
[fname_S2_10m ] = textread('RASSFM_Path.txt', '%s', 1, 'headerlines',1); % read one line and skip one line.
fname_S2_10m = char(fname_S2_10m); % cell to char.

% 20m S2 image path.
[fname_S2_20m ] = textread('RASSFM_Path.txt', '%s', 1, 'headerlines',2); % read one line and skip two lines.
fname_S2_20m = char(fname_S2_20m); % cell to char.

% Fused image path.
[fname_fusion ] = textread('RASSFM_Path.txt', '%s', 1, 'headerlines',3); % read one line and skip three lines.
fname_fusion = char(fname_fusion); % cell to char.

% Check to make sure we've found the input images and specified the output image.
if strcmp(fname_PS, '')
    error('Could not find the PlanetScope image. \n');
end
if strcmp(fname_S2_10m, '')
    error('Could not find the 10m Sentinel-2 bands. \n');
end
if strcmp(fname_S2_20m, '')
    error('Could not find the 20m Sentinel-2 bands. \n');
end
if strcmp(fname_fusion, '')
    error('Please specify the output image name.\n');
end

% Read images.
[Img_PS, W_3m, H_3m, BandNum_PS, ~, ~]=freadenvi(fname_PS);
[Img_S2_10m, W_S2_10m, H_S2_10m, BandNum_S2_10m, ~, ~]=freadenvi(fname_S2_10m);
[Img_S2_20m, W_S2_20m, H_S2_20m, BandNum_S2_20m, ~, ~]=freadenvi(fname_S2_20m);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%% Set up information for the fusion result. %%%%%%%%%%%%%%%%
[filepath_PS, name_PS, ~] = fileparts(fname_PS);
info_PS = read_envihdr(strcat(filepath_PS, '\', name_PS, '.hdr'));

info = info_PS;
BandNum_S2 = BandNum_S2_10m + BandNum_S2_20m; 
info.bands = BandNum_S2; 
FusionBandName = {'Blue', 'Green', 'Red', 'RE1', 'RE2', 'RE3', 'NIR', 'NNIR', 'SWIR1', 'SWIR2'};

fillV = 0.00000000e+000; % Fill value for outliers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Fusion parametrization and preparation.
gap = 6; % The spatial resolution gap between 3m PS and 20m S2 bands.
WinRadius = 5; % Radius of the moving window for similar neighbor searching.
NumPatch = 25; % Number of similar patches.

% Get the image sizes of 10m and 20m S2 bands.
H_10m = H_3m*3/10; W_10m = W_3m*3/10;
H_20m = H_3m*3/20; W_20m = W_3m*3/20;

% Up-resampling S2 from 10m/20m to 3m grids.
Img_S2 = zeros(H_3m, W_3m, BandNum_S2);
Img_S2(:,:,[1:3,7]) = imresize(Img_S2_10m, [H_3m W_3m], 'bicubic'); 
Img_S2(:,:,[4:6,8:10]) = imresize(Img_S2_20m, [H_3m W_3m], 'bicubic'); 
clear Img_S2_10m Img_S2_20m

fprintf('Fusion started. \n');

%% Spectral mapping and spectral correlation.
%%%%%% Spectral mapping between PS and S2.
% Spectral transformation with 10m and 20m PS for the four 10m and six 20m S2 bands, respectively.
% Img_PS_10m = imresize(Img_PS, [H_10m W_10m], 'box'); 
% Img_PS_10T3m = imresize(Img_PS_10m, [H_3m W_3m], 'bicubic');
% Img_PS_20m = imresize(Img_PS, [H_20m W_20m], 'box'); 
% Img_PS_20T3m = imresize(Img_PS_20m, [H_3m W_3m], 'bicubic');
% Sim_3m_Map = zeros(H_3m, W_3m, BandNum_S2);
% Sim_3m_Map(:,:,[1:3,7]) = SpecMap( Img_S2(:,:,[1:3,7]), Img_PS_10T3m ); 
% Sim_3m_Map(:,:,[4:6,8:10]) = SpecMap( Img_S2(:,:,[4:6,8:10]), Img_PS_20T3m ); 
% Spectral transformation with 3m PS.
Sim_3m_Map = SpecMap( Img_S2, Img_PS ); 
fprintf('Spectral mapping completed. \n');

%%%%%% Spectral correlation between PS and S2.
Sim_3m_Corr = SpecCorr(Img_S2(:,:,[4:6,8]), Img_PS, gap); % Only for for RE1&2&3 and NNIR bands.
fprintf('Spectral correlation completed. \n');

%%%%%% "Band combination": combine "Spectral mapping" and "Spectral correlation".
Sim_3m_Combine = BandCombine(Sim_3m_Map(:,:,[4:6,8]), Sim_3m_Corr, Img_S2(:,:,[4:6,8]), gap); % Only for RE1&2&3 and NNIR bands.
Sim_3m = zeros(size(Sim_3m_Map));
Sim_3m(:,:,[1:3,7,9:10]) = Sim_3m_Map(:,:,[1:3,7,9:10]);
Sim_3m(:,:,[4:6,8]) = Sim_3m_Combine;
fprintf('Band combination completed. \n');

clear Sim_3m_Map Sim_3m_Corr Sim_3m_Combine

%% Blending PS and S2.
% Resampling the 3-m similated image for fusion.
Sim_10m = imresize(Sim_3m(:,:,[1:3,7]), [H_10m W_10m], 'box');
Sim_20m = imresize(Sim_3m(:,:,[4:6,8:10]), [H_20m W_20m], 'box');
Sim_UpRsp = zeros(H_3m, W_3m, BandNum_S2);
Sim_UpRsp(:,:,[1:3,7]) = imresize(Sim_10m, [H_3m W_3m], 'bicubic');
Sim_UpRsp(:,:,[4:6,8:10]) = imresize(Sim_20m, [H_3m W_3m], 'bicubic');

% Band-by-band fusion.
FusionImg = zeros(H_3m,W_3m,BandNum_S2);
fprintf('Spatial-spectral fusion running... \n');
for i=1:BandNum_S2
    FusionImg(:,:,i) = SSF_PS_S2( Sim_UpRsp(:,:,i), Img_S2(:,:,i), Sim_3m(:,:,i), WinRadius, NumPatch, 'bicubic' );
end
fprintf('Spatial-spectral fusion completed. \n');

% Write fused image.
rs_imwrite_bands(single(FusionImg), fname_fusion, info, FusionBandName, fillV); % Save results as single to save storage.
fprintf('Fusion result saved. Done! \n');

