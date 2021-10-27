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
[n_dim, n_sensor] = size(x_tdoa);
n_source = size(xs,2);

% Construct Jacobian function handle
J = @(x) tdoa.jacobian(x_tdoa,x,ref_idx);

% Preprocess covariance matrix
C_out = C*utils.constants.c^2;

% Parse sensor pairs
[test_idx_vec, ref_idx_vec] = utils.parseReferenceSensor(ref_idx, n_sensor);
C_tilde = utils.resampleCovMtx(C_out, test_idx_vec, ref_idx_vec);

% Ensure the covariance matrix is invertible
C_tilde = utils.ensureInvertible(C_tilde);

% Pre-compute covariance matrix inverses
do_decomp = ~verLessThan('MATLAB','9.3');
if do_decomp
    % Starging in R2017b, MATLAB released the DECOMPOSITION function,
    % which can decompose matrices for faster computation of left- and
    % right-division in for loops.
    C_d = decomposition(C_tilde,'chol');
else
    % If DECOMPOSITION is unavailable, let's precompute the pseudo-inverse.
    C_inv = pinv(C_tilde);
end

% Initialize output variable
crlb = zeros([n_dim,n_dim,n_source]);

warning('on','MATLAB:nearlySingularMatrix')
        
% Repeat CRLB for each of the n_source test positions
for idx =1:n_source
    this_x = xs(:,idx);
    
    % Evaluate Jacobian at x_i
    J_i = J(this_x);
    
    % Compute Fisher Information Matrix
    if do_decomp
        F = J_i/C_d*J_i'; % Ndim x Ndim
    else
        F = J_i*C_inv*J_i';
    end
    
    if any(isnan(F(:))) || any(isinf(F(:)))
        % Problem is ill defined, Fisher Information Matrix cannot be
        % inverted
        crlb(:,:,idx) = NaN;
    elseif any(diag(F)<= 1e-15)
        % Problem is ill-defined
        valid_ind = diag(F) > 1e-15;
        crlb(~valid_ind,~valid_ind,idx) = Inf;
        crlb(valid_ind,valid_ind,idx) = inv(F(valid_ind,valid_ind));
    else
        % Invert the Fisher Information Matrix to compute the CRLB
        C = inv(F);
        if any(diag(C)<0)
            % We got a negative noise term; invalid result
            crlb(:,:,idx) = NaN;
        else
            crlb(:,:,idx) = C;
        end
    end
end

warning('off','MATLAB:nearlySingularMatrix');