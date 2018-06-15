function panel = panelFitTest()
% panelFitTest - Create panel with buttons for width option in fitting routine
%
%   syntax: panel = panelFitTest()
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
panel.name = 'Test for convergence';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = checkbox('name','Use test conditions','width',162,...
    'selected',0,'tooltip','Limit the maximum number of iterations to 4 and fit only column positions',...
    'equalTo','input.test');

panel.row(2).option1 = pushbutton('name','Re-use fitted coordinates','width',162,...
    'tooltip','Make fitted coordinates the new input coordinates for a second fit',...
    'func','outputIsInput','input',{'output','input'},'output','input','figEnd','Observation','figOptEnd',{'Input coordinates'});
