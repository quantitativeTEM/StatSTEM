function showHideFigOptions(tab,value,option,state,h,sColBar,cAx,cmap)
% showHideFigOptions - Show or hide a figure option
%
%   syntax: showHideFigOptions(tab,value,option,state)
%       tab     - reference to the selected tab
%       value   - Selected figure (number)
%       option  - The selected figure option
%       state   - Logical, indicate whether option should be shown or hiden
%       h       - structure holding references to the StatSTEM interface
%       sColBar - Show colorbar
%       cAx     - colormap limits of axes (optional)
%       cmap    - colormap (optional)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<8
    cmap = [];
end
if nargin<7
    cAx = [];
end
if nargin<6
    % Check if colorbar is shown
    if strcmp(get(h.colorbar(1),'State'),'off')
        sColBar = 0;
    else
        sColBar = 1;
    end
end

% Check matlab version, and switch opengl
v = version('-release');
v = str2double(v(1:4));

usr = get(tab,'Userdata');
userdata = get(get(tab,'Parent'),'Userdata');

scaleMarker = str2double(get(usr.figOptions.optFig.msval,'String'));

reshowCbar = 0;
switch state
    case true
        switch option
            case 'Input coordinates'
                plotCoordinates(usr.images.ax,...
                    usr.file.input.coordinates, option,userdata.pathColor,'.',scaleMarker)
            case 'Fitted coordinates'
                plotCoordinates(usr.images.ax,...
                    [usr.file.output.coordinates(:,1) usr.file.output.coordinates(:,2) usr.file.input.coordinates(:,3)],option,userdata.pathColor,'+',scaleMarker)
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
                plotCoordinates(usr.images.ax, coor, option,userdata.pathColor,'d',scaleMarker)
            case 'Coor strainmapping'
                % Select coordinates (from images), selected by user
                if isempty(usr.fitOpt.strain.selCoor)
                    coor = [usr.file.output.coordinates(:,1) usr.file.output.coordinates(:,2) usr.file.input.coordinates(:,3)];
                else
                    in = inpolygon(usr.file.output.coordinates(:,1), usr.file.output.coordinates(:,2), usr.fitOpt.strain.selCoor(:,1), usr.fitOpt.strain.selCoor(:,2));
                    coor = [usr.file.output.coordinates(in,1) usr.file.output.coordinates(in,2) usr.file.input.coordinates(in,3)];
                end
                
                % Plot
                plotCoordinates(usr.images.ax, coor, option,userdata.pathColor,'d',scaleMarker)
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
            case {'Atom Counts','Lib Counts'}
                % Check if another strain map or counting map is already shown
                data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
                for n=1:size(data,1)
                    if ( strcmp(data{n,2}(1),char(949)) || strcmp(data{n,2}(1),char(969)) || strcmp(data{n,2},'Atom Counts') || strcmp(data{n,2},'Lib Counts') ) && ~strcmp(data{n,2},option)
                        if data{n,1}
                            data{n,1} = false;
                            set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data)
                            deleteImageObject(usr.images.ax,data{n,2})
                        end
                    end
                end
                if strcmp(option,'Atom Counts')
                    coor = usr.file.atomcounting.coordinates;
                    Counts = usr.file.atomcounting.Counts;
                else
                    coor = usr.file.libcounting.coordinates;
                    Counts = usr.file.libcounting.Counts;
                end
                plotAtomCounts(usr.images.ax,usr.images.ax2,coor,Counts,option,scaleMarker,cAx,cmap);
                if sColBar
                    reshowCbar = 1;
                    ylab = 'Number of atoms';
                end
            case 'Library'
                plotLib(usr.images.ax,usr.file.input.library,option);
            case 'Ref strainmapping'
                plotRefCoor(usr.images.ax,usr.file.strainmapping.refCoor,option,scaleMarker)
            case 'Displacement map'
                showDisplacementMap(usr.images.ax,usr.file.strainmapping.coor_sel,usr.file.strainmapping.coor_relaxed,option)
            case {[char(949),'_xx'],[char(949),'_xy'],[char(949),'_yy'],[char(969),'_xy']}
                % Check if another strain map is shown, is so disable it
                data = get(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data');
                for n=1:size(data,1)
                    if ( strcmp(data{n,2}(1),char(949)) || strcmp(data{n,2}(1),char(969)) || strcmp(data{n,2},'Atom Counts') || strcmp(data{n,2},'Lib Counts') ) && ~strcmp(data{n,2},option)
                        if data{n,1}
                            data{n,1} = false;
                            set(usr.figOptions.selOpt.(['optionsImage',num2str(value)]),'Data',data)
                            deleteImageObject(usr.images.ax,data{n,2})
                        end
                    end
                end
                if strcmp(option,[char(949),'_xx'])
                    strainVec = usr.file.strainmapping.eps_xx;
                elseif strcmp(option,[char(949),'_xy'])
                    strainVec = usr.file.strainmapping.eps_xy;
                elseif strcmp(option,[char(949),'_yy'])
                    strainVec = usr.file.strainmapping.eps_yy;
                else 
                    strainVec = usr.file.strainmapping.omg_xy;
                end
                showStrainMap(usr.images.ax,usr.images.ax2,usr.file.strainmapping.coor_sel,strainVec,option,scaleMarker,sColBar,cAx,cmap)
                if sColBar
                    reshowCbar = 1;
                    if strcmp(option(1),char(949))
                        name = '\epsilon';
                    else
                        name = '\omega';
                    end
                    ylab = [name,'_{',option(3:4),'}'];
                end
            case 'a & b lattice'
                teta = usr.file.strainmapping.teta(1);
                R = [cos(teta) sin(teta); -sin(teta) cos(teta)];
                teta_ab = usr.file.strainmapping.dir_teta_ab*usr.file.input.projUnit.ang;
                Rab = [cos(teta_ab) sin(teta_ab); -sin(teta_ab) cos(teta_ab)];
                aDir = R\[usr.file.strainmapping.a(1);0];
                bDir = R\Rab*[usr.file.strainmapping.b(1);0];
                showABlattice(usr.images.ax,usr.file.strainmapping.refCoor,aDir,bDir,option)
        end
    case false
        switch option
            case {'Atom Counts','Lib Counts',[char(949),'_xx'],[char(949),'_xy'],[char(949),'_yy'],[char(969),'_xy']}
                % Colorbar must be removed. Memory leak MATLAB --> remove entire panel and axis
                str = get(usr.figOptions.selImg.listbox,'String');
                val = get(usr.figOptions.selImg.listbox,'Value');
                if v<2015
                    colormap(usr.images.ax,'gray')
                end
                showImage(tab,str{val},h,0)
            case 'Library'
                deleteImageObject(usr.images.ax,option)
                legend(usr.images.ax,'off')
            otherwise
                deleteImageObject(usr.images.ax,option)
        end
end

if reshowCbar
    set(h.colorbar,'State','on')
    insertColorbar(h.colorbar(1),[],h)
end