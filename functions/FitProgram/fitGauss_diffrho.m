function [output,abort] = fitGauss_diffrho(input,FP,offset)
% fitGauss_diffrho - program to fit gaussian peaks having a different width
%                    to a STEM image
%
%   In this method, each individual peak is cut out of the original image.
%   Next, the image contrubutions of the neighbouring atoms are subtracted.
%   Than, a gaussian peak is fitted (coordinates and width). The width of
%   the gaussian peak differs for each column.
%
%   syntax: [output,abort] = fitGauss_diffrho(input,FP,offset)
%       input  - input structure
%       FP     - structure containing the fitting options
%       offset - offset value for progressbar (optional)
%       output - structure containing the output structure
%       abort  - number indicating if fitting procedure is cancelled
%
% See also: fitGauss

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

tic;

% Refine size of box per atom type, start from original
if size(input.coordinates,2)==2
    input.coordinates(:,3) = ones(size(input.coordinates,1),1);
end
if nargin<3
    % For progressbar GUI
    offset = 0;
end

%% specifications fitting
radius = FP.dist*2.5;           % radius around position of a single atom column taking into account the contributions of neighbouring gaussians
TolX = 1e-4;                    % tolerance on estimated parameters
alfa = 0.5;                     % parameter to define change in parameters every iteration
abort = 0;

%% define matrices
Estimated_BetaX = input.coordinates(:,1);
Estimated_BetaY = input.coordinates(:,2);
Estimated_rho = FP.rho;
rho_estimatedbackground = FP.rho;

betaX_estimatedbackground = input.coordinates(:,1);
betaY_estimatedbackground = input.coordinates(:,2);
type = input.coordinates(:,3);

% Recalculate size of boxes used to cut out parts of the original image
% size/2 of the box selected around the position of an atom column position in pixels 
Box = round(FP.dist/input.dx/2)*ones(max(type),1); %calcBoxSize(FP.obs_bs,input.coordinates,input.dx);

%% startmodel
reshape_obs_bs = reshape(input.obs,FP.K*FP.L,1);
Ga = sparse(FP.K*FP.L,FP.n_c+FP.fitzeta);
% Ga2 = sparse(FP.K*FP.L,FP.n_c+FP.fitzeta);
job = cell(FP.numWorkers,1);
max_n = 70-6*FP.numWorkers;
if FP.numWorkers==1
    Ga(:,FP.indAllWorkers{1,1}) = getGa(FP.K,FP.L,max_n,FP.indMat,Estimated_rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{1,1});
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
    thetalin = getLinearPar(Ga,reshape_obs_bs,FP.K*FP.L,FP.fitzeta,FP.zeta);
    clear Ga
else
    for n=1:FP.numWorkers
    %     Ga(:,FP.indAllWorkers{n,1}) = getGa(FP.K,FP.L,max_n,FP.indMat,Estimated_rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{n,1});
    %     Ga2 = getGa(FP.K,FP.L,max_n,FP.indMat,Estimated_rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,[FP.indAllWorkers{n,1};FP.indAllWorkers{n+1,1};FP.indAllWorkers{n+2,1};FP.indAllWorkers{n+3,1}]);
    %     Ga2(:,FP.indAllWorkers{n,1}) = getGa(FP.K,FP.L,max_n,FP.indMat,Estimated_rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{n,1});
        job{n} = parfeval(@getGa,1,FP.K,FP.L,max_n,FP.indMat,Estimated_rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{n,1});
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
    job = parfeval(@getLinearPar,1,Ga,reshape_obs_bs,FP.K*FP.L,FP.fitzeta,FP.zeta);
    thetalin = fetchOutputs(job);
    clear job Ga Ga2
end
if FP.fitzeta
    Estimated_eta = thetalin(1:end-1);
    Estimated_zeta = thetalin(end);
else
    Estimated_eta = thetalin;
    Estimated_zeta = FP.zeta;
end
obs_bs = input.obs - Estimated_zeta;
eta_estimatedbackground = Estimated_eta;

%% options for lsqnonlin
options = optimset('lsqnonlin');
options.Jacobian = 'on';
options.DerivativeCheck = 'off';
options.Display = 'off';
options.Largescale = 'on';
options.Algorithm = 'trust-region-reflective';
options.TolX = 1e-4;
options.TolFun = eps;

