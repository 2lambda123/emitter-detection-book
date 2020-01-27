function crlb = computeCRLB(x_tdoa,xs,C,ref_idx)
% crlb = computeCRLB(x_tdoa,xs,C,ref_idx)
%
% Computes the CRLB on position accuracy for source at location xs and
% sensors at locations in x1 (Ndim x N).  Ctdoa is an Nx1 vector of TOA
% variances at each of the N sensors.
%
% Inputs:
%   x_tdoa      (Ndim x N) array of TDOA sensor positions
%   xs          (Ndim x M) array of source positions over which to 
%               calculate CRLB
%   C           TOA covariance matrix [s^2]
%   ref_idx     Scalar index of reference sensor, or nDim x nPair
%               matrix of sensor pairings
%
% Outputs:
%   crlb    Lower bound on the error covariance matrix for an unbiased
%           TDOA estimator (Ndim x Ndim)
%
% Nicholas O'Donoughue
% 1 July 2019

% Parse inputs
if nargin < 4 || ~exist('ref_idx','var')
    ref_idx = [];
end
n_dim = size(x_tdoa,1);
n_source = size(xs,2);


% Construct Jacobian function handle
J = @(x) tdoa.jacobian(x_tdoa,x,ref_idx);

% Preprocess covariance matrix
C_d = decomposition(C*utils.constants.c^2,'qr');

% Initialize output variable
crlb = zeros([n_dim,n_dim,n_source]);

% Repeat CRLB for each of the n_source test positions
for idx =1:n_source
    this_x = xs(:,idx);
    J_i = J(this_x);
    F = J_i*(C_d\J_i'); % Ndim x Ndim
    if any(isnan(F(:))) || any(isinf(F(:)))
        % Problem is ill defined, Fisher Information Matrix cannot be
        % inverted
        crlb(:,:,idx) = NaN;
    else
        % Invert the Fisher Information Matrix to compute the CRLB
        crlb(:,:,idx) = pinv(F);
    end
end

