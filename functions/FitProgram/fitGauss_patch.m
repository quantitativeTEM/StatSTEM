function [output,abort] = fitGauss_patch(input,FP)
% fitGauss_patch - program to fit gaussian peaks to a STEM image
%
%   In this method, a relative large part of the image surrounding an 
%   individual peak is cut out of the original image. Next, the image 
%   contrubutions of the atoms close to the edge are subtracted. Than,
%   gaussian peaks are fitted to all the remaining columns in the selected 
%   part of the image. The width of the gaussian peak is dependent on the
%   atom type of each column.
%
%   syntax: [output,abort] = fitGauss_patch(input,FP)
%       input  - input structure
%       FP     - structure containing the fitting options
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

abort = 0;

tic;
% Refine size of box per atom type, start from original
if size(input.coordinates,2)==2
    input.coordinates(:,3) = ones(size(input.coordinates,1),1);
end

%% define matrices
Estimated_BetaX = input.coordinates(:,1);
Estimated_BetaY = input.coordinates(:,2);
rho = FP.rho;
type = input.coordinates(:,3);
Box = round(FP.dist/input.dx)/2*ones(max(type),1); %calcBoxSize(FP.obs_bs,input.coordinates,input.dx);

%% Zeta columnwise
% obs_back = smoothBack(Box,FP.K,FP.L,FP.X,FP.Y,input.obs,input.dx);
obs_back = 0;
%% startmodel
input_obs_bs = input.obs-obs_back;
reshape_obs_bs = reshape(input_obs_bs,FP.K*FP.L,1);
Ga = sparse(FP.K*FP.L,FP.n_c+FP.fitzeta);
job = cell(FP.numWorkers,1);
max_n = 70-6*FP.numWorkers;
if FP.numWorkers==1
    Ga(:,FP.indAllWorkers{1,1}) = getGa(FP.K,FP.L,max_n,FP.indMat,rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{1,1});
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
        job{n} = parfeval(@getGa,1,FP.K,FP.L,max_n,FP.indMat,rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{n,1});
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
else
    Estimated_eta = thetalin;
    Estimated_zeta = FP.zeta;
end
obs_bs = input_obs_bs - Estimated_zeta;
Estimated_rho = rho;

%% options for lsqnonlin
options = optimset('lsqnonlin');
options.Jacobian = 'on';
options.DerivativeCheck = 'off';
options.Display = 'off';
options.Largescale = 'on';
options.Algorithm = 'trust-region-reflective';
options.TolX = 1e-4;
options.TolFun = eps;
options.MaxIter = FP.maxIter;
% Box for patches
Box = getBoxSize(input.coordinates,input.dx,FP,20);

%% Start iterations
if FP.GUI==0 && FP.cluster==0
    h = waitbar(0,'1','Name','Fitting...');
end

% Fit new column positions
if FP.numWorkers == 1
    string_n_c = num2str(FP.n_c);
    indWorkers = devideIndices(FP.atomsToFit,1);
    indWorkers = indWorkers{1};
    for n=1:length(indWorkers)
        % Abort button GUI
        if FP.GUI
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
        % Report progress in the waitbar's message field
        if FP.GUI
            FP.waitbar.setValue((n-1)/FP.n_c/(FP.widthtype+1)*100)
        else
            formatSpec = ['Column %d / ',string_n_c];
            if FP.cluster
                fprintf([formatSpec,' \n'],n)
            else
                waitbar(j_iter/FP.maxIter,h, sprintf(formatSpec,n))
            end
        end
        
        EstimatedParametersnonlin = fitAtomNonLinear(obs_bs,FP.X,FP.Y,Box,input.coordinates(:,1),input.coordinates(:,2),rho,Estimated_eta,input.dx,options,FP.widthtype,indWorkers(n));
        Estimated_BetaX(indWorkers(n)) = EstimatedParametersnonlin(1);
        Estimated_BetaY(indWorkers(n)) = EstimatedParametersnonlin(2);
        Estimated_rho(indWorkers(n))   = EstimatedParametersnonlin(3);
    end
else
    numWorkers = min(sum(FP.atomsToFit),50);
    string_n_c = num2str(numWorkers);
    indWorkers = devideIndices(FP.atomsToFit,numWorkers);
    job = cell(numWorkers,1);
    for n=1:numWorkers
        % Abort button GUI
        if FP.GUI
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
        job{n} = parfeval(@fitAtomNonLinear,1,obs_bs,FP.X,FP.Y,Box,input.coordinates(:,1),input.coordinates(:,2),rho,Estimated_eta,input.dx,options,FP.widthtype,indWorkers{n,1});
    end
    
    for n=1:numWorkers
        % Abort button GUI
        if FP.GUI
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
        % Report progress in the waitbar's message field
        if FP.GUI
            FP.waitbar.setValue((n-1)/numWorkers/(FP.widthtype+1)*100)
        else
            formatSpec = ['Part %d / ',string_n_c];
            if FP.cluster
                fprintf([formatSpec,' \n'],n)
            else
                waitbar(j_iter/FP.maxIter,h, sprintf(formatSpec,n))
            end
        end
        EstimatedParametersnonlin = fetchOutputs(job{n});
        
        Estimated_BetaX(indWorkers{n,1}) = EstimatedParametersnonlin(1,:);
        Estimated_BetaY(indWorkers{n,1}) = EstimatedParametersnonlin(2,:);
        Estimated_rho(indWorkers{n,1})   = EstimatedParametersnonlin(3,:);
    end
