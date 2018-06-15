function panel = panelAdv3DModel()
% panelPreCountStat - Create panel with buttons for settings for the 3D
% model
%
%   syntax: panel = panelAdv3DModel()
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
panel.name = 'General';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = textfield('name','Radius:','width',100,...
    'tooltip','Define the radius to identify the coordination number');

panel.row(1).option2 = editfield('name','4','width',42,'input','model3D',...
    'tooltip','Define the radius to identify the coordination number','equalTo','model3D.rad','reshowFigEnd',true);

panel.row(1).option3 = editfield('name',char(197),'width',20,'enable',0,'alignment','c');

panel.row(2).option1 = textfield('name','Number of atoms:','width',100,...
    'tooltip','Define the percentage of atoms for which a coordination number is  to identify the coordination number');

panel.row(2).option2 = editfield('name','100','width',42,'input','model3D',...
    'tooltip','Define the percentage of atoms for which a coordination number is  to identify the coordination number','equalTo','model3D.pForCoor','reshowFigEnd',true);

panel.row(2).option3 = editfield('name','%','width',20,'enable',0,'alignment','c');
