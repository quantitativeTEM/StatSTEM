function panel = panelAtomCountSim()
% panelAtomCountSim - Create panel with buttons for counting atoms in the statistical framework
%
%   syntax: panel = panelAtomCountSim()
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
panel.name = 'Atom counting - Simulation';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Match with simulations','width',162,'input','output','output','libcounting','func','matchLib',...
    'figEnd','Observation','figOptEnd',{'Lib Counts'});

panel.row(2).option1 = pushbutton('name','Create 3D model','width',162,...
    'input',{'libcounting.Counts','strainmapping.indices'},'output','model3D',...
    'func','create3Dmodel','fitting',1,'figEnd','3D model','figOptEnd',{'Color per type'},'reshowFigEnd',true);

panel.row(3).option1 = pushbutton('name','Stop function','width',162,'func','abortFit','input','output');