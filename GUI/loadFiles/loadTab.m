function [tab,mes] = loadTab(h)
% loadTab - Load references to file on specific tab
%
% Test if tab holds references to an opened file
%
%   syntax: [tab,mes] = loadTab(h)
%       h       - structure holding references to the StatSTEM interface
%       tab     - reference to selected tab
%       mes     - message
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

tabs = get(h.right.tabgroup,'Children');
% First check if file is loaded
if length(tabs)==1
    tab = [];
    mes = 'ERROR; First open a file';
else
    % Load tab
    v = version('-release');
    if str2double(v(1:4))>=2015
        tab = get(h.right.tabgroup,'SelectedTab');
    else
        tab = tabs(get(h.right.tabgroup,'SelectedIndex'));
    end
    mes = 'ok';
end
