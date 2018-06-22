function panel = panelIndexRoutine()
% panelIndexRoutine - Create panel for parameters indexing routine
%
%   syntax: panel = panelIndexRoutine()
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
panel.name = 'Indexing';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

% Row 1
panel.row(1).option1 = textfield('name','Update factor:','width',120,...
    'tooltip','Define an update factor to modify the lattice parameters gradually. This will enable the routine to index all columns, even when variations in the lattice are present',...
    'input','strainmapping');

panel.row(1).option2 = editfield('name','0.1','width',42,...
    'tooltip','Define an update factor to modify the lattice parameters gradually. This will enable the routine to index all columns, even when variations in the lattice are present',...
    'input','strainmapping','equalTo','strainmapping.fUpdate');

