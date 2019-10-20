classdef TMOP1 < PROBLEM
% <problem> <TMOP>
% Traditional benchmark MOP
% Schaffer's first (unconstrained) two-objective function

%------------------------------- Reference --------------------------------
% Coello, Carlos A. Coello, Gary B. Lamont, and David A. Van Veldhuizen,
% Evolutionary algorithms for solving multi-objective problems, 2007, 5.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

% This function is written by Tomoaki Takagi

    methods
        %% Initialization
        function obj = TMOP1()
            obj.Global.M = 2;
            obj.Global.D = 1;
            obj.Global.lower    = -10^5;
            obj.Global.upper    = 10^5;
            obj.Global.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(~,X)
            PopObj(:,1) = X.^2;
            PopObj(:,2) = (X-2).^2;
        end
        %% Sample reference points on Pareto front
        function P = PF(obj,N)
            X = obj.PS(N);
            P = obj.CalObj(X);
        end
         %% Sample Pareto Set
        function X = PS(~,N)
            X = 0:2/(N-1):2;
        end
    end
end