%% Start iterations
if FP.GUI==0 && FP.cluster==0 && FP.silent==0
    h = waitbar(0,'','Name','Iterating...');
end
colConv = 0;
progress = 0;
for j_iter = 1:FP.maxIter % maximum number of iterations for convergence
    % Report current estimate in the waitbar's message field
    progress = max(progress,(j_iter-1)/FP.maxIter);
    if FP.GUI
        FP.waitbar.setValue(offset + progress*(100-offset))
    else
        if FP.silent==0
            formatSpec = 'Step %d, progress %d%%';
            if FP.cluster
                fprintf([formatSpec,' \n'],j_iter,round(progress*99))
            else
                waitbar((progress*99)/100,h, sprintf(formatSpec,j_iter,round(progress*99)))
            end
        end
    end
    
    % Save old values, use alfa to ensure convergence
    Estimated_rho_old = Estimated_rho;
    Estimated_BetaX_old = Estimated_BetaX;
    Estimated_BetaY_old = Estimated_BetaY;
    rho_estimatedbackground = rho_estimatedbackground + (Estimated_rho - rho_estimatedbackground)*alfa;
    betaX_estimatedbackground = betaX_estimatedbackground + (Estimated_BetaX - betaX_estimatedbackground)*alfa;
    betaY_estimatedbackground = betaY_estimatedbackground + (Estimated_BetaY - betaY_estimatedbackground)*alfa;
    eta_estimatedbackground = eta_estimatedbackground + (Estimated_eta - eta_estimatedbackground)*alfa;
    
    % Fit new column positions
    if FP.numWorkers == 1
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
        EstimatedParametersnonlin = fitAtomNonLinear(obs_bs,FP.X,FP.Y,Box,input.coordinates(:,1),input.coordinates(:,2),type,betaX_estimatedbackground,betaY_estimatedbackground,rho_estimatedbackground,eta_estimatedbackground,input.dx,radius,options,FP.indWorkers{1,1});
        Estimated_BetaX(FP.indWorkers{1,1}) = EstimatedParametersnonlin(1,:);
        Estimated_BetaY(FP.indWorkers{1,1}) = EstimatedParametersnonlin(2,:);
        Estimated_rho(FP.indWorkers{1,1}) = EstimatedParametersnonlin(3,:);
    else
        job = cell(FP.numWorkers,1);
        for i = 1:FP.numWorkers   % number of workers that will be used
            job{i} = parfeval(@fitAtomNonLinear,1,obs_bs,FP.X,FP.Y,Box,input.coordinates(:,1),input.coordinates(:,2),type,betaX_estimatedbackground,betaY_estimatedbackground,rho_estimatedbackground,eta_estimatedbackground,input.dx,radius,options,FP.indWorkers{i,1});
        end
        for i = 1:FP.numWorkers
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
            EstimatedParametersnonlin = fetchOutputs(job{i});
            Estimated_BetaX(FP.indWorkers{i,1}) = EstimatedParametersnonlin(1,:);
            Estimated_BetaY(FP.indWorkers{i,1}) = EstimatedParametersnonlin(2,:);
            Estimated_rho(FP.indWorkers{i,1}) = EstimatedParametersnonlin(3,:);
        end
        clear job
    end
    
    % Get linear parameters
    Ga = sparse(FP.K*FP.L,FP.n_c+FP.fitzeta);
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
    if FP.numWorkers == 1
        Ga(:,FP.indAllWorkers{1,1}) = getGa(FP.K,FP.L,max_n,FP.indMat,Estimated_rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{1,1});
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
        thetalin = getLinearPar(Ga,reshape_obs_bs,FP.K*FP.L,FP.fitzeta,FP.zeta);
        clear Ga
    else
        job = cell(FP.numWorkers,1);
        for n=1:FP.numWorkers
            job{n} = parfeval(@getGa,1,FP.K,FP.L,max_n,FP.indMat,Estimated_rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{n,1});
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
        job = parfeval(@getLinearPar,1,Ga,reshape_obs_bs,FP.K*FP.L,FP.fitzeta,FP.zeta);
        thetalin = fetchOutputs(job);
        clear job Ga
    end
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
    if FP.fitzeta
        Estimated_eta = thetalin(1:end-1);
        Estimated_zeta = thetalin(end);
        obs_bs = input.obs - Estimated_zeta;
    else
        Estimated_eta = thetalin;
    end
    
    % check convergence
    diff_BetaX = sqrt((Estimated_BetaX_old - Estimated_BetaX).^2)./input.dx;
    diff_BetaY = sqrt((Estimated_BetaY_old - Estimated_BetaY).^2)./input.dx;
    diff_rho   = sqrt((Estimated_rho_old - Estimated_rho).^2)./input.dx;
    test_BetaX_diff = max( diff_BetaX );
    test_BetaY_diff = max( diff_BetaY );
    test_rho_diff   = max( diff_rho );
    if max([test_BetaX_diff,test_BetaY_diff,test_rho_diff]) < TolX
        break;
    end
    
    % Check which values columns already converged
    ind = diff_BetaX < TolX & diff_BetaY < TolX & diff_rho < TolX;
    if sum(ind)<=colConv
        alfa = 0.25;
    else
        alfa = 0.5;
    end
    colConv = sum(ind);
    progress = max(progress,colConv/length(ind));
    
