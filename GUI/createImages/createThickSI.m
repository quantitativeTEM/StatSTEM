function createThickSI(tab,h,show)
% createThickSI - Create a plot of the scattered intensities vs thickness
%
%   In this function all necessary steps are taken to show plot the
%   scattering cross-sections in function of column thickness within the
%   StatSTEM interface. A panel will be created to show options that can be
%   displayed or done with the image
%
%       syntax: createThickSI(tab,h,show)
%           tab  - reference to the selected tab
%           h    - structure holding references to the StatSTEM interface
%           show - Logical value indicating whether the image must be shown
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<3
    show = 0;
end

% Get handle to panels in tab
usr = get(tab,'Userdata');

% Find previously selected image
value = get(usr.figOptions.selImg.listbox,'Value');

% First add the figure name to the current list of figures
str = get(usr.figOptions.selImg.listbox,'String');
num = length(str)+1;
set(usr.figOptions.selImg.listbox,'String',[str;{'SCS vs. Thickness'}])
if show
    set(usr.figOptions.selImg.listbox,'Value',num,'Userdata',num)
else
    set(usr.figOptions.selImg.listbox,'Value',value,'Userdata',value)
end

% Create panel for selecting figure options
columnformat = {'logical','char'};
% Check if library is loaded, if so make it an option to show
nameTag = 'Library';
if any(strcmp(fieldnames(usr.file.input),'library'))
    options = {true,nameTag};
else
    options = [];
end
usr.figOptions.selOpt.(['optionsImage',num2str(num)]) = uitable('Parent',usr.figOptions.selOpt.main,'units','normalized',...
    'Position',[0 0 1 1],'ColumnFormat',columnformat,'Data',options,'ColumnEditable',[true false],'RowName',[],'ColumnName',[],...
    'ColumnWidth',{15 110},'CellSelectionCallback',{@optionSelected,tab,h},'Enable','off','Visible','off');

% Depending on status, show or hide figure
if show
    % Show new panel and hide previous panel
    set(usr.figOptions.selOpt.(['optionsImage',num2str(num)]),'Enable','on','Visible','on')
    set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Enable','off','Visible','off')
    
    % Show plot
    showImage(tab,'SCS vs. Thickness',h)
end

% Update parameters
set(tab,'Userdata',usr)