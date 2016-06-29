function createGMM(tab,show)
% createGMM - Show the GMM of the individual components and the total GMM
%
%   syntax: createGMM(tab,show)
%       tab  - reference to selected tab
%       show - Plot the GMM 
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
val = get(usr.figOptions.selImg.listbox,'Value');
value = find(strcmp(str,'Histogram SCS'));
ax = usr.images.ax;

if show && val==value
    bins = getBinsHist(ax);
    [x,GMM] = calcGMM(usr.file.atomcounting,bins);
    GMMtot = sum(GMM,1);
    
    % Plot the GMM of the individual components
    plotGMMcomp(ax,x,GMM,usr.file.atomcounting.offset)

    % Plot the total GMM
    plotGMM(ax,x,GMMtot)
end
if show
    st = true;
else
    st = false;
end

% Add references to figure options
options = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
options = [options;{st 'GMM components'};{st 'GMM'}];
set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',options)