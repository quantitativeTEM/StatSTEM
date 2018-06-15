function panel = panelFitPar()
% panelFitPar - Create panel with buttons for parallel computing option in fitting routine
%
%   syntax: panel = panelFitPar()
%       panel - structure containing the necessary information to create a
%               panel with buttons in StatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K. H. W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

panel = struct;

% Start by defining the name
panel.name = 'Parallel computing';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = textfield('name','Number of CPU cores:','width',126,...
    'tooltip',['The maximum number of workers are the number of CPU processors: ',num2str(feature('numCores'))]);

panel.row(1).option2 = editfield('name',num2str(feature('numCores')),'width',36,...
    'tooltip',['The maximum number of workers are the number of CPU processors: ',num2str(feature('numCores'))],...
    'equalTo','input.numWorkers');
