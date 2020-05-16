classdef GLOBAL < handle
    properties
        N          = 200;               % Population size
    end
    properties(SetAccess = ?PROBLEM)
        M;                              % Number of objectives
        D;                              % Number of decision variables
        lower;                          % Lower bound of each decision variable
        upper;                          % Upper bound of each decision variable
        encoding   = 'real';            % Encoding of the problem
    end
    properties(SetAccess = private)
        problem    = @DTLZ2;            % Problem function
        PF;                             % True Pareto front
        parameter  = struct();      	% Parameters of functions specified by users
    end
    methods
        %% Constructor
        function obj = GLOBAL(varargin)
            obj.GetObj(obj);
            % Initialize the parameters which can be specified by users
            propertyStr = {'M','D','problem'};
            if nargin > 0
                IsString = find(cellfun(@ischar,varargin(1:end-1))&~cellfun(@isempty,varargin(2:end)));
                [~,Loc]  = ismember(varargin(IsString),cellfun(@(S)['-',S],propertyStr,'UniformOutput',false));
                for i = find(Loc)
                    obj.(varargin{IsString(i)}(2:end)) = varargin{IsString(i)+1};
                end
            end
            % Instantiate a problem object
            obj.problem = obj.problem();
            % Add the folders of the problem to the top of the search path
            addpath(fileparts(which(class(obj.problem))));
        end
        %% Start running the algorithm
        function Start(obj)
            %Pareto optimal solutions
            POS = obj.problem.PF(10000);
            
            %Random generated solutions
            switch obj.encoding
                case 'binary'
                    InitX = randi([0,1],obj.N,obj.D);
                case 'permutation'
                    [~,InitX] = sort(rand(obj.N,obj.D),2);
                otherwise
                    InitX = unifrnd(repmat(obj.lower,obj.N,1),repmat(obj.upper,obj.N,1));
            end
            Init = obj.problem.CalObj(InitX);
            InitC = obj.problem.CalCon(InitX);
            
            %Save figure
            figure('visible', 'off');
            Draw(POS,'ok','MarkerSize',obj.M-1,'Marker','o','Markerfacecolor',[1 0 0],'Markeredgecolor',[1 0 0]);
            SaveFig(obj,min(POS),max(POS),'PF');
            
            Draw(Init(any(InitC>0,2),:),'ok','MarkerSize',4*(obj.M-1),'Marker','o','Markerfacecolor',[0 0 1],'Markeredgecolor',[0 0 1]);
            Draw(Init(all(InitC<=0,2),:),'ok','MarkerSize',4*(obj.M-1),'Marker','o','Markerfacecolor',[.7 .7 .7],'Markeredgecolor',[.4 .4 .4]);
            SaveFig(obj,min([POS;Init]),max([POS;Init]),'Init');
            close;
            
            if obj.D <= 5
                div = 21;
                %Grid generated solutions
                GridX = zeros(div^obj.D,obj.D);
                for j = 1 : div^obj.D
                    for i = 0 : obj.D - 1
                        GridX(j,i+1) = rem(floor((j-1)/div^i),div)/(div-1);
                    end
                end
                GridX = GridX.*repmat(obj.upper-obj.lower,div^obj.D,1)+repmat(obj.lower,div^obj.D,1);
                Grid = obj.problem.CalObj(GridX);
                GridC = obj.problem.CalCon(GridX);
                
                %Save figure
                figure('visible', 'off');
                Draw(POS,'ok','MarkerSize',obj.M-1,'Marker','o','Markerfacecolor',[1 0 0],'Markeredgecolor',[1 0 0]);
                Draw(Grid(any(GridC>0,2),:),'ok','MarkerSize',4*(obj.M-1),'Marker','o','Markerfacecolor',[0 0 1],'Markeredgecolor',[0 0 1]);
                Draw(Grid(all(GridC<=0,2),:),'ok','MarkerSize',4*(obj.M-1),'Marker','o','Markerfacecolor',[.7 .7 .7],'Markeredgecolor',[.4 .4 .4]);
                SaveFig(obj,min([POS;Grid]),max([POS;Grid]),'Grid');
                close;
            end
        end
        %% Obtain the parameter settings from user
        function varargout = ParameterSet(obj,varargin)
            CallStack = dbstack();
            caller    = CallStack(2).file;
            caller    = caller(1:end-2);
            varargout = varargin;
            if isfield(obj.parameter,caller)
                specified = ~cellfun(@isempty,obj.parameter.(caller));
                varargout(specified) = obj.parameter.(caller)(specified);
            end
        end
        %% Variable constraint
        function set.M(obj,value);obj.M = value;end
        function set.D(obj,value);obj.D = value;end
        function set.problem(obj,value);obj.problem = value;end
    end
    methods(Static)
        %% Get the current GLOBAL object
        function obj = GetObj(obj)
            persistent Global;
            if nargin > 0
                Global = obj;
            else
                obj = Global;
            end
        end
    end
end