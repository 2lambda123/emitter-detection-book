function [x,x_full] = gdSoln(y,J,C,x_init,alpha,beta,epsilon,max_num_iterations,force_full_calc,plot_progress)
% [x,x_full] = gdSoln(y,J,C,x_init,epsilon,max_num_iterations,force_full_calc,plot_progress)
%
% Computes the gradient descent solution for localization given the 
% provided measurement and Jacobian function handles, and measurement 
% error covariance.
%
% Inputs:
%   
%   y               Measurement vector function handle (accepts n_dim 
%                   vector of source position estimate, responds with error 
%                   between received and modeled data vector)
%   J               Jacobian matrix function handle (accepts n_dim vector
%                   of source position estimate, and responds with n_dim x
%                   n_sensor Jacobian matrix
%   C               Measurement error covariance matrix
%   x_init          Initial estimate of source position
%   alpha           Backtracking line search parameter
%   beta            Backtracking line search parameter
%   epsilon         Desired position error tolerance (stopping condition)
%   max_num_iterations  Maximum number of LS iterations to perform
%   force_full_calc Forces all max_num_iterations to be executed
%   plot_progress   Binary flag indicating whether to plot error/pos est
%                   over time
%
% Outputs:
%   x               Estimated source position
%   x_full          Iteration-by-iteration estimated source positions
%
% Nicholas O'Donoughue
% 1 July 2019

% Parse inputs
n_dims = numel(x_init);

if nargin < 9 || isempty(plot_progress)
    % By default, do not plot
    plot_progress = false;
end

if nargin < 8 || isempty(force_full_calc)
    % If not specified, don't force the solver to run until it hits
    % max_num_iterations
    force_full_calc = false;
end

if nargin < 7 || isempty(max_num_iterations)
    % Number of iterations not specified, default is 10,000
    max_num_iterations = 10000;
end

if nargin < 6 || isempty(epsilon)
    % Maximum error not specified; default to .1 (distance units)
    epsilon = 1e-6;
end

if nargin < 5 || isempty(beta)
    beta = .8;
end

if nargin < 4 || isempty(alpha)
    alpha = .3;
end

% Initialize loop
iter = 1;
error = Inf;
x_full = zeros(n_dims,max_num_iterations);
x_prev = x_init;
x_full(:,1) = x_prev;

% Pre-compute covariance matrix inverses
% [U,Lambda] = eig(C);
% lam = diag(Lambda);
% C_inv = U*diag(1./lam)*U';
% C_sq_inv = U*diag(1./sqrt(lam))*U';
C_d = decomposition(C);

% Cost Function for Gradient Descent
f = @(x) y(x)'/C_d*y(x);

% Initialize Plotting
if plot_progress
    fig_plot=figure;
    subplot(211);
    xlabel('Iteration Number');
    ylabel('Change in Position Estimate');
    hold on;
    set(gca,'yscale','log')
    subplot(212);
    xlabel('x');
    ylabel('y');
end

% Divergence Detection
num_expanding_iters = 0;
max_num_expanding_iters = 5;
prev_error = Inf;

% Loop until either the desired tolerance is achieved or the maximum
% number of iterations have occurred
while iter < max_num_iterations && (force_full_calc || error >= epsilon)
    iter = iter+1;

    % Evaluate Residual and Jacobian Matrix
    y_i = y(x_prev);
    J_i = J(x_prev);
    
    % Compute Gradient and Cost function
    grad = -2*J_i/C_d*y_i;
    
    % Descent direction is the negative of the gradient
    del_x = -grad/norm(grad);
    
    % Compute the step size
    t = utils.backtrackingLineSearch(f,x_prev,grad,del_x,alpha,beta);
    
    % Update x position
    x_full(:,iter) = x_prev + t*del_x;
    
    % Update variables
    x_prev = x_full(:,iter);
    error = t;
    
    if plot_progress
        figure(fig_plot);
        subplot(211);
        plot(iter,error,'.');
        subplot(212);
        plot(x_full(1,1:iter),x_full(2,1:iter),'-+');
    end
    
    % Check for divergence
    if error <= prev_error
        num_expanding_iters = 0;
    else
        num_expanding_iters = num_expanding_iters + 1;
        if num_expanding_iters >= max_num_expanding_iters
            % Divergence detected
            x_full(:,iter:end) = NaN;%repmat(x_full(:,iter),1,maxIters-iter+1);
            break;
        end
    end
    prev_error = error;
end

% Bookkeeping
if ~force_full_calc
    x_full = x_full(:,1:iter);
end
x = x_full(:,iter);
