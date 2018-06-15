function panel = panelImgPar()
% panelImgPar - Create panel with buttons for image parameters
%
%   syntax: panel = panelImgPar()
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
panel.name = 'Image parameters/actions';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = textfield('name','Pixel size:','width',55);

panel.row(1).option2 = editfield('name','','width',87,'func','updateDX',...
    'enable',1,'input','input.dx','optInput',{'output.dx','atomcounting.dx','libcounting.dx','strainmapping.dx','outputMAP.dx'},...
    'equalTo',{'input.dx','output.dx','atomcounting.dx','libcounting.dx','strainmapping.dx','outputMAP.dx'},...
    'output',{'input.dx','output.dx','atomcounting.dx','libcounting.dx','strainmapping.dx','outputMAP.dx'},...
    'reshowFigEnd',true);

panel.row(1).option3 = editfield('name',char(197),'width',20,'enable',0,'alignment','c');

panel.row(2).option1 = pushbutton('name','Cut part from image','width',162,...
    'func','selectPartImage','input','input.obs','output','input',...
    'figStart','Observation','figOptStart',{'Input coordinates'},'reshowFigEnd',true);

panel.row(3).option1 = pushbutton('name','Flip contrast image','width',162,...
    'func','flipContrastImage','input','input.obs','output','input',...
    'figStart','Observation','figOptStart',{'Input coordinates'},'reshowFigEnd',true);

panel.row(4).option1 = pushbutton('name','Make image background','width',162,...
    'func','makeBack','input','input.obs','output','input','tooltip','Make part of the image equal to a background value',...
    'figStart','Observation','figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);

panel.row(5).option1 = pushbutton('name','Normalise image','width',162,...
    'func','calibrateImage','input','input.obs','output','input',...
    'figEnd','Observation','figOptEnd',{'Input coordinates'},'reshowFigEnd',true);