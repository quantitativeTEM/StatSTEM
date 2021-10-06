function atomcounting = fitGMM(obj,minSel)
% fitGMM - fit a Gaussian mixture model to a data set
%
%   syntax: atomcounting = fitGMM(obj)
%       obj          - outputStatSTEM file
%       minSel       - selected minimum in ICL for automatic run (optional)
%       atomcounting - atomCountStat file
%
% See also: outputStatSTEM, atomCountStat

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2021, EMAT, University of Antwerp
% Authors: A. De Backer, K.H.W. van den Bos, A. De wael
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check matlab version (from 2017 switch from gmdistribution.fit to
% fitgmdist)
v = version('-release');
v = str2double(v(1:4));

estimatedDistributions = cell(1,obj.n_c);
mLogLik = zeros(1,obj.n_c);
[data,ind] = sort(obj.selVol);
coordinates = obj.selCoor(ind,:);

% Create structure for atomcounting
atomcounting = atomCountStat(coordinates,data,obj.dx,estimatedDistributions,mLogLik);

if isempty(obj.GUI)
    atomcounting.GUI = obj.GUI;
end

options = statset('MaxIter', 1000, 'TolTypeFun', 'rel', 'TolTypeX', 'rel','TolX', 1e-8, 'TolFun', 1e-8);
if ~isempty(obj.GUI)
    obj.waitbar.setValue(0)
else
    h_bar = waitbar(0,['Fitting (0/',num2str(obj.n_c),')']);
end
tic
n_c = obj.n_c;
for k = 1:n_c
    niter = 20;
    NlogL_best = 1e+50;
    sigmastart  = (max(data)-min(data))/(2*k);
    if k == 1
        mu_0 = (max(data) + min(data))/2;
    else
        mu_0 = min(data) + (0.5+(0:1:(k-1)).').*(max(data)-min(data))/k;
    end
    for iter = 1:niter % several random displacements as compared to mu_0 to avoid local minima
        mustart = mu_0 + ((max(data)-min(data))/(2*5)).*randn(k, 1);
        mustart = max(min(data), min(max(data), mustart)); % keeping the random starting values within the range of the data
        s = struct('mu', mustart, 'Sigma', sigmastart^2, 'Pcomponents', ones(k,1)/k);
        warning('off','all')
        if v<2017
            obj_s_iter = gmdistribution.fit(data,k,'Options', options, 'Start', s, 'Replicates', 1, 'CovType', 'full', 'SharedCov', true, 'Regularize', 0);
        else
            obj_s_iter = fitgmdist(data,k,'Options', options, 'Start', s, 'Replicates', 1, 'CovType', 'full', 'SharedCov', true, 'Regularize', 0);
        end
        warning('on','all')
        if obj_s_iter.NlogL < NlogL_best
            NlogL_best = obj_s_iter.NlogL;
            obj_best = obj_s_iter;
        end
        % For abort button in StatSTEM interface (if present)
        if ~isempty(obj.GUI)
            % For aborting function
            drawnow
            if get(obj.GUI,'Userdata')==0
                n_c = k-1;
                break
            end
        end
    
    end
    tic
    atomcounting.estimatedDistributions{1,k}.mu = obj_best.mu;
    atomcounting.estimatedDistributions{1,k}.Sigma = obj_best.Sigma;
    atomcounting.estimatedDistributions{1,k}.PComponents = obj_best.PComponents;
    atomcounting.mLogLik(1,k) = NlogL_best;
    
    % Calculate ICL and store it in atomcounting object (For speed)
    atomcounting = setICL(atomcounting,atomcounting.ICL);
    
    % Show ICL
    showICL(atomcounting)
    drawnow
    
    % Update waitbar
    if ~isempty(obj.GUI)
        obj.waitbar.setValue(k/n_c*100)
    else
        waitbar(k/n_c,h_bar,['Fitting (',num2str(k),'/',num2str(n_c),')'])
    end
    % For abort button in StatSTEM interface (if present)
    if ~isempty(obj.GUI)
        % For aborting function
        drawnow
        if get(obj.GUI,'Userdata')==0
            n_c = k-1;
            break
        end
    end
end
% Update waitbar
if ~isempty(obj.GUI)
    obj.waitbar.setValue(k/n_c*100)
else
    delete(h_bar)
end

% If function is aborted gather inputs that are calculated
atomcounting.estimatedDistributions = atomcounting.estimatedDistributions(1,1:n_c);
atomcounting.mLogLik = atomcounting.mLogLik(1,1:n_c);

% Select minimum in ICL curve
if nargin<2
    atomcounting = selICLmin(atomcounting);
else
    atomcounting.selMin = minSel;
end
