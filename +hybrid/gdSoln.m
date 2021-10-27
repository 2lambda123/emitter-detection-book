function [x,x_full] = gdSoln(x_aoa, x_tdoa, x_fdoa, v_fdoa, z,C,x_init,alpha,beta,epsilon,max_num_iterations,force_full_calc,plot_progress,tdoa_ref_idx,fdoa_ref_idx)
% [x,x_full] = gdSoln(x_aoa, x_tdoa, x_fdoa, v_fdoa, z,C,x_init,alpha,...
%            beta,epsilon,max_num_iterations,force_full_calc,plot_progress)
%
% Computes the gradient descent solution for hybrid AOA, TDOA, and
% FDOA processing.
%
% Inputs:   
%   x_aoa               AOA sensor positions
%   x_tdoa              TDOA sensor positions
%   x_fdoa              FDOA sensor positions
%   v_fdoa              FDOA sensor velocities
%   z                   Measurement vector
%   C                   Combined error covariance matrix
%   x_init              Initial estimate of source position [m]
%   alpha               Backtracking line search parameter
%   beta                Backtracking line search parameter
%   epsilon             Desired position error tolerance (stopping 
%                       condition)
%   max_num_iterations  Maximum number of iterations to perform
%   force_full_calc     Boolean flag to force all iterations (up to
%                       max_num_iterations) to be computed, regardless
%                       of convergence (DEFAULT = False)
%   plot_progress       Boolean flag dictacting whether to plot
%                       intermediate solutions as they are derived 
%                       (DEFAULT = False).
%   tdoa_ref_idx    Scalar index of reference sensor, or nDim x nPair
%                   matrix of sensor pairings for TDOA
%   fdoa_ref_idx    Scalar index of reference sensor, or nDim x nPair
%                   matrix of sensor pairings for FDOA
% Outputs:
%   x               Estimated source position
%   x_full          Iteration-by-iteration estimated source positions
%
% Nicholas O'Donoughue
% 1 July 2019

% Parse inputs
if nargin < 14 || ~exist('tdoa_ref_idx','var')
    tdoa_ref_idx = [];
end

if nargin < 15 || ~exist('fdoa_ref_idx','var')
    fdoa_ref_idx = [];
end

y = @(x) z - hybrid.measurement(x_aoa, x_tdoa, x_fdoa, v_fdoa, x, tdoa_ref_idx, fdoa_ref_idx);
J = @(x) hybrid.jacobian(x_aoa, x_tdoa, x_fdoa, v_fdoa, x, tdoa_ref_idx, fdoa_ref_idx);

% Resample the covariance matrix
n_aoa = size(x_aoa,2);
n_tdoa = size(x_tdoa,2);
n_fdoa = size(x_fdoa,2);

% Parse the TDOA and FDOA reference indices together
[tdoa_test_idx_vec, tdoa_ref_idx_vec] = utils.parseReferenceSensor(tdoa_ref_idx,n_tdoa);
[fdoa_test_idx_vec, fdoa_ref_idx_vec] = utils.parseReferenceSensor(fdoa_ref_idx,n_fdoa);
test_idx_vec = cat(2,tdoa_test_idx_vec, n_tdoa + fdoa_test_idx_vec);
ref_idx_vec = cat(2,tdoa_ref_idx_vec, n_tdoa + fdoa_ref_idx_vec);

% For now, we assume the AOA is independent of TDOA/FDOA
C_aoa = C(1:n_aoa, 1:n_aoa);
C_tfdoa = C(n_aoa+1:end, n_aoa+1:end);
C_tilde = blkdiag(C_aoa, utils.resampleCovMtx(C_tfdoa, test_idx_vec, ref_idx_vec));

[x,x_full] = utils.gdSoln(y,J,C_tilde,x_init,alpha,beta,epsilon,max_num_iterations,force_full_calc,plot_progress);
