function [atomcounting,abort] = fitGMM(ax,atomcounting,n_c,h_bar,abortBut)
% fitGMM - fit a Gaussian mixture model to a data set
%
%   syntax: [atomcounting,abort] = fitGMM(ax,atomcounting,n_c,h_bar,abortBut)
%       ax           - axes to show the ICL criterion
%       atomcounting - structure containing atom counting results
%       n_c          - maximum number of components to be fitted
%       h_bar        - reference to progressbar (optional)
%       abortBut     - reference to abort button (optional)
%       abort        - boolean, indicating if fitting went well
%
% See also: ICL_crit

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

abort = 0;
if nargin<5
    abortBut.isEnabled = 1;
end

atomcounting.estimatedDistributions = cell(1,n_c);
atomcounting.mLogLik = zeros(1,n_c);
atomcounting.ICL  = zeros(1,n_c);
% atomcounting.AIC  = zeros(1,n_c);
% atomcounting.GIC  = zeros(1,n_c);
% atomcounting.AWE  = zeros(1,n_c);
% atomcounting.BIC  = zeros(1,n_c);
% atomcounting.CLC  = zeros(1,n_c);
data = sort(atomcounting.volumes);

options = statset('MaxIter', 1000, 'TolTypeFun', 'rel', 'TolTypeX', 'rel','TolX', 1e-8, 'TolFun', 1e-8);
if nargin>3
    h_bar.setValue(0);
else
    h_bar = waitbar(0,['Fitting (0/',num2str(n_c),')']);
end
tic
for k = 1:n_c
    if k == 1
        mustart = (max(data) - min(data))/2;
        sigmastart  = (max(data)-min(data))/(2*k);
        s = struct('mu', mustart', 'Sigma', sigmastart^2, 'Pcomponents', ones(k,1)/k);
        obj_s{k} = gmdistribution.fit(data,k,'Options', options, 'Start', s, 'Replicates', 1, 'CovType', 'full', 'SharedCov', true, 'Regularize', 0);
        NlogL_s = obj_s{k}.NlogL;
        % For abort button
        if toc>1
            pause(0.02);
            tic;
        end
        if ~abortBut.isEnabled
            n_c = k-1;
            break
        end
    else
        obj_s = cell(1,k);
        NlogL_s = zeros(1,k);
        try
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
                obj_s{i} = gmdistribution.fit(data,k,'Options', options, 'Start', s, 'Replicates', 1, 'CovType', 'full', 'SharedCov', true, 'Regularize', 0);
                NlogL_s(i) = obj_s{i}.NlogL;
                % For abort button
                if toc>1
                    pause(0.02);
                    tic;
                end
                if ~abortBut.isEnabled
                    n_c = k-1;
                    break
                end
            end
        catch
            n_c = k-1;
            abort = 2;
            atomcounting.estimatedDistributions = atomcounting.estimatedDistributions(1,1:n_c);
            atomcounting.mLogLik = atomcounting.mLogLik(1,1:n_c);
            atomcounting.ICL  = atomcounting.ICL(1,1:n_c);
            break
        end
    end
    if ~abortBut.isEnabled
        n_c = k-1;
        break
    end
    best = find(NlogL_s == min(NlogL_s),1);
    atomcounting.estimatedDistributions{1,k}.mu = obj_s{best}.mu;
    atomcounting.estimatedDistributions{1,k}.Sigma = obj_s{best}.Sigma;
    atomcounting.estimatedDistributions{1,k}.PComponents = obj_s{best}.PComponents;
    atomcounting.mLogLik(1,k) = NlogL_s(best);

    % Evaluate selection criterion
    atomcounting.ICL(1,k)  = ICL_crit(atomcounting.mLogLik(1,k), data, atomcounting.estimatedDistributions{1,k}.mu, atomcounting.estimatedDistributions{1,k}.PComponents, sqrt(atomcounting.estimatedDistributions{1,k}.Sigma), length(data), 2*k);
%     atomcounting.AIC(1,k)  = AIC_crit(atomcounting.mLogLik(1,k), 2*k);
%     atomcounting.GIC(1,k)  = AIC_Delft_crit(atomcounting.mLogLik(1,k), 2*k);
%     atomcounting.AWE(1,k)  = AWE_crit(atomcounting.mLogLik(1,k), data, atomcounting.estimatedDistributions{1,k}.mu, atomcounting.estimatedDistributions{1,k}.PComponents, sqrt(atomcounting.estimatedDistributions{1,k}.Sigma), length(data), 2*k);
%     atomcounting.BIC(1,k)  = BIC_crit(atomcounting.mLogLik(1,k), 2*k, length(data));
%     atomcounting.CLC(1,k)  = CLC_crit(atomcounting.mLogLik(1,k), data, atomcounting.estimatedDistributions{1,k}.mu, atomcounting.estimatedDistributions{1,k}.PComponents, sqrt(atomcounting.estimatedDistributions{1,k}.Sigma), length(data), k);
    
    % Show ICL
    showICL(ax,atomcounting.ICL(1,1:k))
    drawnow

    % Update waitbar
    if nargin>3
        h_bar.setValue(k/n_c*100);
    else
        waitbar(k/n_c,h_bar,['Fitting (',num2str(k),'/',num2str(n_c),')'])
    end
    if ~abortBut.isEnabled
        n_c = k-1;
        break
    end
end
% Update waitbar
if nargin>3
    h_bar.setValue(100);
else
    delete(h_bar)
end

% Check if abort button is pressed
if ~abortBut.isEnabled
    abort = 1;
    atomcounting.estimatedDistributions = atomcounting.estimatedDistributions(1,1:n_c);
    atomcounting.mLogLik = atomcounting.mLogLik(1,1:n_c);
    atomcounting.ICL  = atomcounting.ICL(1,1:n_c);
%     atomcounting.AIC  = atomcounting.AIC(1,1:n_c);
%     atomcounting.GIC  = atomcounting.GIC(1,1:n_c);
%     atomcounting.AWE  = atomcounting.AWE(1,1:n_c);
%     atomcounting.BIC  = atomcounting.BIC(1,1:n_c);
%     atomcounting.CLC  = atomcounting.CLC(1,1:n_c);
end
