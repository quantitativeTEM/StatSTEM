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
% Copyright: 2018, EMAT, University of Antwerp
% Authors: A. De Backer, K.H.W. van den Bos
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
    obj_s = cell(1,k);
    if k == 1
        mustart = (max(data) - min(data))/2;
        sigmastart  = (max(data)-min(data))/(2*k);
        s = struct('mu', mustart', 'Sigma', sigmastart^2, 'Pcomponents', ones(k,1)/k);
        warning('off','all')
        if v<2017
            obj_s{k} = gmdistribution.fit(data,k,'Options', options, 'Start', s, 'Replicates', 1, 'CovType', 'diagonal', 'SharedCov', true, 'Regularize', 0);
        else
            obj_s{k} = fitgmdist(data,k,'Options', options, 'Start', s, 'Replicates', 1, 'CovType', 'diagonal', 'SharedCov', true, 'Regularize', 0);
        end
        warning('on','all')
        NlogL_s = obj_s{k}.NlogL;
        % For abort button in StatSTEM interface (if present)
        if ~isempty(obj.GUI)
            % For aborting function
            drawnow
            if get(obj.GUI,'Userdata')==0
                n_c = k-1;
                break
            end
        end
    else
        NlogL_s = zeros(1,k);
        for i = 1:k
            sortmu = sort(atomcounting.estimatedDistributions{1,k-1}.mu);
            if i == 1
                mustartextra = (sortmu(1) - min(data))/2;
            elseif i == k
                mustartextra = (max(data) - sortmu(k-1))/2 + sortmu(k-1);
            else
                mustartextra = (sortmu(i) - sortmu(i-1))/2 + sortmu(i-1);
            end

            s = struct('mu', [atomcounting.estimatedDistributions{1,k-1}.mu' mustartextra]', 'Sigma', atomcounting.estimatedDistributions{k-1}.Sigma, 'Pcomponents', ones(k,1)/k);
            warning('off','all')
            if v<2017
                obj_s{i} = gmdistribution.fit(data,k,'Options', options, 'Start', s, 'Replicates', 1, 'CovType', 'diagonal', 'SharedCov', true, 'Regularize', 0);
            else
                obj_s{i} = fitgmdist(data,k,'Options', options, 'Start', s, 'Replicates', 1, 'CovType', 'diagonal', 'SharedCov', true, 'Regularize', 0);
            end
            warning('on','all')
            NlogL_s(i) = obj_s{i}.NlogL;
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
    end
    tic
    best = find(NlogL_s == min(NlogL_s),1);
    atomcounting.estimatedDistributions{1,k}.mu = obj_s{best}.mu;
    atomcounting.estimatedDistributions{1,k}.Sigma = obj_s{best}.Sigma;
    atomcounting.estimatedDistributions{1,k}.PComponents = obj_s{best}.PComponents;
    atomcounting.mLogLik(1,k) = NlogL_s(best);
    
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
