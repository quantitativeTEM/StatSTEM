function panel = panelPreCountStat()
% panelPreCountStat - Create panel with buttons for settings for statistical atom counting framework
%
%   syntax: panel = panelPreCountStat()
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
panel.name = 'Pre-analysis options';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = textfield('name','Max components:','width',100,...
    'tooltip','Define the maximum number of components to estimate');

panel.row(1).option2 = editfield('name','100','width',62,'input','output.volumes',...
    'tooltip','Define the maximum number of components to estimate','equalTo','output.n_c');
