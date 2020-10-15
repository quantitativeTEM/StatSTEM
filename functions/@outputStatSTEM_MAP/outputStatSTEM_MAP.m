classdef outputStatSTEM_MAP < StatSTEMfile
% outputStatSTEM_MAP - class to hold fitted parameters of different
% Gaussian models obtained from the MAP probability rule
    
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
    
    properties
        models = {}; % Cell structure containing outputStatSTEM files
        NselMod = 1; % Selected model
    end
    
    properties (Dependent)
        Nmodels % Number of fitted models
        MAPprob % MAP probability of the fitted models
        N % Vector indicating the number of columns per fitted model
        M % Number of columns in the last fitted model
    end
    
    properties (SetAccess=private)
        chi2 = 0.0; % Least squares sum of fitted models
        det_hes = 0.0; % Determinant of Hessian matrix of fitted models
        zetamin = 0.0; % Lower limit on background in pixel intensities
        zetamax = 0.0; % Upper limit on background in pixel intensities
        rhomin = 0.0; % Lower limit on width of a column in A
        rhomax = 0.0; % Upper limit on width of a column in A
        etamin = 0.0; % Lower limit on intensity of a column in pixel intensities
        etamax = 0.0; % Upper limit on intensity of a column in pixel intensities
        beta_xmin = 0.0; % Lower limit on x-coordinate of a column in A
        beta_xmax = 0.0; % Upper limit on x-coordinate of a column in A
        beta_ymin = 0.0; % Lower limit on y-coordinate of a column in A
        beta_ymax = 0.0; % Upper limit on y-coordinate of a column in A
    end
    
    methods
        showMAPprob_update(obj,input)
        showMAPprob(obj)
        [output,outputMAP] = selNewModel(outputMAP,input);
        hfig = showModels(obj,input)
    end
    
    methods
        function obj = outputStatSTEM_MAP(output,dx,chi2,det_hes,etamin,etamax,beta_xmin,beta_xmax,beta_ymin,beta_ymax,rho_min,rho_max,zeta_min,zeta_max)
            if isa(output,'outputStatSTEM')
                obj.models = {output};
            elseif isa(output,'cell')
                if isa(output{1},'outputStatSTEM')
                    obj.models = output;
                else
                    error('Wrong input given, please give a outputStatTEM variable')
                end
            else
                error('Wrong input given, please give a outputStatTEM variable')
            end
            obj.dx = dx;
            obj.chi2 = chi2;
            obj.det_hes = det_hes;
            obj.etamin = etamin;
            obj.etamax = etamax;
            obj.beta_xmin = beta_xmin;
            obj.beta_xmax = beta_xmax;
            obj.beta_ymin = beta_ymin;
            obj.beta_ymax = beta_ymax;
            obj.rhomin = rho_min;
            obj.rhomax = rho_max;
            obj.zetamin = zeta_min;
            obj.zetamax = zeta_max;
        end
        
        function obj = addModel(obj,output,chi2,det_hes)
            if ~isa(output,'outputStatSTEM')
                error('Wrong input given, please give a outputStatTEM variable')
            end
            obj.models = [obj.models;{output}];
            obj.chi2 = [obj.chi2;chi2];
            obj.det_hes = [obj.det_hes;det_hes];
        end
        
        function output = getSelModel(obj)
            output = obj.models{obj.NselMod};
        end
        
        function val = get.Nmodels(obj)
            val = length(obj.models);
        end
        
        function val = get.M(obj)
            modelN = obj.models{obj.Nmodels};
            if isempty(modelN.coordinates)
                val = 0;
            else
                val = length(modelN.coordinates(:,1));
            end
        end
        
        function val = get.N(obj)
            val = zeros(obj.Nmodels,1);
            for i=1:obj.Nmodels
                if isempty(obj.models{i}.coordinates)
                    val(i,1) = 0;
                else
                    val(i,1) = length(obj.models{i}.coordinates(:,1));
                end
            end
        end
        
        function val = get.MAPprob(obj)
            chi2_diff = obj.chi2-obj.chi2(end);
            t = zeros(1,obj.Nmodels);
            for mm = obj.N(1):obj.M
                if mm == 0
                    t(mm+1) = factorial(mm) / factorial(obj.N(end)) * (4*pi)^(-0.5*(1+3*obj.M)) * exp(-0.5*(chi2_diff(mm+1)))...
                * ((obj.beta_xmax/obj.dx-obj.beta_xmin/obj.dx)*(obj.beta_ymax/obj.dx-obj.beta_ymin/obj.dx)*(obj.etamax-obj.etamin))^obj.M*(obj.rhomax/obj.dx-obj.rhomin/obj.dx)...
                * sqrt(obj.det_hes(end)/obj.det_hes(mm+1));
                else
                t(mm+1-obj.N(1)) = factorial(mm) / factorial(obj.M) * (4*pi)^(1.5*(mm-obj.M)) * exp(-0.5*(chi2_diff(mm+1-obj.N(1))))...
                * ((obj.beta_xmax/obj.dx-obj.beta_xmin/obj.dx)*(obj.beta_ymax/obj.dx-obj.beta_ymin/obj.dx)*(obj.etamax-obj.etamin))^(obj.M-mm)...
                * sqrt(obj.det_hes(end)/obj.det_hes(mm+1-obj.N(1)));
                end
            end
            p = t/max(t); % normalize t to obtain p: contains relative probabilities
            val = log10(p); % define on logscale: map
            val = real(val);
        end
    end
end