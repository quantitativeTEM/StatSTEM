function panel = panelPostCountStat()
% panelPostCountStat - Create panel with buttons for options within statistical atom counting framework
%
%   syntax: panel = panelPostCountStat()
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
panel.name = 'Post-analysis options';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = textfield('name','Counting offset:','width',100,...
    'tooltip','Define the offset in the atom counting results');

panel.row(1).option2 = editfield('name','0','width',62,'input','atomcounting.offset',...
    'tooltip','Define the offset in the atom counting results','equalTo','atomcounting.offset',...
    'equalTo','atomcounting.offset');

panel.row(2).option1 = pushbutton('name','Select new ICL minimum','width',162,...
    'input','atomcounting.selMin','output','atomcounting','func','selICLmin',...
    'figStart','ICL','figEnd','ICL','figOptEnd',{'Minimum ICL'});
