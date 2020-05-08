classdef outputStatSTEM_MAP < StatSTEMfile
% outputStatSTEM_MAP - class to hold fitted parameters of different
% Gaussian models obtained for MAP
%
%   Advanced analysis options are defined for this class such as:
%
    
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
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
        N % Variable indicating the number of columns per fitted model
        M % Number of columns in the last fitted model (should be the maximum # columns)
    end
    
    properties (SetAccess=private)
        chi2 = 0.0; % Least squares sum of fitted models
        heds_tot = 0.0; % Determinant of Hessian matrix of fitted models
        etamin = 0.0; % Lower limit on intensity of a column
        beta_xmin = 0.0; % Lower limit on x-coordinate of a column
        beta_ymin = 0.0; % Lower limit on y-coordinate of a column
        etamax = 0.0; % Upper limit on intensity of a column
        beta_xmax = 0.0; % Upper limit on x-coordinate of a column
        beta_ymax = 0.0; % Upper limit on y-coordinate of a column
        rho_min = 0.0; % Lower limit on width of a column
        rho_max = 0.0; % Upper limit on width of a column
        zeta_min = 0.0; % Lower limit on background
        zeta_max = 0.0; % Upper limit on background
    end
    
    methods
        showMAPprob(obj)
        [output,outputMAP] = selNewModel(outputMAP,input);
        hfig = showModels(obj,input)
    end
    
    methods
        function obj = outputStatSTEM_MAP(output,dx,chi2,heds_tot,etamin,etamax,beta_xmin,beta_xmax,beta_ymin,beta_ymax,rho_min,rho_max,zeta_min,zeta_max)
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
            obj.heds_tot = heds_tot;
            obj.etamin = etamin;
            obj.etamax = etamax;
            obj.beta_xmin = beta_xmin;
            obj.beta_xmax = beta_xmax;
            obj.beta_ymin = beta_ymin;
            obj.beta_ymax = beta_ymax;
            obj.rho_min = rho_min;
            obj.rho_max = rho_max;
            obj.zeta_min = zeta_min;
            obj.zeta_max = zeta_max;
        end
        
        function obj = addModel(obj,output,chi2,heds_tot)
            if ~isa(output,'outputStatSTEM')
                error('Wrong input given, please give a outputStatTEM variable')
            end
            obj.models = [obj.models;{output}];
            obj.chi2 = [obj.chi2;chi2];
            obj.heds_tot = [obj.heds_tot;heds_tot];
        end
        
        function output = getSelModel(obj)
            output = obj.models{obj.NselMod};
        end
        
        function val = get.Nmodels(obj)
            val = length(obj.models);
        end
        
        function val = get.M(obj)
            modelN = obj.models{obj.Nmodels};
            val = length(modelN.coordinates(:,1));
        end
        
        function val = get.N(obj)
            val = zeros(obj.Nmodels,1);
            for i=1:obj.Nmodels
                val(i,1) = length(obj.models{i}.coordinates(:,1));
            end
        end
        
        function val = get.MAPprob(obj)
            u = obj.N;
            q = min(obj.chi2);
            v = obj.M;
            chi = (obj.chi2-q);

            t = zeros([1 obj.Nmodels]);
            for i = 1:obj.Nmodels
                t(i) = factorial(u(i)) / factorial(v) * (4*pi)^(1.5*(u(i)-v)) * exp(-0.5*(chi(i))) * ((obj.beta_xmax/obj.dx-obj.beta_xmin/obj.dx)*(obj.beta_ymax/obj.dx-obj.beta_ymin/obj.dx)*(obj.etamax-obj.etamin))^(v-u(i)) * (obj.heds_tot(obj.Nmodels)/obj.heds_tot(i));
            end
            p = t/max(t);
            val = log10(p);
        end
    end
end