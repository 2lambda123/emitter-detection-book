function [fw,b1,b2,b3,b4,b5,b6] = makeSpectroscopicTableWater()
% [fw,b1,b2,b3,b4,b5,b6] = makeSpectroscopicTableWater()
%
% Returns the spectroscopic table for water, according to ITU-R P.676-11
% "Attenuation by atmospheric gases (09/2016)"
%
% INPUTS:
%   <none>
%
% OUTPUTS:
%   Variables b1, b2, b3, b4, b5, and b6, each represented
%   as a vector indexed by frequency (fw), in MHz, used by equations (5-7)
%   of ITU-R P.676
%
% 1 July 2019
% Nicholas O'Donoughue

refMat = [22.23508,0.1079,2.144,26.38,0.76,5.087,1;
67.80396,0.0011,8.732,28.58,0.69,4.93,0.82;
119.99594,0.0007,8.353,29.48,0.7,4.78,0.79;
183.310087,2.273,0.668,29.06,0.77,5.022,0.85;
321.22563,0.047,6.179,24.04,0.67,4.398,0.54;
325.152888,1.514,1.541,28.23,0.64,4.893,0.74;
336.227764,0.001,9.825,26.93,0.69,4.74,0.61;
380.197353,11.67,1.048,28.11,0.54,5.063,0.89;
390.134508,0.0045,7.347,21.52,0.63,4.81,0.55;
437.346667,0.0632,5.048,18.45,0.6,4.23,0.48;
439.150807,0.9098,3.595,20.07,0.63,4.483,0.52;
443.018343,0.192,5.048,15.55,0.6,5.083,0.5;
448.001085,10.41,1.405,25.64,0.66,5.028,0.67;
470.888999,0.3254,3.597,21.34,0.66,4.506,0.65;
474.689092,1.26,2.379,23.2,0.65,4.804,0.64;
488.490108,0.2529,2.852,25.86,0.69,5.201,0.72;
503.568532,0.0372,6.731,16.12,0.61,3.98,0.43;
504.482692,0.0124,6.731,16.12,0.61,4.01,0.45;
547.67644,0.9785,0.158,26,0.7,4.5,1;
552.02096,0.184,0.158,26,0.7,4.5,1;
556.935985,497,0.159,30.86,0.69,4.552,1;
620.700807,5.015,2.391,24.38,0.71,4.856,0.68;
645.766085,0.0067,8.633,18,0.6,4,0.5;
658.00528,0.2732,7.816,32.1,0.69,4.14,1;
752.033113,243.4,0.396,30.86,0.68,4.352,0.84;
841.051732,0.0134,8.177,15.9,0.33,5.76,0.45;
859.965698,0.1325,8.055,30.6,0.68,4.09,0.84;
899.303175,0.0547,7.914,29.85,0.68,4.53,0.9;
902.611085,0.0386,8.429,28.65,0.7,5.1,0.95;
906.205957,0.1836,5.11,24.08,0.7,4.7,0.53;
916.171582,8.4,1.441,26.73,0.7,5.15,0.78;
923.112692,0.0079,10.293,29,0.7,5,0.8;
970.315022,9.009,1.919,25.5,0.64,4.94,0.67;
987.926764,134.6,0.257,29.85,0.68,4.55,0.9;
1780,17506,0.952,196.3,2,24.15,5];


fw = refMat(:,1);
b1 = refMat(:,2);
b2 = refMat(:,3);
b3 = refMat(:,4);
b4 = refMat(:,5);
b5 = refMat(:,6);
b6 = refMat(:,7);