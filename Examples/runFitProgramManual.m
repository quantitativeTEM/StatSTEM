function runFitProgramManual

% Add StatSTEM function to path
pathF = '..\functions';
addpath(genpath(pathF))

%% Fit Options
FP.fitzeta = 1;    % Fit background
FP.zeta = 0;       % Value background (if not fitted)
FP.widthtype = 1;  % Use same Gaussian width for different atomic columns (1 = 'same', 0 = 'different')
FP.atomsToFit = 1; % Fit Gaussian function to all selected peak positions
FP.test = 0;       % Will fit be a test (1 = 'yes', 0 = 'no')
FP.cluster = 1;    % Calculation in a cluster, print progress in command window (1 = 'yes', 0 = 'no')
FP.maxIter = 1;  % Maximum number of iterations
FP.GUI = 0;        % Use GUI (1 = 'yes', 0 = 'no')
FP.numWorkers = feature('numCores'); % Number of cores for parallel computing
FP.silent = 1;     % Hide progress indication from comment window

rho_start = [];    % Starting value width, empty means program will find a value, otherwise define a value for each column in a N x 1 vector 
                   % Can also be defined in the input structure, in field input.rho
                   
%% Check MATLAB version (before MATLAB 2015 no parallel computing is allowed)
v = version('-release');
if str2double(v(1:4))<2015
    FP.numWorkers = 1;
end

%% Select file(s)
[filename, pathname] = uigetfile('*.mat','MultiSelect','on');
if ischar(filename)
    filename = {filename};
end

%% Run program
% If multiple files selected run fitProgram on all files
for n=1:length(filename)
    fprintf('File %d / %d \n',n,length(filename))
    file = strcat(pathname,filename{n});
    load(file)
    clear output
    
    % Parameters for fitting
    FP.K = size(input.obs,2);
    FP.L = size(input.obs,1);
    [FP.X,FP.Y] = meshgrid( (1:FP.K)*input.dx,(1:FP.L)*input.dx);
    FP.Xaxis = FP.X(1,:);
    FP.Yaxis = FP.Y(:,1);
    FP.Xreshape = reshape(FP.X,FP.K*FP.L,1);
    FP.Yreshape = reshape(FP.Y,FP.K*FP.L,1);
    FP.reshapeobs = reshape(input.obs, FP.K*FP.L,1);
    
    % Define starting width
    if ~isempty(rho_start)
        input.rho = rho_start;
    end
    
    if size(input.coordinates,2)==2
        input.coordinates = [input.coordinates ones(size(input.coordinates,1),1)];
    end
        
    % Fit the model
    output = fitGauss(input,FP);

    % Save fitted model
    file = strcat(pathname,filename{n});
    save(file,'input','output')
end
fprintf('Finished \n')