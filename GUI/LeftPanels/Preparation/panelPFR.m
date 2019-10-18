function panel = panelPFR()
% panelPFR - Create panel with buttons for a peak finder routine
%
%   syntax: panel = panelPFR()
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
panel.name = 'Peak Finder Routine';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Execute routine 1','width',162,'func','RunPeakFinder','input','input','output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);
panel.row(2).option1 = pushbutton('name','Execute routine 2','width',162,'func','tfm_PeakFinder2','input','input','output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);
