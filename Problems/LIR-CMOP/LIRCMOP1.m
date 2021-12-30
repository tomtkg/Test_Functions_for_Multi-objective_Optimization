classdef LIRCMOP1 < PROBLEM
% <problem> <LIR-CMOP>
% Constrained benchmark MOP with large infeasible regions

%------------------------------- Reference --------------------------------
% Z. Fan, W. Li, X. Cai, H. Huang, Y. Fang, Y. You, J. Mo, C. Wei, and E.
% Goodman, An improved epsilon constraint-handling method in MOEA/D for
% CMOPs with large infeasible regions, Soft Computing, 2019.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

% This function is written by Wenji Li
    
    methods
        %% Initialization
        function obj = LIRCMOP1()
            obj.Global.M = 2;
            if isempty(obj.Global.D)
                obj.Global.D = 30;
            end
            obj.Global.lower    = zeros(1,obj.Global.D);
            obj.Global.upper    = ones(1,obj.Global.D);
            obj.Global.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,X)
            x_odd       = X(:,3:2:end);
            x_even      = X(:,2:2:end);
            g_1         = sum((x_odd - sin(0.5 * pi * X(:,1))).^2,2);
            g_2         = sum((x_even - cos(0.5 * pi * X(:,1))).^2,2);
            PopObj(:,1) = X(:,1) + g_1;
            PopObj(:,2) = 1 - X(:,1) .^ 2 + g_2;
        end
        %% Calculate constraint violations
        function PopCon = CalCon(obj,X)
            x_odd       = X(:,3:2:end);
            x_even      = X(:,2:2:end);
            g_1         = sum((x_odd - sin(0.5 * pi * X(:,1))).^2,2);
            g_2         = sum((x_even - cos(0.5 * pi * X(:,1))).^2,2);
            PopCon(:,1) = (0.5 - g_1).*(0.51 - g_1);
            PopCon(:,2) = (0.5 - g_2).*(0.51 - g_2);
        end 
        %% Sample reference points on Pareto front
        function P = PF(obj,N)
            P(:,1) = (0:1/(N-1):1)';
            P(:,2) = 1 - P(:,1).^2;
            P      = P + 0.5;
        end
    end
end