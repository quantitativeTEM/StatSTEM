function [output,abort] = getFitParam(output,input,FP)
% getFitParam - construct a model from the fitted parameters
%
%   syntax: [output,abort] = getFitParam(output,input,FP)
%       output - structure containing the output structure
%       input  - input structure
%       FP     - structure containing the fitting options
%       abort  - number indicating if fitting procedure is cancelled
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

abort = 0;
max_n = 70-6*FP.numWorkers;
tic
% Get linear parameters, if necessary
if ~any(isfield(output,'eta'))
    Ga = sparse(FP.K*FP.L,FP.n_c+FP.fitzeta);
    if FP.numWorkers == 1
        Ga(:,FP.indAllWorkers{1,1}) = getGa(FP.K,FP.L,max_n,FP.indMat,output.rho,input.dx,output.coordinates(:,1),output.coordinates(:,2),FP.Xreshape,FP.Yreshape,FP.indAllWorkers{1,1});
        if FP.GUI
            % For abort button
            if toc>1
                pause(0.02);
                tic;
            end
            if ~FP.abortButton.isEnabled
                abort = 1;
                output = 0;
                return
            end
        end
        thetalin = getLinearPar(Ga,FP.reshapeobs,FP.K*FP.L,FP.fitzeta,FP.zeta);
        clear Ga
    else
        job = cell(FP.numWorkers,1);
        for n=1:FP.numWorkers
            job{n} = parfeval(@getGa,1,FP.K,FP.L,max_n,FP.indMat,output.rho,input.dx,output.coordinates(:,1),output.coordinates(:,2),FP.Xreshape,FP.Yreshape,FP.indAllWorkers{n,1});
        end
        for n=1:FP.numWorkers
            if FP.GUI
                % For abort button
                if toc>1
                    pause(0.02);
                    tic;
                end
                if ~FP.abortButton.isEnabled
                    abort = 1;
                    output = 0;
                    return
                end
            end
            Ga(:,FP.indAllWorkers{n,1}) = fetchOutputs(job{n});
        end
        clear job
        job = parfeval(@getLinearPar,1,Ga,FP.reshapeobs,FP.K*FP.L,FP.fitzeta,FP.zeta);
        if FP.GUI
            % For abort button
            if toc>1
                pause(0.02);
                tic;
            end
            if ~FP.abortButton.isEnabled
                abort = 1;
                output = 0;
                return
            end
        end
        thetalin = fetchOutputs(job);
        clear job Ga
    end
    
    if FP.fitzeta
        output.eta = thetalin(1:end-1);
        output.zeta = thetalin(end);
    else
        output.eta = thetalin;
        output.zeta = FP.zeta;
    end
end

% Get model
if FP. numWorkers == 1
    combined_model = combinedGauss(output.coordinates(FP.indAllWorkers{1,1},1), output.coordinates(FP.indAllWorkers{1,1},2), output.rho(FP.indAllWorkers{1,1}), output.eta(FP.indAllWorkers{1,1}),FP.Xreshape,FP.Yreshape,FP.indMat,input.dx,FP.K,FP.L,max_n);
else
    job = cell(4,1);
    for n=1:FP.numWorkers
        job{n,1} = parfeval(@combinedGauss,1,output.coordinates(FP.indAllWorkers{n,1},1), output.coordinates(FP.indAllWorkers{n,1},2), output.rho(FP.indAllWorkers{n,1}), output.eta(FP.indAllWorkers{n,1}),FP.Xreshape,FP.Yreshape,FP.indMat,input.dx,FP.K,FP.L,max_n);
    end
    combined_model = sparse(FP.K*FP.L,1);
    for n=1:FP.numWorkers
        combined_model = combined_model + fetchOutputs(job{n,1});
    end
end
output.model = reshape(combined_model, FP.L,FP.K) + output.zeta;
output.volumes = 2*pi*output.eta.*output.rho.^2;
temp = (output.model - input.obs).^2;
output.lsq = sum(temp(:));