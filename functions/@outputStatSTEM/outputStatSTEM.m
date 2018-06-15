classdef outputStatSTEM < StatSTEMfile
% inputStatSTEM - class to hold fitted parameters of the Gaussian model
%
%   Advanced analysis options are defined for this class such as:
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
        rho = []; % A (n x 1) vector containing the width of each column (in angstrom)
        eta = []; % A (n x 1) vector containing the height of each column
        zeta = 0; % The background value (standard at 0)
        selRegion = []; % Selected region to extract coordinates (n x 2) vector with x- and y-coordinates for analysis
        rangeVol = []; % Selected range of volumes of the scattering cross-section for analysis [min, max]
        selType = []; % Select type of atoms for analysis
    end
    
    properties % For atom-counting
        n_c = 50; % Maximum number of components when fitting a GMM
    end
       
    properties % For strainmapping
        optRefCoor = 0; % Routine to select reference coordinates: 0-most central, 1-user defined
        findDirA = 0; % Routine to find a-direction: 0-automatic, 1-user defined 
        impByFit = true; % Option to improve found a-direction by fitting (logical)
        nUC = 5; % Number of unit cells used to improve a,b-direction and angle by fitting
        fitABang = 0; % Indicate what should be improved by fitting: 0-angle and a,b-direction, 1-only the angle
    end
    
    
    properties (Dependent)
        volumes = []; % A (n x 1) vector that contains the volume of each atomic column
        model = []; % An image of the fitted Gaussian model
        selCoor = []; % A (n x 3) vector with the selected coordinates for analysis
        selVol = [];
    end
    
    properties (SetAccess=private, Hidden)
        pModel = [];
    end
    
    properties (Hidden)
        lsq = []; % The least squares sum
        iter = []; % Iterations needed for convergence
    end
    
    methods
        showModel(obj,input)
        output = combinedGauss(output, K, L, ind)
        obj = selColumnAtom(obj,state)
        obj = selColumnHist(obj,state)
        obj = selColumnType(obj,state)
        atomcounting = fitGMM(obj)
        libcounting = matchLib(output,library,thick)
        strainmapping = indexColumns(output,input,strainmapping)
    end
    
    methods
        function obj = outputStatSTEM(coordinates,rho,eta,zeta,dx,Name,Value,varargin)
            obj.coordinates = coordinates;
            obj.rho = rho;
            obj.eta = eta;
            obj.zeta = zeta;
            obj.dx = dx;
            if nargin>6
                varargin = [{Name},{Value},varargin];
            end
            if ~isempty(varargin)
                N = length(varargin);
                for n=1:2:N-1
                    obj.(varargin{n}) = varargin{n+1};
                end
            end
        end
        
        function obj = set.rho(obj,val)
            % Check if input is not empty
            if isa(val,'double') && (isempty(val) || ( size(val,1)>=0 && size(val,2)==1 ) )
                obj.rho = val;
            else
                error('StatSTEMfile: Rho vector not properly defined')
            end
        end
        
        function obj = set.eta(obj,val)
            % Check if input is not empty
            if isa(val,'double') && (isempty(val) || ( size(val,1)>=0 && size(val,2)==1 ) )
                obj.eta = val;
            else
                error('StatSTEMfile: Eta vector not properly defined')
            end
        end
        
        function obj = set.zeta(obj,val)
            % Check if input is not empty
            if isa(val,'double') && ~isempty(val)
                obj.zeta = val;
            else
                errordlg('StatSTEMfile: Zeta not properly defined')
            end
        end
        
        function val = get.volumes(obj)
            % Calculate volumes under Gaussian peaks
            val = 2*pi*obj.eta.*obj.rho.^2;
        end
        
        function val = get.model(obj)
            % Get the image of the Gaussian model
            val = obj.pModel;
        end
        
        function obj = loadModel(obj,model)
            % Store a model image (for conversion from previous file
            % formats)
            obj.pModel = model;
        end
        
        function val = get.selCoor(obj)
            ind = getIndSel(obj);
            val = obj.coordinates(ind,:);
        end
        
        function val = get.selVol(obj)
            ind = getIndSel(obj);
            val = obj.volumes(ind,:);
        end
        
        function val = getIndSel(obj)
            val = true(size(obj.coordinates,1),1);
            if ~isempty(obj.selRegion)
                val = val & inpolygon(obj.coordinates(:,1), obj.coordinates(:,2), obj.selRegion(:,1), obj.selRegion(:,2));
            end
            if ~isempty(obj.rangeVol)
                val = val & obj.volumes>=obj.rangeVol(1) & obj.volumes<=obj.rangeVol(2);
            end
            if ~isempty(obj.selType)
                val = val & obj.coordinates(:,3)==obj.selType;
            end
        end
        
        function obj = set.n_c(obj,val)
            % Check if value is correct
            if isa(val,'double') && val>0
                obj.n_c = val;
            else
                error('StatSTEMfile: n_c value not properly defined')
            end
        end
        
        function obj = set.optRefCoor(obj,val)
            % Check if input is correct
            if isa(val,'double') && length(val)==1 && max(val)<=1 && min(val)>=0
                obj.optRefCoor = val;
            elseif isa(val,'char')
                switch lower(val)
                    case 'same width'
                        obj.optRefCoor = 0;
                    case 'user defined'
                        obj.optRefCoor = 1;
                    otherwise
                        error('StatSTEMfile: widthtype must be equal to 1 or 2')
                end
            else
                error('StatSTEMfile: widthtype must be equal to 1 or 2')
            end
        end 
          
    end
end
        