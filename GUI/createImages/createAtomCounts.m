function createAtomCounts(tab, h, show)
% createAtomCounts - Show counting results in observation image
%
%   syntax: createAtomCounts(tab)
%       tab   - reference to selected tab
%       h     - structure holding references to GUI interface
%       show  - show observation with counting results
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

usr = get(tab,'Userdata');

% Get the reference to the axes of the histogram
str = get(usr.figOptions.selImg.listbox,'String');
value_obs = find(strcmp(str,'Observation'));
value_mod = find(strcmp(str,'Model'));

% Add references to figure options of observation
options1 = get(usr.figOptions.selOpt.(['optionsImage',num2str(value_obs)]),'Data');
options2 = get(usr.figOptions.selOpt.(['optionsImage',num2str(value_obs)]),'Data');
if show==1
    options1(:,1) = {0};
    options2(:,1) = {0};
end
options1 = [options1;{show==1 'Atom Counts'}];
options2 = [options2;{show==1 'Atom Counts'}];
set(usr.figOptions.selOpt.(['optionsImage',num2str(value_obs)]),'Data',options1)
set(usr.figOptions.selOpt.(['optionsImage',num2str(value_mod)]),'Data',options2)

if show
    % Show counting results in observation
    showImage(tab,'Observation',h)
end

