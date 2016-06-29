function updateNumWorkFit(jObject,event,h)
% updateBack - Callback for storing the number of cores for parallel
% computing
%
%   syntax: updateNumWorkFit(jObject,event,h)
%       jObject - Reference to java object
%       event   - structure recording button events
%       h       - structure holding references to StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

tab = loadTab(h);
if isempty(tab)
%     h_mes = errordlg('First load an image');
%     waitfor(h_mes)
    return
end
% Load image
usr = get(tab,'Userdata');
set(jObject,'Text',num2str(usr.fitOpt.model.numWorkers))