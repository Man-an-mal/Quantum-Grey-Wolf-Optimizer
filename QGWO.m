function [BestFitness, BestPos, convergence_curve] = QGWO(MaxWolves, MaxIter, ub, lb, dim, f)
% Quantum-inspired Grey Wolf Optimizer (QGWO)
% Author: Manan Mal
% Date: 2025
%
% Inputs:
%   MaxWolves  - population size
%   MaxIter    - number of iterations
%   ub, lb     - upper and lower bounds (can be scalar or vector)
%   dim        - problem dimensionality
%   f          - objective/fitness function handle
%
% Outputs:
%   BestFitness       - best fitness found
%   BestPos           - position of best wolf
%   convergence_curve - vector tracking best fitness over iterations

%% --- Initialization -----------------------------------------------------
if isscalar(ub)
    ub = ub .* ones(1, dim);
    lb = lb .* ones(1, dim);
end

X = rand(MaxWolves, dim) .* (ub - lb) + lb;  % initial wolf positions
Fitness = inf(MaxWolves, 1);

% initialize leader wolves
Alpha.pos = zeros(1, dim); Alpha.fit = inf;
Beta.pos  = zeros(1, dim); Beta.fit  = inf;
Delta.pos = zeros(1, dim); Delta.fit = inf;

% parameters for local attractor weighting
c1 = 2.05; 
c2 = 2.05; 

convergence_curve = zeros(1, MaxIter);

%% --- Main Optimization Loop --------------------------------------------
for iter = 1:MaxIter
    
    % --- Evaluate fitness and identify leaders ---
    for i = 1:MaxWolves
        Fitness(i) = f(X(i, :));
        
        if Fitness(i) < Alpha.fit
            Delta = Beta;
            Beta = Alpha;
            Alpha.pos = X(i, :);
            Alpha.fit = Fitness(i);
        elseif Fitness(i) < Beta.fit
            Delta = Beta;
            Beta.pos = X(i, :);
            Beta.fit = Fitness(i);
        elseif Fitness(i) < Delta.fit
            Delta.pos = X(i, :);
            Delta.fit = Fitness(i);
        end
    end
    
    % --- Compute leaders mean (mbest) ---
    mbest = (Alpha.pos + Beta.pos + Delta.pos) / 3;
    
    % --- Quantum-inspired update for each wolf ---
    for i = 1:MaxWolves
        
        % local attractor (quantum-inspired combination)
        r1 = rand(1, dim);
        r2 = rand(1, dim);
        fy = (c1 * r1) ./ (c1 * r1 + c2 * r2);
        
        % randomly pick one of the leaders or the direction vector
        slct = [Alpha.pos; Beta.pos; Delta.pos; (Alpha.pos - X(i, :))];
        LA = fy .* X(i, :) + (1 - fy) .* slct(randi([1,4]), :);
        
        % logarithmic (quantum) jump factor
        rr = log(1 ./ rand(1, dim));
        
        % quantum jump control coefficient (similar to beta_t in QPSO)
        beta_t = 1.5 - 1.4 * (iter / MaxIter);  % decays from 1.5 → 0.1
        
        R = rand;
        if R < 1/3
            Xnew = LA + beta_t .* abs(X(i, :) - mbest) .* rr;
        elseif R < 2/3
            Xnew = LA - beta_t .* abs(X(i, :) - mbest) .* rr;
        else
            Xnew = LA;
        end
        
        % apply boundary constraints
        Xnew = ApplyBounds(Xnew, lb, ub);
        
        % greedy selection
        newFit = f(Xnew);
        if newFit < Fitness(i)
            X(i, :) = Xnew;
            Fitness(i) = newFit;
        end
    end
    
    % --- Update global best ---
    [BestFitness, idx] = min(Fitness);
    BestPos = X(idx, :);
    
    % --- Store best fitness per iteration ---
    convergence_curve(iter) = BestFitness;
    
    % --- (Optional) display progress ---
    if mod(iter, 50) == 0
        fprintf('Iteration %d/%d | Best = %.4e\n', iter, MaxIter, BestFitness);
    end
    
end

end

%% --- Helper Function: Boundary handling ---------------------------------
function X = ApplyBounds(X, lb, ub)
    X = max(X, lb);
    X = min(X, ub);
end