%     fprintf(['Number of columns fitted: ',num2str(sum(ind)),'/',num2str(length(ind)),'\n'])
%     [~,indColumn1] = max(diff_BetaX);
%     [~,indColumn2] = min(diff_BetaX);
%     fprintf(['Minimum Col: ',num2str(indColumn1),' X : ',num2str(diff_BetaX(indColumn1)),', Y: ',num2str(diff_BetaY(indColumn1)),', rho: ',num2str(diff_rho(indColumn1)),'. Minimum Col: ',num2str(indColumn2),' X: ',num2str(diff_BetaX(indColumn2)),' and Y: ',num2str(diff_BetaY(indColumn2)),', rho: ',num2str(diff_rho(indColumn2)),'\n'])
end
if FP.GUI==0 && FP.cluster==0
    close(h)
end

%% Store found results
output = struct;
output.coordinates = [Estimated_BetaX,Estimated_BetaY];
output.rho = Estimated_rho;
output.eta = Estimated_eta;
if FP.fitzeta == 0
    output.zeta = FP.zeta;
else
    output.zeta = Estimated_zeta;
end
output.iter = j_iter;

function EstimatedParametersnonlin = fitAtomNonLinear(obs_bs,X,Y,Box,betaX_org,betaY_org,type,betaX_estimatedbackground,betaY_estimatedbackground,rho_estimatedbackground,eta_estimatedbackground,dx,radius,options,ind)
EstimatedParametersnonlin = zeros(3,length(ind));
for n=1:length(ind)
    i = ind(n);
    % select section of the image and grid around a single atom column
    [obs_s, X_s, Y_s, K_s, L_s] = selectSection(obs_bs, X, Y, Box(type(i)),betaX_org(i)/dx, betaY_org(i)/dx);
    [betaX_b, betaY_b, rho_b, eta_b] = selectParameters(betaX_estimatedbackground, betaY_estimatedbackground, rho_estimatedbackground, eta_estimatedbackground, radius,i);
    reshapeX_s = reshape(X_s,L_s*K_s,1);
    reshapeY_s = reshape(Y_s,L_s*K_s,1);
    
    % Create model to subtract from partial images, for overlap neighbouring columns
    combined_background = sparse(L_s*K_s,1);
    for k = 1:length(betaX_b);
        R = sqrt( ( reshapeX_s - betaX_b(k) ).^2 + (reshapeY_s - betaY_b(k)).^2);
        combined_background = combined_background + eta_b(k)*exp(-R.^2/(2*rho_b(k)^2));
    end
    obs_s_back = reshape(obs_s,L_s*K_s,1) - combined_background;

    % fit
    StartParametersnonlin_s = [betaX_estimatedbackground(i) betaY_estimatedbackground(i) rho_estimatedbackground(i)];
    EstimatedParametersnonlin(:,n) = lsqnonlin('criterionGauss_diffrho',StartParametersnonlin_s',[],[],options,reshapeX_s,reshapeY_s,K_s,L_s,obs_s_back);
end
