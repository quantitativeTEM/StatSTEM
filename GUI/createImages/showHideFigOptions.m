function showHideFigOptions(tab,value,option,state)
% showHideFigOptions - Show or hide a figure option
%
%   syntax: showHideFigOptions(tab,value,option,state)
%       tab    - reference to the selected tab
%       value  - Selected figure (number)
%       option - The selected figure option
%       state  - Logical, indicate whether option should be shown or hiden
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

usr = get(tab,'Userdata');

switch state
    case true
        switch option
            case 'Input coordinates'
                plotCoordinates(usr.images.ax,...
                    usr.file.input.coordinates, option,'.')
            case 'Fitted coordinates'
                plotCoordinates(usr.images.ax,...
                    [usr.file.output.coordinates(:,1) usr.file.output.coordinates(:,2) usr.file.input.coordinates(:,3)],option,'+')
            case 'Coor atomcounting'
                % Select coordinates (from images), selected by user
                if isempty(usr.fitOpt.atom.selCoor)
                    coor = [usr.file.output.coordinates(:,1) usr.file.output.coordinates(:,2) usr.file.input.coordinates(:,3)];
                    vol = usr.file.output.volumes;
                else
                    in = inpolygon(usr.file.output.coordinates(:,1), usr.file.output.coordinates(:,2), usr.fitOpt.atom.selCoor(:,1), usr.fitOpt.atom.selCoor(:,2));
                    coor = [usr.file.output.coordinates(in,1) usr.file.output.coordinates(in,2) usr.file.input.coordinates(in,3)];
                    vol = usr.file.output.volumes(in);
                end
                % Select coordinates (from histogram), selected by user
                if ~isempty(usr.fitOpt.atom.minVol) && ~isempty(usr.fitOpt.atom.maxVol)
                    in = vol>usr.fitOpt.atom.minVol & vol<usr.fitOpt.atom.maxVol;
                    coor = coor(in,:);
                end
                % Select coordinates based on type
                if ~isempty(usr.fitOpt.atom.selType)
                    in = coor(:,3) == usr.fitOpt.atom.selType;
                    coor = coor(in,:);
                end
                
                % Plot
                plotCoordinates(usr.images.ax, coor, option,'d')
            case 'TTest Ref Area'
                showArea(usr.images.ax,...
                    usr.file.analysis.ttest.reference.posArea,option)
            case 'TTest Area'
                showArea(usr.images.ax,...
                    usr.file.analysis.ttest.selection.posArea,option)
            case 'Minimum ICL'
                plotMinICL(usr.images.ax,[usr.file.atomcounting.selMin usr.file.atomcounting.ICL(usr.file.atomcounting.selMin)])
            case 'GMM components'
                bins = getBinsHist(usr.images.ax);
                [x,GMM] = calcGMM(usr.file.atomcounting,bins);
                plotGMMcomp(usr.images.ax,x,GMM,usr.file.atomcounting.offset)
            case 'GMM'
                bins = getBinsHist(usr.images.ax);
                [x,GMM] = calcGMM(usr.file.atomcounting,bins);
                plotGMM(usr.images.ax,x,sum(GMM,1))
            case 'Atom Counts'
                usr = plotAtomCounts(tab,usr.file.atomcounting.coordinates,usr.file.atomcounting.Counts);
                set(tab,'Userdata',usr);
            case 'Library'
                plotLib(usr.images.ax,usr.file.input.library,option);
        end
    case false
        switch option
            case 'Atom Counts'
                str = get(usr.figOptions.selImg.listbox,'String');
                if strcmp(str{value},'Observation')
                    obs = usr.file.input.obs;
                elseif strcmp(str{value},'Model')
                    obs = usr.file.output.model;
                end
                deleteAtomCounts(tab,obs)
            case 'Library'
                deleteImageObject(usr.images.ax,option)
                legend(usr.images.ax,'off')
            otherwise
                deleteImageObject(usr.images.ax,option)
        end
end