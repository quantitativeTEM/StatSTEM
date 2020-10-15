function panel = panelPFR()
% panelPFR - Create panel with buttons for getting initial peak positions
%
%   syntax: panel = panelPFR()
%       panel - structure containing the necessary information to create a
%               panel with buttons in StatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K. H. W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

panel = struct;

% Start by defining the name
panel.name = 'Get peak locations';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Peak-finder routine 1','width',162,'func','RunPeakFinder','input','input','output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);
panel.row(2).option1 = pushbutton('name','Peak-finder routine 2','width',162,'func','tfm_PeakFinder2','input','input','output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);
panel.row(3).option1 = pushbutton('name','Import locations from file','width',162,'func','importPeaks','input','input','output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);
panel.row(4).option1 = pushbutton('name','Get locations from MAP','width',162,'func','GetMAPpos','input',{'input';'outputMAP'},'output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);
