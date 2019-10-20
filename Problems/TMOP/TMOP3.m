classdef TMOP3 < PROBLEM
% <problem> <TMOP>
% Traditional benchmark MOP
% Poloni's MOP (transformed minimization problem)

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
        function obj = TMOP3()
            obj.Global.M = 2;
            obj.Global.D = 2;
            obj.Global.lower    = [-pi,-pi];
            obj.Global.upper    = [pi,pi];
            obj.Global.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(~,X)
            A1 = 0.5*sin(1)-2*cos(1)+sin(2)-1.5*cos(2);
            A2 = 1.5*sin(1)-cos(1)+2*sin(2)-0.5*cos(2);
            B1 = 0.5*sin(X(:,1))-2*cos(X(:,1))+sin(X(:,2))-1.5*cos(X(:,2));
            B2 = 1.5*sin(X(:,1))-cos(X(:,1))+2*sin(X(:,2))-0.5*cos(X(:,2));
            PopObj(:,1) = (1+(A1-B1).^2+(A2-B2).^2);
            PopObj(:,2) = ((X(:,1)+3).^2+(X(:,2)+1).^2);
        end
        %% Sample reference points on Pareto front
        function P = PF(obj,N)
            X = obj.PS(N);
            P = obj.CalObj(X);
            P = P(NDSort(P,1)==1,:);
        end
         %% Sample Pareto Set
        function X = PS(obj,N)
            %% Should be changed later
            X1 = zeros(10000,2);
            for i = 0 : 30
                for j = 0 : 180
                    X1(i*181+j+1,1) = -3.3+0.01*i;
                    X1(i*181+j+1,2) = -1.0+0.01*j;
                end
            end
            X2 = zeros(10000,2);
            for i = 0 : 40
                for j = 0 : 50
                    X2(i*51+j+1,1) = 0.7+0.01*i;
                    X2(i*51+j+1,2) = 1.5+0.01*j;
                end
            end
            X = vertcat(X1,X2);
            P = obj.CalObj(X);
            X = X(NDSort(P,1)==1,:);
        end
    end
end