function optionSelected(hObject,event,tab)
% optionSelected - Callback to show or hide figure option
%
% syntax: optionSelected(hObject,event,tab)
%   hObject - Reference to button
%   event   - structure recording button events
%   tab     - reference to the selected tab
%
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
if ~isempty(event.Indices)
    row = event.Indices(1);
    data = get(hObject,'Data');
    % CellEditCallback already updated data{row,1} with new value
    % so no need to toggle manually
    showHideFigOptions(tab, data{row,2}, data{row,1})
end