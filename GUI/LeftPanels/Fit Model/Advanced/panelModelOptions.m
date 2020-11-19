function panel = panelModelOptions()
% panelFitWidth - Create panel with buttons for options in model selection
%
%   syntax: panel = panelModelOptions()
%       panel - structure containing the necessary information to create a
%               panel with buttons in StatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2020, EMAT, University of Antwerp
% Author: K. H. W. van den Bos, J. Fatermans
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

panel = struct;

% Start by defining the name
panel.name = 'Options';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = textfield('name','Max. # columns:','width',100);

panel.row(1).option2 = editfield('name','','width',62,'enable',1,...
    'input','input','equalTo','input.MaxColumns');


% panel.row(2).option1 = textfield('name','# Test points:','width',100);
% 
% panel.row(2).option2 = editfield('name','','width',62,'enable',1,...
%     'tooltip','Define the number of initial random starting coordinates per model evaluation','input','input','equalTo','input.testpoints');


panel.row(2).option1 = textfield('name','Min. background:','width',100);

panel.row(2).option2 = editfield('name','','width',62,'enable',1,...
    'input','input','equalTo','input.zetamin');


panel.row(3).option1 = textfield('name','Max. background:','width',100);

panel.row(3).option2 = editfield('name','','width',62,'enable',1,...
    'input','input','equalTo','input.zetamax');


panel.row(4).option1 = textfield('name','Min. width.:','width',100);

panel.row(4).option2 = editfield('name','','width',42,'enable',1,...
    'input','input','equalTo','input.rhomin');

panel.row(4).option3 = editfield('name',char(197),'width',20,'enable',0,'alignment','c');


panel.row(5).option1 = textfield('name','Max. width:','width',100);

panel.row(5).option2 = editfield('name','','width',42,'enable',1,...
    'input','input','equalTo','input.rhomax');

panel.row(5).option3 = editfield('name',char(197),'width',20,'enable',0,'alignment','c');


panel.row(6).option1 = textfield('name','Min. intensity:','width',100);

panel.row(6).option2 = editfield('name','','width',62,'enable',1,...
    'input','input','equalTo','input.etamin');


panel.row(7).option1 = textfield('name','Max. intensity:','width',100);

panel.row(7).option2 = editfield('name','','width',62,'enable',1,...
    'input','input','equalTo','input.etamax');


panel.row(8).option1 = textfield('name','Min. x-coord.:','width',100);

panel.row(8).option2 = editfield('name','','width',42,'enable',1,...
    'input','input','equalTo','input.beta_xmin');

panel.row(8).option3 = editfield('name',char(197),'width',20,'enable',0,'alignment','c');


panel.row(9).option1 = textfield('name','Max. x-coord.:','width',100);

panel.row(9).option2 = editfield('name','','width',42,'enable',1,...
    'input','input','equalTo','input.beta_xmax');

panel.row(9).option3 = editfield('name',char(197),'width',20,'enable',0,'alignment','c');


panel.row(10).option1 = textfield('name','Min. y-coord.:','width',100);

panel.row(10).option2 = editfield('name','','width',42,'enable',1,...
    'input','input','equalTo','input.beta_ymin');

panel.row(10).option3 = editfield('name',char(197),'width',20,'enable',0,'alignment','c');


panel.row(11).option1 = textfield('name','Max. y-coord.:','width',100);

panel.row(11).option2 = editfield('name','','width',42,'enable',1,...
    'input','input','equalTo','input.beta_ymax');

panel.row(11).option3 = editfield('name',char(197),'width',20,'enable',0,'alignment','c');

