function [quest,usr] = removeQuestionFit(tab,h,string)
% removeQuestionFit - Remove atomcounting results
%
% Check if atomcounting results are present. If so, ask user whether 
% results can be removed
%
%   syntax: [quest,usr] = removeQuestionFit(tab,h,string)
%       tab    - reference to selected tab containing the file
%       h      - reference to all GUI objects
%       string - message send to user
%       quest  - String idicating if fit results are removed ('Yes'/'No')
%       usr    - Structure with references to selected file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Load image
usr = get(tab,'Userdata');

% Show warning that addition of peak will remove the fitted model and
% possible analysis
if any(strcmp(fieldnames(usr.file),'atomcounting'))
	quest = questdlg(string,'Warning','Yes','No','No');
    drawnow; pause(0.05); % MATLAB hang 2013 version
    if strcmp(quest,'Yes')
        if any(strcmp(fieldnames(usr.file),'atomcounting'))
            deleteAtomCounting(tab,h)
        end
        drawnow
        usr = get(tab,'Userdata');
    end
else
    quest = 'Yes';
end