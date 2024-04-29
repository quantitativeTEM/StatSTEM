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


panel.row(2).option1 = radiobutton('name','same width','width',162,'selected',1,...
    'tooltip','Fit GMM components same width',...
    'equalTo','output.GMMType','optN',1,'selWhen',{1,'output.GMMType'});

panel.row(3).option1 = radiobutton('name','dose dependent width','width',162,'selected',0,...
    'tooltip','Fit GMM components dose dependent width',...
    'equalTo','output.GMMType','optN',2,'selWhen',{2,'output.GMMType'});

panel.row(4).option1 = textfield('name','Incident dose:','width',80,...
    'tooltip','Give the incident electron dose in electrons per Angstrom squared');

panel.row(4).option2 = editfield('name','100000','width',52,'input','output.volumes',...
    'tooltip','Give the incident electron dose in electrons per Angstrom squared','equalTo','output.dose');

panel.row(4).option3 = editfield('name', char([101 47 197 178]),'width',30,'enable',0,'alignment','c');