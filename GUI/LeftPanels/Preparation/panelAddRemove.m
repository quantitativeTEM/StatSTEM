function panel = panelAddRemove()
% panelAddRemove - Create panel with buttons to add and remove peaks manually
%
%   syntax: panel = panelAddRemove()
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
panel.name = 'Add/Remove Peaks';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = textfield('name','Type:','width',33);

panel.row(1).option2 = popupmenu('name',{'Add';'Remove';'Names'},'width',64,...
    'func','numberATypes','keepName',1,'input','input','equalTo','input.types','output','input','selOptInput','input.actType',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);

panel.row(1).option3 = pushbutton('name','Add','width',65,'func','addPeaks','input','input','output','input','figStart','Observation','figOptStart',{'Input coordinates'});

% Second row
panel.row(2).option1 = pushbutton('name','Remove','width',81,...
    'func','removePeaks','input','input.coordinates','output','input','figStart','Observation','figOptStart',{'Input coordinates'});

panel.row(2).option2 = pushbutton('name','Remove all','width',81,...
    'func','removeAllPeaks','input','input.coordinates','output','input','figStart','Observation','figOptStart',{'Input coordinates'});

% Third row
panel.row(3).option1 = pushbutton('name','Select region','width',162,...
    'func','keepPeaks','input','input.coordinates','output','input','figStart','Observation','figOptStart',{'Input coordinates'},...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);

% Fourth row
panel.row(4).option1 = pushbutton('name','Remove region','width',162,...
    'func','deletePeaks','input','input.coordinates','output','input','figStart','Observation','figOptStart',{'Input coordinates'},...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);
