classdef GLOBAL < handle
    properties
        N          = 200;               % Population size
        P          = 21;                % Particle size
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
            propertyStr = {'N','M','D','problem','P'};
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
            InitX = unifrnd(repmat(obj.lower,obj.N,1),repmat(obj.upper,obj.N,1));
            Init = obj.problem.CalObj(InitX);
            InitC = obj.problem.CalCon(InitX);
            %Grid generated solutions
            GridX = zeros(obj.P^obj.D,obj.D);
            for j = 1 : obj.P^obj.D
                for i = 0 : obj.D - 1
                    GridX(j,i+1) = rem(floor((j-1)/obj.P^i),obj.P)/(obj.P-1);
                end
            end
            GridX = GridX.*repmat(obj.upper-obj.lower,obj.P^obj.D,1)+repmat(obj.lower,obj.P^obj.D,1);
            Grid = obj.problem.CalObj(GridX);
            GridC = obj.problem.CalCon(GridX);
            
            figure('visible', 'off');
            Draw(POS,'ok','MarkerSize',obj.M-1,'Marker','o','Markerfacecolor',[1 0 0],'Markeredgecolor',[1 0 0]);
            xmin = min(POS);
            xmax = max(POS);
            SaveFig(obj,xmin,xmax,'PF');
            
            Draw(Init(any(InitC>0,2),:),'ok','MarkerSize',4*(obj.M-1),'Marker','o','Markerfacecolor',[0 0 1],'Markeredgecolor',[0 0 1]);
            Draw(Init(all(InitC<=0,2),:),'ok','MarkerSize',4*(obj.M-1),'Marker','o','Markerfacecolor',[.7 .7 .7],'Markeredgecolor',[.4 .4 .4]);
            xmax = max(vertcat(xmax,Init));
            SaveFig(obj,xmin,xmax,'Init');
            close;
            
            figure('visible', 'off');
            Draw(POS,'ok','MarkerSize',obj.M-1,'Marker','o','Markerfacecolor',[1 0 0],'Markeredgecolor',[1 0 0]);
            Draw(Grid(any(GridC>0,2),:),'ok','MarkerSize',4*(obj.M-1),'Marker','o','Markerfacecolor',[0 0 1],'Markeredgecolor',[0 0 1]);
            Draw(Grid(all(GridC<=0,2),:),'ok','MarkerSize',4*(obj.M-1),'Marker','o','Markerfacecolor',[.7 .7 .7],'Markeredgecolor',[.4 .4 .4]);
            xmin = min(POS);
            xmax = max(vertcat(POS,Grid));
            SaveFig(obj,xmin,xmax,'Grid');
            close;

        end
        %% Obtain the parameter settings from user
        function varargout = ParameterSet(obj,varargin)
            CallStack = dbstack();
            caller    = CallStack(2).file;
            caller    = caller(1:end-2);
            varargout = varargin;
            if isfield(obj.parameter,caller)
                specified = cellfun(@(S)~isempty(S),obj.parameter.(caller));
                varargout(specified) = obj.parameter.(caller)(specified);
            end
        end
        %% Variable constraint
        function set.N(obj,value)
            obj.Validation(value,'int','size of population ''-N''',1);
            obj.N = value;
        end
        function set.P(obj,value)
            obj.Validation(value,'int','size of particle ''-P''',1);
            obj.P = value;
        end
        function set.M(obj,value)
            obj.Validation(value,'int','number of objectives ''-M''',2);
            obj.M = value;
        end
        function set.D(obj,value)
            obj.Validation(value,'int','number of variables ''-D''',1);
            obj.D = value;
        end
        function set.problem(obj,value)
            if iscell(value)
                obj.Validation(value{1},'function','test problem ''-problem''');
                obj.problem = value{1};
                obj.parameter.(func2str(value{1})) = value(2:end);
            elseif ~isa(value,'PROBLEM')
                obj.Validation(value,'function','test problem ''-problem''');
                obj.problem = value;
            else
                obj.problem = value;
            end
        end
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
    % The following functions cannot be invoked by users
    methods(Access = private)
        %% Check the validity of the specific variable
        function Validation(obj,value,Type,str,varargin)
            switch Type
                case 'function'
                    assert(isa(value,'function_handle'),'INPUT ERROR: the %s must be a function handle',str);
                    assert(~isempty(which(func2str(value))),'INPUT ERROR: the function <%s> does not exist',func2str(value));
                case 'int'
                    assert(isa(value,'double') && isreal(value) && isscalar(value) && value==fix(value),'INPUT ERROR: the %s must be an integer scalar',str);
                    if ~isempty(varargin); assert(value>=varargin{1},'INPUT ERROR: the %s must be not less than %d',str,varargin{1}); end
                    if length(varargin) > 1; assert(value<=varargin{2},'INPUT ERROR: the %s must be not more than %d',str,varargin{2}); end
                    if length(varargin) > 2; assert(mod(value,varargin{3})==0,'INPUT ERROR: the %s must be a multiple of %d',str,varargin{3}); end
            end
        end
    end
end