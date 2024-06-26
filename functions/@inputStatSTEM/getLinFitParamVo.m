function output = getLinFitParamVo(input,rho,ratioGL,coordinates)
% getLinFitParamVo - find linear parameter from fitted non-linear parameters
%
%   syntax: output = getLinFitParamVo(input,rho,coordinates)
%       input       - inputStatSTEM structure
%       rho         - A (Nx1)-vector containing the width for each column
%       ratioGL     - ratio between the Gaussian and Lorentzian
%       coordinates - New column coordinates (optional)
%       output      - outputStatSTEM structure
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos, A. De Backer
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Use new coordinates if given
if nargin>=3
    input.coordinates(:,1:2) = coordinates;
end

parWork = 1;
% Don't use parpool at this moment if not yet created (takes time to start)
if input.numWorkers ~= 1
    if ~isempty(gcp('nocreate'))
        parWork = input.numWorkers;
        input = devideIndices(input);
    end
end

KL =input.K*input.L;
N = input.n_c;
Z = double(input.fitZeta);
px_p_col = ceil(((max(rho)*6))/input.dx)^2;
Vo = spalloc(KL, N+Z, px_p_col*N + Z*KL);
% Ga = sparse(input.K*input.L,input.n_c+double(input.fitZeta));
if parWork == 1
    indCol = (1:input.n_c)';
    Vo(:,indCol) = getVo(input.K,input.L,input.indMat,rho,ratioGL,input.dx,input.coordinates(:,1),input.coordinates(:,2),input.Xreshape,input.Yreshape,indCol);
    if ~isempty(input.GUI)
        % For aborting function
        drawnow
        if get(input.GUI,'Userdata')==0
            error('Error: function stopped by user')
        end
    end
    thetalin = getLinearPar(Vo,input.reshapeobs,KL,input.fitZeta,input.zeta);
    clear Vo
else
    job = cell(input.numWorkers,1);
    for n=1:input.numWorkers
        job{n} = parfeval(@getVo,1,input.K,input.L,input.indMat,rho,ratioGL,input.dx,input.coordinates(:,1),input.coordinates(:,2),input.Xreshape,input.Yreshape,input.indAllWorkers{n,1});
    end
    for n=1:input.numWorkers
        if ~isempty(input.GUI)
            % For aborting function
            drawnow
        end
        Vo(:,input.indAllWorkers{n,1}) = fetchOutputs(job{n});
    end
    clear job
    job = parfeval(@getLinearPar,1,Vo,input.reshapeobs,KL,input.fitZeta,input.zeta);
    if ~isempty(input.GUI)
        % For aborting function
        drawnow
        if get(input.GUI,'Userdata')==0
            error('Error: function stopped by user')
        end
    end
    thetalin = fetchOutputs(job);
    clear job Vo
end

if input.fitZeta
    eta = thetalin(1:end-1);
    zeta = thetalin(end);
else
    eta = thetalin;
    zeta = input.zeta;
end

% Create outputStatSTEMstructure
output = outputStatSTEM(input.coordinates,rho,eta,zeta,input.dx,input.peakShape,ratioGL);
output.types = input.types;