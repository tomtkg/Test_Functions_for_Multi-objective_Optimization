classdef TMOP2 < PROBLEM
% <problem> <TMOP>
% Traditional benchmark MOP
% Fonseca's second MOP

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
        function obj = TMOP2()
            obj.Global.M = 2;
            if isempty(obj.Global.D)
                obj.Global.D = 3;
            end
            obj.Global.lower    = ones(1,obj.Global.D)*-4;
            obj.Global.upper    = ones(1,obj.Global.D)*4;
            obj.Global.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(~,X)
            [~,D]  = size(X);
            PopObj(:,1) = 1 - exp(-sum((X-1/sqrt(D)).^2,2));
            PopObj(:,2) = 1 - exp(-sum((X+1/sqrt(D)).^2,2));
        end
        %% Sample reference points on Pareto front
        function P = PF(obj,N)
            X = obj.PS(N);
            P = obj.CalObj(X);
        end
         %% Sample Pareto Set
        function X = PS(obj,N)
            temp = 1/sqrt(obj.Global.D);
            X = -temp:temp*2/(N-1):temp;
            X = repmat(X.',1,obj.Global.D);
        end
    end
end