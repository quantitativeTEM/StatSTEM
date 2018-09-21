function panel = panelAssignTypes()
% panelAssignTypes - Create panel with buttons to assign column types
%
%   syntax: panel = panelAssignTypes()
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
panel.name = 'Assign column types';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Projected unit cell','width',162,...
    'input','input','output','input.projUnit','func','loadPUC');

% Second row
panel.row(2).option1 = pushbutton('name','Auto assign','width',162,...
    'func','autoAssignTypes','input',{'input.projUnit','input.coordinates'},'output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);

% Second row
panel.row(3).option1 = pushbutton('name','Add missing types','width',162,...
    'func','autoAddTypes','input',{'input.projUnit','input.coordinates'},'output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);

% Fourth row
panel.row(4).option1 = pushbutton('name','Change type to:','width',107,...
    'func','changePeaks','input','input.coordinates','output','input','figStart','Observation','figOptStart',{'Input coordinates'},...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);

panel.row(4).option2 = popupmenu('name',{'Add';'Remove';'Names'},'width',55,...
    'func','numberATypes','input','input','equalTo','input.types','keepName',1,'output','input','selOptInput','input.actType',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);
