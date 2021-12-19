classdef DASCMOP8 < PROBLEM
% <problem> <DAS-CMOP>
% Difficulty-adjustable and scalable constrained benchmark MOP

%------------------------------- Reference --------------------------------
% Z. Fan, W. Li, X. Cai, H. Li, C. Wei, Q. Zhang, K. Deb, and E. Goodman,
% Difficulty adjustable and scalable constrained multi-objective test
% problem toolkit, Evolutionary Computation, 2019.
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
        function obj = DASCMOP8()
            obj.Global.M = 3;
            if isempty(obj.Global.D)
                obj.Global.D = 30;
            end
            obj.Global.lower    = zeros(1,obj.Global.D);
            obj.Global.upper    = ones(1,obj.Global.D);
            obj.Global.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,X)
            x_all = X(:,3:1:end); 
            g_1   = sum((x_all - 0.5) .* (x_all - 0.5) - cos(20.0 * pi .* ( x_all - 0.5)),2);
            sum1  = obj.Global.D - 2 + g_1;
            
            PopObj(:,1) = cos(0.5 * pi * X(:,1)) .* cos(0.5 * pi * X(:,2)) + sum1 ;     
            PopObj(:,2) = cos(0.5 * pi * X(:,1)) .* sin(0.5 * pi * X(:,2)) + sum1;
            PopObj(:,3) = sin(0.5 * pi * X(:,1)) + sum1;
        end
        %% Calculate constraint violations
        function PopCon = CalCon(obj,X) 
            x_all = X(:,3:1:end); 
            g_1   = sum((x_all - 0.5) .* (x_all - 0.5) - cos(20.0 * pi .* ( x_all - 0.5)),2);
            sum1  = obj.Global.D - 2 + g_1; 
            
            % set the parameters of constraints
            DifficultyFactors = [0.5,0.5,0.5];
            % Type-I parameters
            a = 20;
            b = 2 * DifficultyFactors(1) - 1;                            
            % Type-II parameters
            d = 0.5;
            if DifficultyFactors(2) == 0.0                               
                d = 0.0;
            end
            e = d - log(DifficultyFactors(2));                          
            if isfinite(e) == 0
                e = 1e+30;
            end
            % Type-III parameters
            r = 0.5 * DifficultyFactors(3);                             
            
            PopObj = obj.CalObj(X);
            % Type-I constraints
            PopCon(:,1) = b - sin(a * pi * X(:,1));
            PopCon(:,2) = b - cos(a * pi * X(:,2));
            % Type-II constraints
            PopCon(:,3) = -(e - sum1) .* (sum1 - d);
            if DifficultyFactors(2) == 1.0                            
                PopCon(:,3) = 1e-4 - abs(sum1 - e);
            end
            % Type-III constraints
            x_k = [1.0, 0.0, 0.0, 1.0 / sqrt(3.0)];
            y_k = [0.0, 1.0, 0.0, 1.0 / sqrt(3.0)];
            z_k = [0.0, 0.0, 1.0, 1.0 / sqrt(3.0)];
            
            for k=1:length(x_k)
                PopCon(:,3+k) = r * r - ((PopObj(:,1) - x_k(k))).^2  -...
                    ((PopObj(:,2) - y_k(k))).^2 - ((PopObj(:,3) - z_k(k))).^2;
            end
        end
        %% Sample reference points on Pareto front
        function P = PF(obj,N)
            P = UniformPoint(N,3);
            P = P./repmat(sqrt(sum(P.^2,2)),1,3);
            X(:,2) = atan(P(:,2)./P(:,1))/0.5/pi;
            X(:,1) = acos(P(:,1)./cos(0.5*pi*X(:,2)))/0.5/pi;
            C(:,1) = -sin(20*pi*X(:,1));
            C(:,2) = -cos(20*pi*X(:,2));
            P(any(C>1e-2,2),:) = [];
            P = P + 0.5;
        end 
    end
end