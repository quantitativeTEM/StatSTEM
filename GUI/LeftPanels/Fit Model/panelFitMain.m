function panel = panelFitMain()
% panelFitMain - Create panel with buttons for fitting routine
%
%   syntax: panel = panelFitMain()
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
panel.name = 'Standard procedure';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Run fitting routine','width',162,'func','fitGauss',...
    'input','input.coordinates','output','output','fitting',1,'figEnd','Model','figOptEnd',{'Fitted coordinates'});

panel.row(2).option1 = pushbutton('name','Abort fitting routine','width',162,'func','abortFit','input','input');

% Advanced option
panel.advanced = struct; % empty structure means that no advanced options are present

panel.showAdv = 0; % 1 - Show panel from start
panel.advanced(1).panel = panelFitBack;
panel.advanced(2).panel = panelFitWidth;
panel.advanced(3).panel = panelFitTest;
panel.advanced(4).panel = panelFitPar;