end

% Close waitbar
if FP.GUI==0
    if FP.cluster==0
        close(h)
    end
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
% Get linear parameters
Ga = sparse(FP.K*FP.L,FP.n_c+FP.fitzeta);
if FP. numWorkers == 1
    Ga(:,FP.indAllWorkers{1,1}) = getGa(FP.K,FP.L,max_n,FP.indMat,rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{1,1});
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
    for n=1:FP.numWorkers
        job{n} = parfeval(@getGa,1,FP.K,FP.L,max_n,FP.indMat,rho,input.dx,Estimated_BetaX,Estimated_BetaY,FP.Xreshape,FP.Yreshape,FP.indAllWorkers{n,1});
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
    job = parfeval(@getLinearPar,1,Ga,FP.reshapeobs,FP.K*FP.L,FP.fitzeta,FP.zeta);
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
else
    Estimated_eta = thetalin;
    Estimated_zeta = FP.zeta;
end


%% results
output = struct;
output.coordinates = [Estimated_BetaX,Estimated_BetaY];
output.rho = Estimated_rho;
output.eta = Estimated_eta;
output.zeta = Estimated_zeta;


function EstimatedParametersnonlin = fitAtomNonLinear(obs_bs,X,Y,Box,BetaX_org,BetaY_org,rho_org,Eta_org,dx,options,widthtype,ind)
EstimatedParametersnonlin = zeros(3,length(ind));
for i=1:length(ind)
    n = ind(i);

    % select section of the image and grid around a single atom column
    [obs_s, X_s, Y_s, K_s, L_s] = selectSection(obs_bs, X, Y, Box,BetaX_org(n)/dx, BetaY_org(n)/dx);
    obs_s = obs_s - min(min(obs_s));
    index = selectColumns(BetaX_org, BetaY_org, Box*dx+1.25*rho_org, n);
    betaX = [BetaX_org(n);BetaX_org(index)];
    betaY = [BetaY_org(n);BetaY_org(index)];
    rho = [rho_org(n);rho_org(index)];
    eta   = [Eta_org(n);Eta_org(index)];
    reshapeX_s = reshape(X_s,L_s*K_s,1);
    reshapeY_s = reshape(Y_s,L_s*K_s,1);
    obs_r = reshape(obs_s,L_s*K_s,1);
    
    index2 = selectColumns(betaX,betaY, Box*dx-rho, 1);
    index2(1) = 1; % First column must be fitted
    
    betaX_s = betaX(index2==0);
    betaY_s = betaY(index2==0);
    rho_s = rho(index2==0);
    eta_s = eta(index2==0);
    betaX_b = betaX(index2);
    betaY_b = betaY(index2);
    rho_b = rho(index2);
    
    % Create model to subtract from partial images, for overlap neighbouring columns near the border
    combined_background = sparse(L_s*K_s,1);
    for k = 1:length(betaX_s);
        R = sqrt( ( reshapeX_s - betaX_s(k) ).^2 + (reshapeY_s - betaY_s(k)).^2);
        combined_background = combined_background + eta_s(k)*exp(-R.^2/(2*rho_s(k)^2));
    end
    reshape_obs_s = obs_r - combined_background;
    
    % rho starting parameters
    if widthtype==0
        n_c_s = length(betaX_b);
        types = (1:n_c_s)';
        rho_sel = rho;
    else
        [rho_sel,~,types] = unique(rho_b);
        n_c_s = length(types);
    end
    
    % fit
    StartParametersnonlin_s = [betaX_b;betaY_b;rho_sel];
    fitzeta = 0;
    EstParnonlin = lsqnonlin('criterionGauss_Patch',StartParametersnonlin_s',[],[],options,reshapeX_s,reshapeY_s,K_s,L_s,reshape_obs_s,types,fitzeta);
    EstimatedParametersnonlin(1,i) = EstParnonlin(1);
    EstimatedParametersnonlin(2,i) = EstParnonlin(n_c_s+1);
    EstimatedParametersnonlin(3,i) = EstParnonlin(2*n_c_s+1);
end

function Box = getBoxSize(coordinates,dx,FP,num)

dist_test = zeros(length(coordinates(:,1)),1);
job = cell(FP.numWorkers,1);
if FP.numWorkers == 1
    Box = mean(getDist(coordinates,FP.indAllWorkers{1,1},num))/dx;
else
    % Calculate distance per worker
    for k=1:FP.numWorkers
        job{k} = parfeval(@getDist,1,coordinates,FP.indAllWorkers{k,1},num);
    end
    % Receive distance
    for k=1:FP.numWorkers
        [~,dist_test(FP.indAllWorkers{k,1})] = fetchNext(job{k});
    end
    Box = mean(dist_test)/dx;
end
    
function dist = getDist(coordinates,ind,num)
dist = zeros(length(ind),1);
num = min(length(coordinates(:,1)),num);
for n = 1:length(ind)
    i = ind(n);
    betaX_translated = coordinates(:,1) - coordinates(i,1);
    betaY_translated = coordinates(:,2) - coordinates(i,2);
    r = betaX_translated.^2+betaY_translated.^2;
    sr = sort(r);
    dist(n) = sqrt(sr(num));
end
