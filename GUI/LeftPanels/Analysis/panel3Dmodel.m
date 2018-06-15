function panel = panel3Dmodel()
% panelAtomCountStat - Create panel with buttons for a 3D model
%
%   syntax: panel = panel3Dmodel()
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
panel.name = '3D model';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Save model as XYZ','width',162,...
    'input','model3D','func','export3Dcoor','fitting',1);

panel.row(2).option1 = pushbutton('name','Coordination number','width',162,...
    'input','model3D','output','model3D.coorNum','func','getCoorNum','fitting',1,...
    'figEnd','3D model','figOptEnd',{'Coordination number'},'reshowFigEnd',true);

panel.row(3).option1 = pushbutton('name','Save coor number as XYZ','width',162,...
    'input','model3D.coorNum','func','export3DcoorNum','fitting',1);

panel.row(4).option1 = pushbutton('name','Stop function','width',162,'func','abortFit','input','output');

% Advanced option
panel.advanced = struct; % empty structure means that no advanced options are present

panel.showAdv = 0;
panel.advanced(1).panel = panelAdv3DModel;