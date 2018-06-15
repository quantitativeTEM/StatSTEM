function panel = panelIndexing()
% panelStrainMap - Create panel with buttons for strain mapping
%
%   syntax: panel = panelIndexing()
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
panel.name = 'Index columns';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Projected unit cell','width',162,...
    'input','input','output',{'input.projUnit','strainmapping'},'func','loadPUC');

panel.row(2).option1 = pushbutton('name','Start indexing','width',162,...
    'input',{'output.coordinates','input.projUnit'},'optInput','strainmapping','output','strainmapping.indices','func','indexColumns',...
    'figEnd','Observation','figOptEnd',{'Indexed coordinates'});

% Advanced option
panel.advanced = struct; % empty structure means that no advanced options are present

panel.showAdv = 0;
panel.advanced(1).panel = panelIndexRef;
panel.advanced(2).panel = panelIndexDirA;
