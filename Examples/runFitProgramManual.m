function runFitProgramManual

% Add StatSTEM function to path
pathF = '..\functions';
addpath(genpath(pathF))

%% Fit Options
appFitApp = 1;  % Select whether fit options below should be applied to all files
fitZeta = 0;    % Fit background
zeta = 0;       % Value background (if not fitted)
widthtype = 1;  % Use same Gaussian width for different atomic columns (1 = 'same', 0 = 'different')
atToFit = 1;    % Fit Gaussian function to all selected peak positions
test = 0;       % Will fit be a test (1 = 'yes', 0 = 'no')
cluster = 1;    % Calculation in a cluster, print progress in command window (1 = 'yes', 0 = 'no')
maxIter = 400;  % Maximum number of iterations
numWorkers = feature('numCores'); % Number of cores for parallel computing
silent = 1;     % Hide progress indication from comment window

rho_start = [];    % Starting value width, empty means program will find a value, otherwise define a value for each column type in a N x 1 vector 
                   % Can also be defined in the input structure, in field input.rhoT
                   
%% Check MATLAB version (before MATLAB 2015 no parallel computing is allowed)
v = version('-release');
if str2double(v(1:4))<2015
    FP.numWorkers = 1;
end

%% Select file(s)
% [filename, pathname] = uigetfile('*.mat','MultiSelect','on');
% if ischar(filename)
%     filename = {filename};
% end
pathnames = uigetfiles;
filename = cell(0,0);
for n=1:length(pathnames)
    files = dir(fullfile(pathnames{n}));
    names = cell(1,length(files));
    for m=1:length(files)
        [pathstr,name,ext] = fileparts(pathnames{n});
        if strcmp(ext,'.mat')
            names{1,m} = [pathstr,filesep,files(m).name];
        else
            [pathstr,name,ext] = fileparts([pathnames{n},filesep,files(m).name]);
            if strcmp(ext,'.mat')
                names{1,m} = [pathstr,filesep,files(m).name];
            else
                names{1,m} = '';
            end
        end
    end
    if isempty(names{1,1})
        names = names(3:end);
    end
    filename = [filename,names];
end
pathname = '';

%% Run program
% If multiple files selected run fitProgram on all files
for n=1:length(filename)
    fprintf('File %d / %d \n',n,length(filename))
    file = strcat(pathname,filename{n});
    [file,~,~] = loadStatSTEMfile(file);
    input = file.input;
    
    % Apply options selected on top
    if appFitApp
        input.fitZeta = fitZeta;
        input.zeta = zeta;
        input.widthtype = widthtype;
        input.atToFit = atToFit;
        input.test = test;
        input.cluster = cluster;
        input.silent = silent;
        input.maxIter = maxIter;
        input.numWorkers = numWorkers;

        % Define starting width
        if ~isempty(rho_start)
            input.rhoT = rho_start;
        end
    end
        
    % Fit the model
    output = input.fitGauss;

    % Save fitted model
    file = strcat(pathname,filename{n});
    save(file,'input','output')
end
fprintf('Finished \n')