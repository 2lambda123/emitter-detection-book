function fig = ex7_3(fig_in)
% fig=ex7_3(fig_in)
%
% Executes Example 7.3; if fig_in is provided then it adds the curve to the
% existing plot, otherwise a new figure is generated.
%
% INPUTS
%   fig_in      figure handle to pre-existing figure, on which new data
%               will be plotted
%
% OUTPUTS
%   fig         figure handle to generated graphic
%
% Nicholas O'Donoughue
% 1 July 2019

if nargin<1 || isempty(fig_in)
    fig = figure;
end

% Parameter Definition
Pt = 35e-3; % W
Gt = 34; % dBi
B_s = 31.3e6; % Hz -- unused
f0 = 35e9; % Hz
lambda = utils.constants.c/f0; % m
Lt = 0; % dB
ht = 500; % m -- unused
Lr = 2; % dB
F_n = 4; % dB
B_n = 40e6; % Hz
T_s = 10e-6; % s
hr = 500; % m

% Angle of arrival
th_true = 10;
psi_true = th_true*pi/180;

% Compute the SNR, as a function of range
R = [1e3:1e3:10e3, 20e3:10e3:100e3];
S = (10*log10(Pt) + Gt - Lt) + 20*log10(lambda./(4*pi*R)) - Lr;
N = 10*log10(utils.constants.boltzmann*utils.constants.T0*B_n)+F_n;
snr_db = S-N;

% Compute the number of time samples available
M = 1 + floor(T_s*B_n);

% Doppler Model
ts = 1/(2*f0);
R_dop = lambda/2;
fr = 1/T_s;
crlb_psi_dop = aoa.doppler_crlb(snr_db,M,1,ts,f0,R_dop,fr,psi_true);
rmse_th_dop = (180/pi)*sqrt(crlb_psi_dop);

% Add to plot
hold on;
loglog(R/1e3,rmse_th_dop,'-v','DisplayName','Doppler');
