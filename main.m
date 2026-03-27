clc; clear; close all;

%% --- Algorithm parameters ---
Agent = 50;       % population size
Gen = 500;        % iterations
Runs = 10;        % independent runs for statistics

%% --- Select test mode ---
mode = "benchmark";  % options: "benchmark" or "engineering"

switch mode
    case "benchmark"
        % Benchmark test suite F1–F23
        Functions = {'F1','F2','F3','F4','F5','F6','F7','F8','F9','F10',...
                     'F11','F12','F13','F14','F15','F16','F17','F18','F19','F20',...
                     'F21','F22','F23'};
        GetFunc = @BM;   % benchmark function provider
    case "engineering"
        % Engineering design problems (from Get_Functions_details)
        Functions = {'F1','F2','F3','F4','F5','F6'};
        GetFunc = @Get_Functions_details;
end

%% --- Storage for results ---
Results = struct();

%% --- Run test suite ---
for idx = 1:numel(Functions)
    FuncName = Functions{idx};
    fprintf('\n--- Running %s (%s test) ---\n', FuncName, mode);

    [lb, ub, dim, f] = GetFunc(FuncName);
    
    % making sure bounds are vectors
    if isscalar(ub)
        ub = repmat(ub, 1, dim);
        lb = repmat(lb, 1, dim);
    end

    BestVals = zeros(Runs,1);

    % Run multiple trials for statistical robustness
    for run = 1:Runs
        fprintf('Run %d/%d ...\n', run, Runs);
        [Val, Loc, plt] = QGWO(Agent, Gen, ub, lb, dim, f);
        BestVals(run) = Val;

        % Plot convergence 
        if run == 1
            figure('Name',[FuncName ' Convergence'],'NumberTitle','off');
            semilogy(plt, 'LineWidth', 2); grid on;
            title(['QGWO Convergence on ' FuncName]);
            xlabel('Iteration'); ylabel('Best Fitness');
            drawnow;
        end
    end

    % Compute statistics
    Best = min(BestVals);
    MeanVal = mean(BestVals);
    StdVal = std(BestVals);

    Results.(FuncName).Best = Best;
    Results.(FuncName).Mean = MeanVal;
    Results.(FuncName).Std = StdVal;

    fprintf(' → %s results: Best = %.4e | Mean = %.4e | Std = %.4e\n', ...
            FuncName, Best, MeanVal, StdVal);
end

%% --- Summarize results ---
fprintf('\n=== QGWO Summary (%s mode) ===\n', mode);
fprintf('Function\tBest\t\tMean\t\tStd\n');
for idx = 1:numel(Functions)
    F = Functions{idx};
    fprintf('%s\t%.3e\t%.3e\t%.3e\n', F, ...
        Results.(F).Best, Results.(F).Mean, Results.(F).Std);
end

%% --- Example single run for detailed plot ---
% For just visualizing one benchmark
% Function_name = 'F2';
% [lb,ub,dim,f] = BM(Function_name);
% [Val,Loc,plt] = QGWO(Agent,Gen,ub,lb,dim,f);
% figure; semilogy(plt,'LineWidth',2);
% title(['Convergence on ' Function_name]); xlabel('Iteration'); ylabel('Fitness');











