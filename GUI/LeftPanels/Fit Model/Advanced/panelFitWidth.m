function panel = panelFitWidth()
% panelFitWidth - Create panel with buttons for width option in fitting routine
%
%   syntax: panel = panelFitWidth()
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
panel.name = 'Column width';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = radiobutton('name','Same width','width',162,'selected',1,...
    'tooltip','Use the same width for each atomic column of the same type',...
    'equalTo','input.widthtype','optN',1,'selWhen',{1,'input.widthtype'});

panel.row(2).option1 = radiobutton('name','Different width','width',162,'selected',0,...
    'tooltip','Use a different width for each atomic column',...
    'equalTo','input.widthtype','optN',0,'selWhen',{0,'input.widthtype'});

panel.row(3).option1 = radiobutton('name','User defined','width',110,'selected',0,...
    'tooltip','Use a user defined width for each atomic column (type)',...
    'equalTo','input.widthtype','optN',2,'selWhen',{2,'input.widthtype'});

panel.row(3).option2 = pushbutton('name','Edit','width',52,'func','defineRho',...
    'tooltip','Edit the user defined width for each column (type)','actWhen',{2,'input.widthtype'},...
    'input','input.rhoT','output','input.rhoT');
