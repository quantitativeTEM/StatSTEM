function runAtomCountingManual

% Add StatSTEM function to path
pathF = '..\functions';
addpath(genpath(pathF))

offset = 0; % Offset in atom counts
n_c = 20;   % Maximum number of components to be fitted

%% Select file
[filename, pathname] = uigetfile('*.mat');
if ischar(filename)
    filename = {filename};
end

%% Run program
fig = figure;
filename = strcat(pathname,filename);
[file,~,~] = loadStatSTEMfile(filename{1});
if isfield(file,'atomcounting')
    file = rmfield(file,'atomcounting');
end

% Fit the gaussian mixture model
file.output.n_c = n_c;
file.atomcounting = file.output.fitGMM;
file.atomcounting.offset = offset;
close(fig)

% Save fitted model
save(filename{1},'-struct','file')
fprintf('Finished \n')