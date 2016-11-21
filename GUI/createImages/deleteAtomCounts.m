function deleteAtomCounts(h,tab,obs,nameTag)
% deleteAtomCounts - Delete the atom counts from the image
%
%   In this function all necessary steps are taken to delete the atom
%   counts from the shown image 
%
%       syntax: deleteAtomCounts(tab,obs)
%       h       - structure holding references to StatSTEM interface
%           tab     - reference to the selected tab
%       	obs     - the shown image
%           nameTag - name of the counting results
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Get userdata
usr = get(tab,'Userdata');

% Now delete old figure axes and panel (panel for memory leakage)
delete(usr.images.ax2)
delete(usr.images.ax)
delete(usr.images.img)
usr.images.img = uipanel('Parent',usr.images.main,'units','normalized','Position',[0 0 1 1],'ShadowColor',[0.8 0.8 0.8],'ForegroundColor',[0.8 0.8 0.8],'HighlightColor',[0.8 0.8 0.8],'BackgroundColor',[0.8 0.8 0.8]);
usr.images.ax2 = axes('Parent',usr.images.img,'units','normalized');axis off
usr.images.ax = axes('Parent',usr.images.img,'units','normalized');
showObservation(usr.images.ax,obs,usr.file.input.dx,usr.file.input.dx,usr.file.input.obs)
set(tab,'Userdata',usr)

% Show all previously selected options
value = get(usr.figOptions.selImg.listbox,'Value');
options = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
for n=1:size(options,1)
    if nargin==3
        op = options{n,1} & ~strcmp(options{n,2},nameTag);
    else
        op = options{n,1};
    end
    if op
        showHideFigOptions(tab,value,options{n,2},true,h)
    end
end