function addMinICL(tab,show,h)
% addMinICL - add the selected minimum to the ICL figure in the StatSTEM
%             interface
%
%   syntax: addMinICL(tab,show,h)
%       tab  - reference to selected tab
%       show - Show the minimum in the ICL
%       h    - structure holding references to StatSTEM interface
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

usr = get(tab,'Userdata');

% Get the reference to the axes of the histogram
str = get(usr.figOptions.selImg.listbox,'String');
ind = get(usr.figOptions.selImg.listbox,'Value');
val = find(strcmp(str,'ICL'));
ax = usr.images.ax;

if show && ind==val
    % Plot selected minimum
    plotMinICL(ax,[usr.file.atomcounting.selMin,usr.file.atomcounting.ICL(usr.file.atomcounting.selMin)]);
end
if show
    st = true;
else
    st = false;
end
% Add reference to plotted minimum in figure options
options = get(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data');
options = [options;{st 'Minimum ICL'}];
set(usr.figOptions.selOpt.(['optionsImage',num2str(val)]),'Data',options);

% Enable select minimum in ICL button
h.left.ana.panel.atomAdv.minICL.setEnabled(true)