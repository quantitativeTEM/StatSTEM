function panel = panelPeakShape()
% panelFitWidth - Create panel with drop down menu to indicate the peak shape
%
%   syntax: panel = panelPeakShape()
%       panel - structure containing the necessary information to create a
%               panel with buttons in StatSTEM
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2023, EMAT, University of Antwerp
% Author: A. De Backer
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

panel = struct;

% Start by defining the name
panel.name = 'Peak Shape';

panel.row = struct;
%% Define buttons, etc row per row (don't put too much buttons per row for size limitations)
% Define buttons, etc for the first row per option. Each row has a maximum
% width of 162 pixels

panel.row(1).option1 = radiobutton('name','Gauss (round)','width',162,'selected',1,...
    'tooltip','Fit round Gaussians',...
    'equalTo','input.peakShape','optN',1,'selWhen',{1,'input.peakShape'});

panel.row(2).option1 = radiobutton('name','Lorentz','width',162,'selected',0,...
    'tooltip','Fit Lorentzian',...
    'equalTo','input.peakShape','optN',2,'selWhen',{2,'input.peakShape'});

