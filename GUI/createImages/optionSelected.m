function optionSelected(hObject,event,tab,h)
% optionSelected - Callback to show or hide figure option
%
%   syntax: optionSelected(hObject,event,tab)
%       hObject - Reference to button
%       event   - structure recording button events
%       tab     - reference to the selected tab
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if ~isempty(event.Indices)
    % Find row
    row = event.Indices(1);
    data = get(hObject,'Data');
    data{row,1} = ~data{row,1};
    
    %Change true false status
    set(hObject,'Data',data)

    % Load handle reference to selected file
    handle = get(tab,'Userdata');

    % Find reference to selected image
    value = get(handle.figOptions.selImg.listbox,'Value');

    % Now update figure
    showHideFigOptions(tab,value,data{row,2},data{row,1},h,1)
end