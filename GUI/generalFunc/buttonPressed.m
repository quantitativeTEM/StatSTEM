function buttonPressed(hObject,event,func,varargin)
% buttonPressed - Change callback function of java button
%
% This function changes the callback function of a java button
%
%   syntax: buttonPressed(hObject,event,func,varargin)
%       hObject  - Reference to button
%       event    - structure recording button events
%       func     - name of the function
%       varargin - cell structure containing input variables of the
%                  function func
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if isempty(func)
    set(hObject,'MouseReleasedCallback',[])
else
    set(hObject,'MouseReleasedCallback',[{func},varargin])
end

