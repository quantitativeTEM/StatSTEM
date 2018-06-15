function panel = panelSelColumns()
% selColumns - Create panel with buttons for selecting column for further analysis
%
%   syntax: panel = selColumns()
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
panel.name = 'General options';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Select new model from MAP','width', 162,...
    'input',{'outputMAP';'input'},'output',{'output';'outputMAP'},'func','selNewModel',...
    'figStart','MAP probability','figEnd','Model','figOptEnd','Fitted coordinates');

panel.row(2).option1 = pushbutton('name','Show models from MAP','width', 162,...
    'input',{'outputMAP';'input'},'func','showModels');

panel.row(3).option1 = togglebutton('name','Select columns in image','width',162,...
    'input','output.volumes','func','selColumnAtom','output','output','equalTo','output.selRegion',...
    'figStart','Model','figOptStart',{'Fitted coordinates'},'figEnd','Model','figOptEnd',{'Coor analysis'});

panel.row(4).option1 = togglebutton('name','Select columns in histogram','width',162,...
    'input','output.volumes','func','selColumnHist','output','output','equalTo','output.rangeVol',...
    'figStart','Histogram SCS','figEnd','Histogram SCS','reshowFigEnd',true);

panel.row(5).option1 = togglebutton('name','Select columns on type','width',162,...
    'input','output.volumes','func','selColumnType','output','output','equalTo','output.selType',...
    'figEnd','Model','figOptEnd',{'Coor analysis'});
