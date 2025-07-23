# RASSFM_MATLAB
This is the MATLAB source code package of the Robust and Adaptive Spatial-Spectral image Fusion Model (RASSFM). It aims to blend the four PlanetScope (PS) 3-m bands (Blue, Green, Red, NIR) and the ten Sentinel-2 (S2) 10-m and 20-m bands (Blue, Green, Red, RE1, RE2, RE3, NIR, SWIR1, SWIR2) to generate the synthetic ten 3-m bands. This code package can also be modified for fusing other satellite imaery with similar characteristics.

Version 1.0: May 26, 2023.

Inputs from RASSFM_Path.txt:
===================================================================================================================================================================
(1) fname_PS:  The file name of the input PS image;

(2) fname_S2: The file name of the input S2 image;

(3) fname_fusion: The file name of the fusion result image.

Input data requirements:
===================================================================================================================================================================
(1) the 3m PS bands are stacked in the order of: Blue, Green, Red, NIR;

(2) the 10m S2 bands are stacked in the order of: Blue, Green, Red, NIR;

(3) the 20m S2 bands are stacked in the order of: RE1, RE2, RE3, NNIR, SWIR1, SWIR2;

(4) the surface reflectance value ranges of PS and S2 images are 0 - 10000;

(5) the PS and S2 images should have the same geographic coverage and projection (e.g., UTM); 

(6) the PS and S2 images should be geometrically matched. 

(7) This code package is for spatial-spectral fusion, so the PS and S2 images should be observed on the same or very close date(s).

References:
===================================================================================================================================================================
Yongquan Zhao, Desheng Liu. 2022. A robust and adaptive spatial-spectral fusion model for PlanetScope and Sentinel-2 imagery. GIScience & Remote Sensing, 59(1), 520-546. doi: 10.1080/15481603.2022.2036054

Copyright and License
===================================================================================================================================================================
Copyright (c) 2022–2023 Yongquan Zhao, yqzhao@niglas.ac.cn, Ningjing Institute of Geography and Limnology, Chinese Academy of Sciences (NIGLAS).

This repository is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) license.
