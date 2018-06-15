function panel = panelFitBack()
% panelFitBack - Create panel with buttons for background option in fitting routine
%
%   syntax: panel = panelFitBack()
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
panel.name = 'Background';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = checkbox('name','Fit background','width',162,'equalTo','input.fitZeta','selWhen',{1,'input.fitZeta'});

% Row 2
panel.row(2).option1 = textfield('name','Value:','width',37);

panel.row(2).option2 = editfield('name','Automatic','width',75,...
    'equalTo','input.zeta','actWhen',{0,'input.fitZeta'});

panel.row(2).option3 = pushbutton('name','Select','width',50,'func','selectBack',...
    'input','input.zeta','output','input.zeta','actWhen',{0,'input.fitZeta'},'figStart','Observation');