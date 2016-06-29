function setNumWorkFit(jObject,event,h)
% setNumWorkFit - Callback for storing new value for parallel computing
%
%   syntax: setNumWorkFit(jObject,event,h)
%       jObject - Reference to java object
%       event   - structure recording button events
%       h       - structure holding references to GUI interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

str = get(jObject,'Text');
num = str2double(str);
if isempty(str) || strcmp(str,'-')
    num = feature('numCores');
elseif isnan(num)
    num=feature('numCores');
	set(jObject,'Text',num2str(feature('numCores')))
elseif num>feature('numCores')
    num = feature('numCores');
end
tab = loadTab(h);
if isempty(tab)
    h_mes = errordlg('First load an image');
    waitfor(h_mes)
    return
end
% Load image
usr = get(tab,'Userdata');
usr.fitOpt.model.numWorkers = num;
% Save background
set(tab,'Userdata',usr)