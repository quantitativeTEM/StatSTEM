classdef inputStatSTEM < StatSTEMfile
% inputStatSTEM - class to hold input parameters for fitting a Gaussian model
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

    properties
        obs = []; % The image/observation (in double format)
        rhoT = 0; % Starting value width per atom type, zero means find a value by fitting, otherwise define a value for each column type in a N x 1 vector 
        fitRho = true; % Find rho by fitting
        projUnit = []; % Projected unit cell (projUnitCell file)
        fitZeta = true; % Logical, indicating whether the background should be determined by fitting
        zeta = 0; % The background value when not determining the background by fitting
        widthtype = 1; % Use same Gaussian width for different atomic columns (1 = 'same', 0 = 'different', 2 = 'user defined')
        atToFit = 1; % Determine which column should be modelled as Gaussian functions (1 = 'all', otherwise a (n x 1) logical vector is needed)
        test = 0; % Fit under test conditions (maximum number of iterations is set to 4)
        cluster = 0; % Calculation in a cluster, print progress in command window (1 = 'yes', 0 = 'no')
        silent = 0; % Hide progress indication from comment window
        MaxColumns = 10; % Maximum number of expected columns in the image
        testpoints = 0; % Number of test coordinates evaluated to add column in model fit using MAP
        zetamin = 0.0; % Lower limit on background
        rhomin = 0.0; % Lower limit on width of a column
        etamin = 0.0; % Lower limit on intensity of a column
        beta_xmin = 0.0; % Lower limit on x-coordinate of a column
        beta_ymin = 0.0; % Lower limit on y-coordinate of a column
        zetamax = 0.0; % Upper limit on background
        rhomax = 0.0; % Upper limit on width of a column
        etamax = 0.0; % Upper limit on intensity of a column
        beta_xmax = 0.0; % Upper limit on x-coordinate of a column
        beta_ymax = 0.0; % Upper limit on y-coordinate of a column
    end
    
    properties (Dependent=true, Hidden=true)
        atomsToFit % Vector stating which atomic column should be modelled
        findRho % Logical indicating whether the width should be estimated
        n_c % number of atom columns
        K % Size of image in horizontal direction;
        L % Size of image in vertical direction;
        X % Image with values of x-coordinates (in angstrom)
        Y % Image with values of y-coordinates (in angstrom)
        Xaxis % Vector with the coordinates in pixel of x-axis
        Yaxis % Vector with the coordinates in pixel of y-axis
        Xreshape % Vector with values of x-coordinates (in pixels) of image
        Yreshape % Vector with values of y-coordinates (in pixels) of image
	    reshapeobs % Vector with values of image
        indMat % Image with indices numbers (for parallel computing)
        rho_start % Vector with starting values of width per atom type for fitting procedure
        dist % Mean distance between atomic columns (angstrom)
    end
    
    properties (Hidden)
        maxIter = 400; % Maximum number of iterations
        Sval = 100; % Number of columns needed to switch from fitting procedure that estimated Gaussian peaks all at ones to the separate approach
    end
    
    properties (SetAccess = private, Hidden)
        pDist = 0;
        indWorkers = {};
        indAllWorkers = [];
    end
    
    methods
        obj = devideIndices(obj)
        output = fitGauss(obj)
        obj = averageDistance(obj)
        output = fitWidth(input, Tol, TolFun, offwait, maxwait)
        output = getLinFitParam(input,rho,coordinates)
        obj = addPeaks(obj)
        obj = removePeaks(obj)
        obj = removeAllPeaks(obj)
        obj = keepPeaks(obj)
        obj = deletePeaks(obj)
        obj = numberATypes(obj,item)
        [input,strainmapping] = loadPUC(input,strainmapping)
        obj = changePeaks(obj,type)
        obj = RunPeakFinder(obj)
        obj = importPeaks(obj)
        obj = defineRho(obj,Name,Value,varargin)
        obj = selectPartImage(obj)
        obj = flipContrastImage(obj)
        obj = calibrateImage(obj)
        obj = autoAssignTypes(obj,varargin)
        [output,outputMAP] = MAP_back_samerho(input)
    end
    
    % Functions to make sure input is correct
    methods
        function obj = inputStatSTEM(obs,dx,coordinates,types,Name,Value,varargin)
            % Create a input file for StatSTEM
            obj.obs = obs;
            if nargin>=2
                obj.dx = dx;
            else
                dx = obj.dx;
            end
            obj.beta_xmin = 0.5*dx;
            obj.beta_ymin = 0.5*dx;
            obj.beta_xmax = (size(obj.obs,2)+0.5)*dx;
            obj.beta_ymax = (size(obj.obs,1)+0.5)*dx;
            try
                obj.zetamax = max(max(obj.obs));
            catch
                obj.zetamax = 0;
            end
            obj.rhomax = mean(size(obj.obs));
            obj.etamax = obj.zetamax;
            obj.testpoints = round((size(obj.obs,2)+size(obj.obs,1))/2);
            if nargin>=3
                obj.coordinates = coordinates;
            end
            if nargin>=4
                obj.types = types;
            end
            if nargin>5
                varargin = [{Name},{Value},varargin];
            end
            if ~isempty(varargin)
                N = length(varargin);
                for n=1:2:N-1
                    obj.(varargin{n}) = varargin{n+1};
                end
            end
        end
        
        function obj = set.obs(obj,val)
            % Check if input is correct
            if isa(val,'double') && ~isempty(val)
                if size(val,3)>1
                    val = selectImageFromStack(val);
                end
                obj.obs = val;
            else
                errordlg('StatSTEMfile: Not a valid image given')
            end
        end
        
        function obj = set.rhoT(obj,val)
            % Check if input is correct
            if isa(val,'double') && (isempty(val) || ( size(val,1)>=0 && size(val,2)==1 ) ) && min(val)>=0
                obj.rhoT = val;
            else
                error('StatSTEMfile: rhoT vector not properly defined, must be a vector with positive numbers (or zeros)')
            end
        end
        
        function obj = set.fitRho(obj,val)
            % Check if input is correct
            if isa(val,'logical')
                obj.fitRho = val;
            elseif isa(val,'double') && (val==0 || val==1)
                obj.fitRho = val==1;
            else
                error('StatSTEMfile: fitRho must be a logical')
            end
        end
        
        function obj = set.fitZeta(obj,val)
            % Check if input is correct
            if isa(val,'logical')
                obj.fitZeta = val;
            elseif isa(val,'double') && (val==0 || val==1)
                obj.fitZeta = val==1;
            else
                error('StatSTEMfile: FitZeta must be a logical')
            end
        end
        
        function obj = set.zeta(obj,val)
            % Check if input is correct
            if isa(val,'double') && length(val)==1
                obj.zeta = val;
            else
                error('StatSTEMfile: zeta must be a number')
            end
        end 
        
        function obj = set.widthtype(obj,val)
            % Check if input is correct
            if isa(val,'double') && length(val)==1 && max(val)<=2 && min(val)>=0
                obj.widthtype = val;
            elseif isa(val,'char')
                switch lower(val)
                    case 'same width'
                        obj.widthtype = 1;
                    case 'different width'
                        obj.widthtype = 0;
                    case 'user defined'
                        obj.widthtype = 2;
                    otherwise
                        error('StatSTEMfile: widthtype must be equal to 0, 1 or 2')
                end
            else
                error('StatSTEMfile: widthtype must be equal to 0, 1 or 2')
            end
        end 
          
        function obj = set.atToFit(obj,val)
            % Check if input is correct
            if (length(val)==1 && val==1) || (length(val)>1 && min(val)>=0 && max(val)<=1)
                obj.atToFit = val;
            else
                error('StatSTEMfile: atToFit must be equal to 1 or (n x 1) vector indicating for each column whether it should be fitted')
            end
        end
        
        function val = get.atomsToFit(obj)
            % Check if input is correct
            N = length(obj.atToFit);
            n_c = size(obj.coordinates,1);
            if N==1
                val = ones(n_c,1);
            else
                if N~=n_c
                    val = ones(n_c,1);
                    warning('StatSTEMfile: length atToFit different than the number of coordinates, all atomic columns selected for fitting')
                else
                    val = obj.atToFit;
                end
            end
        end
        
        function obj = set.test(obj,val)
            % Check if input is correct
            if isa(val,'logical')
                obj.test = val;
            elseif isa(val,'double') && (val==0 || val==1)
                obj.test = val==1;
            else
                error('StatSTEMfile: test must be a logical')
            end
        end 
        
        function obj = set.cluster(obj,val)
            % Check if input is correct
            if isa(val,'logical')
                obj.cluster = val;
            elseif isa(val,'double') && (val==0 || val==1)
                obj.cluster = val==1;
            else
                error('StatSTEMfile: cluster must be a logical')
            end
        end
        
        function obj = set.maxIter(obj,val)
            % Check if input is correct
            if isa(val,'double') && val>0
                obj.maxIter = val;
            else
                error('StatSTEMfile: maxIter must be a positive number')
            end
        end
        
        function obj = set.silent(obj,val)
            % Check if input is correct
            if isa(val,'logical')
                obj.silent = val;
            elseif isa(val,'double') && (val==0 || val==1)
                obj.silent = val==1;
            else
                error('StatSTEMfile: silent must be a logical')
            end
        end
        
        function val = get.findRho(obj)
            % Check whether width should be found by fitting
            val = 1;
            if (obj.test==1 || obj.widthtype==2) && ~any(obj.rhoT==0) && length(obj.rhoT)>=max(obj.coordinates(:,3))
                val = 0;
            elseif ~any(obj.rhoT==0) && obj.fitRho==0
                if length(obj.rhoT)>=max(obj.coordinates(:,3))
                    val = 0;
                else
                    warning('StatSTEMfile: start values rho not defined for every atom type, values will be found by fitting')
                end
            end
        end
        
        function val = get.n_c(obj)
            % Find number of columns
            val = size(obj.coordinates,1);        
        end
        
        function val = get.K(obj)
            val = size(obj.obs,2);                   
        end
        
        function val = get.L(obj)
            val = size(obj.obs,1);                   
        end
        
        function val = get.Xaxis(obj)
            val = (1:obj.K)*obj.dx;
        end
        
        function val = get.X(obj)
            val = repmat( obj.Xaxis , obj.L, 1);
        end
        
        function val = get.Yaxis(obj)
            val = (1:obj.L)'*obj.dx;
        end
        
        function val = get.Y(obj)
            val = repmat( obj.Yaxis, 1, obj.K);
        end
        
        function val = get.Xreshape(obj)
            val = reshape(obj.X,obj.K*obj.L,1);
        end
        
        function val = get.Yreshape(obj)
            val = reshape(obj.Y,obj.K*obj.L,1);
        end
        
        function val = get.reshapeobs(obj)
            val = reshape(obj.obs,obj.K*obj.L,1);
        end
        
        function val = get.maxIter(obj)
            if obj.test==1
                val = 4;
            else
                val = obj.maxIter;
            end
        end
        
        function val = get.rho_start(obj)
            % Get starting value for the width, rho, of the atomic columns
            if obj.findRho==1
                typ = obj.coordinates(:,3);
                val = obj.dist/4*ones(max(typ),1);
            else
                typ = obj.coordinates(:,3);
                val = obj.rhoT(1:max(typ));
            end
        end
        
        function val = get.dist(obj)
            val = obj.pDist;
        end
        
        function val = get.indMat(obj)
            val = reshape((1:obj.K*obj.L)',obj.L,obj.K);
        end
        
        
        function obj = set.MaxColumns(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>0 && val>=size(obj.coordinates,1)
                obj.MaxColumns = val;
            else
                error('StatSTEMfile: MaxColumns must be positive and greater than initial number of columns')
            end
        end
        
        function obj = set.testpoints(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>0
                obj.testpoints = val;
            else
                error('StatSTEMfile: number of testpoints must be positive')
            end
        end
        
        function obj = set.zetamin(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val)
                obj.zetamin = val;
            else
                error('StatSTEMfile: zetamin must be a number')
            end
        end
        
        function obj = set.rhomin(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>=0
                obj.rhomin = val;
            else
                error('StatSTEMfile: rhomin must be a positive number')
            end
        end
        
        function obj = set.etamin(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val)
                obj.etamin = val;
            else
                error('StatSTEMfile: etamin must be a number')
            end
        end
        
        function obj = set.beta_xmin(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>=0
                obj.beta_xmin = val;
            else
                error('StatSTEMfile: beta_xmin must be a positive number')
            end
        end
        
        function obj = set.beta_ymin(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>=0
                obj.beta_ymin = val;
            else
                error('StatSTEMfile: beta_ymin must be a positive number')
            end
        end
        
        function obj = set.zetamax(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>=obj.zetamin
                obj.zetamax = val;
            else
                error('StatSTEMfile: zetamax must be a number greater than zetamin')
            end
        end
        
        function obj = set.rhomax(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>=obj.rhomin
                obj.rhomax = val;
            else
                error('StatSTEMfile: rhomax must be a number greater than rhomin')
            end
        end
        
        function obj = set.etamax(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>=obj.etamin
                obj.etamax = val;
            else
                error('StatSTEMfile: etamax must be a number greater than etamin')
            end
        end
        
        function obj = set.beta_xmax(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>=obj.beta_xmin
                obj.beta_xmax = val;
            else
                error('StatSTEMfile: beta_xmax must be a number greater than beta_xmin')
            end
        end
        
        function obj = set.beta_ymax(obj,val)
            % Check if input is correct
            if isa(val,'double') && isscalar(val) && val>=obj.beta_ymin
                obj.beta_ymax = val;
            else
                error('StatSTEMfile: beta_ymax must be a number greater than beta_ymin')
            end
        end
    end
end