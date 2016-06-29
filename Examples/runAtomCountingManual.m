function runAtomCountingManual

% Add StatSTEM function to path
pathF = '..\functions';
addpath(genpath(pathF))
pathG = '..\GUI';
addpath(genpath(pathG))

offset = 0; % Offset in atom counts
n_c = 10;                % Maximum number of components to be fitted

%% Select file
[filename, pathname] = uigetfile('*.mat');
if ischar(filename)
    filename = {filename};
end

%% Run program
fig = figure;ax = gca;
file = strcat(pathname,filename);
load(file{1})
clear atomcounting

% Parameters for fitting
atomcounting.coordinates = output.coordinates(:,1:2);
atomcounting.volumes = output.volumes(:);
atomcounting.selType = [];
atomcounting.N = length(atomcounting.volumes);
atomcounting.ICL = [];
atomcounting.offset = offset;

% Fit the gaussian mixture model
atomcounting = fitGMM(ax,atomcounting,n_c);

% Select minimum
[x,~] = ginput(1);

% Generate atom counts
atomcounting.selMin = min(max(round(x),1),length(atomcounting.ICL));
atomcounting = getAtomCounts(atomcounting);

% Save fitted model
file = strcat(pathname,filename);
save(file{1},'input','output','atomcounting')
fprintf('Finished \n')
close(fig)