function panel = panelIndexDirA()
% panelIndexDirA - Create panel for strain mapping to select a-direction
%
%   syntax: panel = panelIndexDirA()
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
panel.name = 'Direction a lattice';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

% Row 1
panel.row(1).option1 = radiobutton('name','Automatic','width',100,'selected',1,...
    'input','strainmapping','equalTo','strainmapping.findDirA','optN',0,'selWhen',{0,'strainmapping.findDirA'});


panel.row(1).option2 = pushbutton('name','Show','width',62,'input','strainmapping',...
    'output','strainmapping','actWhen',{0,'strainmapping.findDirA'},'func','findLatDir',...
    'figEnd','Observation','figOptEnd',{'Fitted coordinates','a & b lattice'});

% Row 2
panel.row(2).option1 = radiobutton('name','User defined','width',100,...
    'input','strainmapping','equalTo','strainmapping.findDirA','optN',1,'selWhen',{1,'strainmapping.findDirA'});

panel.row(2).option2 = pushbutton('name','Select','width',62,'input','strainmapping',...
    'output','strainmapping.a','actWhen',{1,'strainmapping.findDirA'},'func','findLatDir',...
    'figStart','Observation','figOptStart',{'Fitted coordinates','Ref strainmapping'},...
    'figEnd','Observation','figOptEnd',{'Fitted coordinates','a & b lattice'});

% Row 3
panel.row(3).option1 = checkbox('name','Improve values by fitting',...
    'width',162,'selected',1,'input','strainmapping','equalTo','strainmapping.impByFit');

% Row 4
panel.row(4).option1 = textfield('name','','width',10); % Dummy for space

panel.row(4).option2 = textfield('name','Number of UCs:','width',100,...
    'tooltip','Define the number of unit cells that will be used for fitting the angle and the a- and b-lattice parameters',...
    'actWhen',{1,'output.impByFit'},'input','strainmapping');

panel.row(4).option3 = editfield('name','3','width',42,...
    'tooltip','Define the number of unit cells that will be used for fitting the angle and the a- and b-lattice parameters',...
    'actWhen',{1,'output.impByFit'},'input','strainmapping','equalTo','strainmapping.nUC');

panel.row(4).option4 = textfield('name','','width',10); % Dummy for space

% Row 5
panel.row(5).option1 = textfield('name','','width',10); % Dummy for space

panel.row(5).option2 = radiobutton('name','Fit angle, a and b','width',142,...
    'selected',1,'input','strainmapping','actWhen',{1,'strainmapping.impByFit'},'optN',0,'equalTo','strainmapping.fitABang','selWhen',{0,'strainmapping.fitABang'});

panel.row(5).option3 = textfield('name','','width',10); % Dummy for space

% Row 6
panel.row(6).option1 = textfield('name','','width',10); % Dummy for space

panel.row(6).option2 = radiobutton('name','Fit only the angle','width',142,...
    'selected',0,'input','strainmapping','actWhen',{1,'strainmapping.impByFit'},'optN',1,'equalTo','strainmapping.fitABang','selWhen',{1,'strainmapping.fitABang'});

panel.row(6).option3 = textfield('name','','width',10); % Dummy for space

