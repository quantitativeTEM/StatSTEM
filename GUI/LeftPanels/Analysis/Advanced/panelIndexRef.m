function panel = panelIndexRef()
% panelIndexRef - Create panel for strain mapping to select reference coordinate
%
%   syntax: panel = panelIndexRef()
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
panel.name = 'Reference coordinate';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = textfield('name','Type:','width',100);

panel.row(1).option2 = popupmenu('name','','width',62,'input','output',...
    'equalTo','input.types','keepName',0,'selOptInput','output.actType');

panel.row(2).option1 = radiobutton('name','Most central','width',100,'selected',1,...
    'input','output','equalTo','output.optRefCoor','optN',0,'selWhen',{0,'output.optRefCoor'});

panel.row(2).option2 = pushbutton('name','Show','width',62,'input',{'output','input.projUnit'},...
    'output','strainmapping','actWhen',{0,'output.optRefCoor'},'func','getCenCoor',...
    'figEnd','Observation','figOptEnd',{'Coor analysis','Ref strainmapping'});

panel.row(3).option1 = radiobutton('name','User defined','width',100,'selected',0,...
    'input','output','equalTo','output.optRefCoor','optN',1,'selWhen',{1,'output.optRefCoor'});

panel.row(3).option2 = pushbutton('name','Select','width',62,'input',{'output','input.projUnit'},...
    'output','strainmapping','actWhen',{1,'output.optRefCoor'},'func','usrCoorGUI',...
    'figStart','Observation','figEnd','Observation','figOptEnd',{'Coor analysis','Ref strainmapping'});