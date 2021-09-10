function output = getLinFitParam(input,rho,coordinates)
% getLinFitParam - find linear parameter from fitted non-linear parameters
%
%   syntax: output = getLinFitParam(input,rho,coordinates)
%       input       - inputStatSTEM structure
%       rho         - A (Nx1)-vector containing the width for each column
%       coordinates - New column coordinates (optional)
%       output      - outputStatSTEM structure
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
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

% Get linear parameters, if necessary
indCol = (1:input.n_c)';
Ga = sparse(input.K*input.L,input.n_c+double(input.fitZeta));
if parWork == 1
    Ga(:,indCol) = getGa(input.K,input.L,input.indMat,rho,input.dx,input.coordinates(:,1),input.coordinates(:,2),input.Xreshape,input.Yreshape,indCol);
    if ~isempty(input.GUI)
        % For aborting function
        drawnow
        if get(input.GUI,'Userdata')==0
            error('Error: function stopped by user')
        end
    end
    thetalin = getLinearPar(Ga,input.reshapeobs,input.K*input.L,input.fitZeta,input.zeta);
    clear Ga
else
    job = cell(input.numWorkers,1);
    for n=1:input.numWorkers
        job{n} = parfeval(@getGa,1,input.K,input.L,input.indMat,rho,input.dx,input.coordinates(:,1),input.coordinates(:,2),input.Xreshape,input.Yreshape,input.indAllWorkers{n,1});
    end
    for n=1:input.numWorkers
        if ~isempty(input.GUI)
            % For aborting function
            drawnow
        end
        Ga(:,input.indAllWorkers{n,1}) = fetchOutputs(job{n});
    end
    clear job
    job = parfeval(@getLinearPar,1,Ga,input.reshapeobs,input.K*input.L,input.fitZeta,input.zeta);
    if ~isempty(input.GUI)
        % For aborting function
        drawnow
        if get(input.GUI,'Userdata')==0
            error('Error: function stopped by user')
        end
    end
    thetalin = fetchOutputs(job);
    clear job Ga
end

if input.fitZeta
    eta = thetalin(1:end-1);
    zeta = thetalin(end);
else
    eta = thetalin;
    zeta = input.zeta;
end

% Create outputStatSTEMstructure
output = outputStatSTEM(input.coordinates,rho,eta,zeta,input.dx);
output.types = input.types;