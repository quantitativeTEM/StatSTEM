classdef atomCountStat < atomCount
% atomCountStat - class to hold fitted parameters for statistical atomcounting
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
        volumes = []; % A (n x 1) vector that contains the volume of each atomic column
        offset = 0; % Offset in counting results
        estimatedDistributions = []; % The results of the Gaussian mixture model fitting for different components
        mLogLik = []; % The maximum log likelihood for the fitted results for different components
        selMin = []; % The selected minimum in the ICL
    end
    
    properties (Dependent)
        estimatedLocations % The locations of the Gaussian peak in the mixture model for the selected minimum
        estimatedWidth % The estimated width of the Gaussian peaks
        estimatedProportions % The estimated propertion of each Gaussian peak
        ICL % The ICL criterion
        x % X-location used for calculating the GMM components
        GMMcomp % The component of the gaussian mixture model
        GMM % The gaussian mixture model
    end
    
    properties (Dependent, Hidden)
        AIC % The AIC criterion
        GIC % The GIC criterion
        AWE % The AWE criterion
        BIC % The BIC criterion
        CLC % The CLC criterion
    end
    
    properties (SetAccess = private, Hidden)
        ICLp = [];% Hidden variable to store ICL
    end
    
    methods
        plotAtomCounts(atomcounting)
        plotGMM(obj)
        plotGMMcomp(obj)
        plotMinICL(obj)
        obj = selICLmin(obj)
        showICL(obj)
        showThickSI(obj)
        out = singleatomsensivity(atomcounting,sens)
    end
    
    methods
        function obj = atomCountStat(coordinates,volumes,dx,estimatedDistributions,mLogLik,selMin)
            obj.coordinates = coordinates;
            obj.volumes = volumes;
            obj.dx = dx;
            obj.estimatedDistributions = estimatedDistributions;
            obj.mLogLik = mLogLik;
            if nargin>=6
                obj.selMin = selMin;
            end
        end
        
        function val = get.estimatedLocations(obj)
            if isempty(obj.selMin)
                val = [];
            else
            	val = sort(obj.estimatedDistributions{1,obj.selMin}.mu);
            end
        end
        
        function val = get.estimatedWidth(obj)
            if isempty(obj.selMin)
                val = [];
            else
            	val = sqrt(obj.estimatedDistributions{1,obj.selMin}.Sigma);
            end
        end
        
        function val = get.estimatedProportions(obj)
            if isempty(obj.selMin)
                val = [];
            else
            	[~,ind] = sort(obj.estimatedDistributions{1,obj.selMin}.mu);
                prop = obj.estimatedDistributions{1,obj.selMin}.PComponents;
                val = prop(ind);
            end
        end
        
        function obj = set.selMin(obj,val)
            % Check if selected minimum exists
            if ~isempty(val)
                estDis = obj.estimatedDistributions;
                if ~isempty(estDis)
                    if val<1
                        val = 1;
                    elseif val>length(estDis)
                        val = length(estDis);
                    end
                else
                    val = [];
                end
            end
            obj.selMin = val;
        end
        
        function val = getCounts(obj)
            if isempty(obj.selMin)
                val = [];
                return
            end
            % assign number of atoms to each atom column
            probability = zeros(obj.selMin,1);
            N = obj.N;
            val = zeros(N,1);
            vol = obj.volumes;
            Loc = obj.estimatedLocations;
            Width = obj.estimatedWidth;
            Pcomp = obj.estimatedProportions;
            for i=1:N
                for j = 1:obj.selMin
                    probability(j) = Pcomp(j)*normaldistribution(vol(i),Loc(j),Width);
                end
                val(i) = find(probability == max(probability))+obj.offset;
            end
        end
        
        function val = get.ICL(obj)
            % ICL - the Integrated Classification Likelihood Criterion
            %
            % See also: Biernacki et al., Technical Report  3521, INRIA, Rhônes-Alpes, 1998.
            
            val = obj.ICLp;
            if length(val)==length(obj.estimatedDistributions)
                return
            end
            
            n_c = length(obj.estimatedDistributions);
            N = length(obj.volumes);
            crit = zeros(1,n_c);
            crit(1,1:length(val)) = val;
            for p=(length(val)+1):n_c
                % Check if inputs are present
                if isempty(obj.estimatedDistributions{1,p})
                    n_c=p-1;
                    break
                end

                % Gather inputs
                mu = obj.estimatedDistributions{1,p}.mu;
                var_eq = sqrt(obj.estimatedDistributions{1,p}.Sigma);
                P = obj.estimatedDistributions{1,p}.PComponents;
                mlog = obj.mLogLik(1,p);

                pP = zeros(N,p);
                for k = 1:p
                    pP(:,k) = normaldistribution(obj.volumes,mu(k),var_eq)*P(k);
                end
                E_w = pP./repmat(sum(pP,2),1,p);
                Ew = E_w(:);
                index=find(ne(log(Ew),-Inf));
                som=0;
                for j=1:length(index)
                    som = som + sum(sum(Ew(index(j)).*log(Ew(index(j)))));
                end
                crit(1,p) = 2*mlog - 2*som + p*2*log(N);
            end
            val = crit(1,1:n_c);
        end
        
        function val = get.AIC(obj)
            % AIC - the Akaike's Information Criterion
            %
            % See also: Akaike, IEEE Transactions on Automatic Control 19 (9) p.716
            n_c = length(obj.estimatedDistributions);
            crit = zeros(1,n_c);
            for p=1:n_c
                % Check if inputs are present
                if isempty(obj.estimatedDistributions{1,p})
                    n_c=p-1;
                    break
                end
                mlog = obj.mLogLik(1,p);
                crit(1,p) = 2*mlog+2*2*p;
            end
            val = crit(1,1:n_c);
        end
        
        function val = get.AWE(obj)
            % AWE_crit - the Approximate Weight of Evidence criterion
            %
            % See also: Banfield and Raftery, Biometrics 49, p. 803
            N = length(obj.volumes);
            CLC = obj.CLC;
            n_c = length(CLC);
            val = zeros(1,n_c);
            for p=1:n_c
                val(1,p) = CLC(1,p) + 2*2*p*(3/2+log(N));
            end
        end
        
        function val = get.BIC(obj)
            % BIC - The Bayesian Information Criterion
            %
            % See also: Schwarz, Annals of Statistics 6 (2), p. 461
            n_c = length(obj.estimatedDistributions);
            N = length(obj.volumes);
            crit = zeros(1,n_c);
            for p=1:n_c
                % Check if inputs are present
                if isempty(obj.estimatedDistributions{1,p})
                    n_c=p-1;
                    break
                end
                mlog = obj.mLogLik(1,p);
                crit(1,p) = 2*mlog+2*p*log(N);
            end
            val = crit(1,1:n_c);
        end
        
        function val = get.CLC(obj)
            % CLC_crit - Classification Likelihood Information Criterion
            %
            % See also: Biernacki and Govaert, Computing Science and Statistics 29 p. 451
            n_c = length(obj.estimatedDistributions);
            N = length(obj.volumes);
            crit = zeros(1,n_c);
            for p=1:n_c
                % Check if inputs are present
                if isempty(obj.estimatedDistributions{1,p})
                    n_c=p-1;
                    break
                end
                
                % Gather inputs
                mu = obj.estimatedDistributions{1,p}.mu;
                var_eq = sqrt(obj.estimatedDistributions{1,p}.Sigma);
                P = obj.estimatedDistributions{1,p}.PComponents;
                mlog = obj.mLogLik(1,p);
                
                pP = zeros(N,p);
                for n = 1:N
                    for k = 1:p
                        pP(n,k) = normaldistribution(obj.volumes(n),mu(k),var_eq)*P(k);
                    end
                end
                E_w = pP./repmat(sum(pP,2),1,p);
                Ew = E_w(:);
                index=find(ne(log(Ew),-Inf));
                som=0;
                for j=1:length(index)
                    som = som + sum(sum(Ew(index(j)).*log(Ew(index(j)))));
                end
                crit(1,p) = 2*mlog - 2*som;
            end
            val = crit(1,1:n_c);
        end
        
        function val = get.GIC(obj)
            % GIC - variation on AIC criterion, GIC Generalised Information Criterion
            %
            % See also: Broersen and Wensink, IEEE Transactions on Signal Processing 41 (1) p. 194
            n_c = length(obj.estimatedDistributions);
            crit = zeros(1,n_c);
            for p=1:n_c
                % Check if inputs are present
                if isempty(obj.estimatedDistributions{1,p})
                    n_c=p-1;
                    break
                end
                mlog = obj.mLogLik(1,p);
                crit(1,p) = 2*mlog+3*2*p;
            end
            val = crit(1,1:n_c);
        end
        
        function val = get.x(obj)
            val = linspace(0,max(obj.volumes)*1.05,1000);
        end
        
        function val = get.GMMcomp(obj)
            % Calculate the values of the different GMM components
            val = zeros(obj.selMin, length(obj.x));
            bins = getNBins(obj.volumes);
            Loc = obj.estimatedLocations;
            Width = obj.estimatedWidth;
            Pcomp = obj.estimatedProportions;
            x = obj.x;
            for i = 1:obj.selMin
               val(i,:) = normaldistribution(x,Loc(i),Width)*Pcomp(i)*obj.N*(max(obj.volumes)-min(obj.volumes))/bins;
            end
        end
        
        function val = get.GMM(obj)
            % Calculate the value of the final GMM (all components together)
            val = sum(obj.GMMcomp,1);
        end
        
        function val = getGMM(obj,x)
            % Calculate the values of the different GMM components
            val = zeros(obj.selMin, length(x));
            Loc = obj.estimatedLocations;
            Width = obj.estimatedWidth;
            Pcomp = obj.estimatedProportions;
            for i = 1:obj.selMin
               val(i,:) = normaldistribution(x,Loc(i),Width)*Pcomp(i);
            end
            val = sum(val);
        end
        
        function obj = setICL(obj,val)
            % Give ICL values to object
            obj.ICLp = val;
        end
    end
end