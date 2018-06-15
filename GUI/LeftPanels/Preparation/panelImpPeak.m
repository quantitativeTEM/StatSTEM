function panel = panelImpPeak()
% panelImpPeak - Create panel for importing peak locations
%
%   syntax: panel = panelImpPeak()
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
panel.name = 'Import peak locations';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Load File','width',162,'func','importPeaks','input','input','output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);