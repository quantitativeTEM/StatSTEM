function panel = panelAtomCountHMM()
% panelAtomCountHMM - Create panel with buttons for counting atoms using
% hidden Markov models
%
%   syntax: panel = panelAtomCountHMM()
%       panel - structure containing the necessary information to create a
%               panel with buttons in StatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2019, EMAT, University of Antwerp
% Author: K. H. W. van den Bos, A. De wael
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

panel = struct;

% Start by defining the name
panel.name = 'Atom counting - Time series';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = pushbutton('name','Run HMM','width',162,'func','analyseFactorialHMM','input','inputHMM','output','outputHMM','fitting',1,...
    'figEnd','Observations Time Series','figOptEnd',{'Atom Counts Time Series'},'reshowFigEnd',true);


