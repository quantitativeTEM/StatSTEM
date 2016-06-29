function showImage(tab,nameTag,h)
% showImage - Show an image in the StatSTEM interface
%
%   In this function all necessary steps are taken to show a specific image
%   in the StatSTEM interface
%
%   syntax: showImage(tab,nameTag,h)
%       tab     - reference to the selected tab
%       nameTag - name of the image
%       h       - structure holding references to the StatSTEM interface
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
if isempty(nameTag)
    return
end

usr = get(tab,'Userdata');

str = get(usr.figOptions.selImg.listbox,'String');
value = find(strcmp(str,nameTag));

% First update selected image
set(usr.figOptions.selImg.listbox,'Value',value);

% Now show the correct figure options panels
set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Enable','on','Visible','on')
oldRow = get(usr.figOptions.selImg.listbox,'Userdata');
if oldRow~=value
    set(usr.figOptions.selOpt.(['optionsImage',num2str(oldRow)]),'Enable','off','Visible','off')
    set(usr.figOptions.selImg.listbox,'Userdata',value);
end

% Delete axes and panel (panel for memory leakage)
delete(usr.images.ax)
delete(usr.images.img)
usr.images.img = uipanel('Parent',usr.images.main,'units','normalized','Position',[0 0 1 1],'ShadowColor',[0.8 0.8 0.8],'ForegroundColor',[0.8 0.8 0.8],'HighlightColor',[0.8 0.8 0.8],'BackgroundColor',[0.8 0.8 0.8]);
usr.images.ax = axes('Parent',usr.images.img,'units','normalized');

% Update userdata
set(tab,'Userdata',usr);

% Now show the figure
switch nameTag
    case 'Observation'
        showObservation(usr.images.ax,usr.file.input.obs,usr.file.input.dx)
    case 'Model'
        showObservation(usr.images.ax,usr.file.output.model,usr.file.input.dx,usr.file.input.dx,usr.file.input.obs)
    case 'Histogram SCS'
        % Select coordinates (from images), selected by user
        if isempty(usr.fitOpt.atom.selCoor)
            vol = usr.file.output.volumes;
        else
            in = inpolygon(usr.file.output.coordinates(:,1), usr.file.output.coordinates(:,2), usr.fitOpt.atom.selCoor(:,1), usr.fitOpt.atom.selCoor(:,2));
            vol = usr.file.output.volumes(in);
        end
        % Select coordinates (from histogram), selected by user
        if ~isempty(usr.fitOpt.atom.minVol) && ~isempty(usr.fitOpt.atom.maxVol)
            in = vol>usr.fitOpt.atom.minVol & vol<usr.fitOpt.atom.maxVol;
            vol = vol(in);
        end
        showHistogram(usr.images.ax,vol,'Scattering cross-section (e^-Å^2)')
    case 'ICL'
        showICL(usr.images.ax,usr.file.atomcounting.ICL)
    case 'SCS vs. Thickness'
        plotThickSI(usr.images.ax,usr.file.atomcounting.estimatedLocations,usr.file.atomcounting.offset)
end
% Now show all the selected figure options
data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
for n=1:size(data,1)
    if data{n,1}
        showHideFigOptions(tab,value,data{n,2},true)
    end
end

% If zooming is turned on, turn it off and on again
zoomReset(h)