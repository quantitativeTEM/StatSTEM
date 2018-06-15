function obj = makeBack(obj)
% makeBack - Make part of the image equal to a background value (to hide
%            images of other nanoparticles which will not be analysed)
%
%   syntax: obj = makeBack(obj)
%       obj - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% First, select background region
% Ask user which image to take, or whether a value will be given
q = questdlg('First an image background value should be given, select an option:','Background value option','Select region in current image','Select region in other image','By value','Select region in current image');

backVal = [];
switch q
    case 'Select region in current image'
        objB = obj;
    case 'Select region in other image'
        [file,message,~] = loadStatSTEMfile();
        if ~isempty(message)
            obj.message = message;
            return
        end
        objB = file.input;
        clear file;
    case 'By value'
        backVal = inputdlg('Give image background value','Background value',1,{'0'});
        backVal = str2double(backVal);
        if isnan(backVal)
            errordlg('Not a real number given, nothing is changed in new image')
            obj.message = 'Not a real number given, nothing is changed in new image';
            return
        elseif isempty(backVal)
            return
        end
    otherwise
        % No appropriate option selected
        obj.message = 'Making part of image equal to the background cancelled';
        return
end

if isempty(backVal)
    if isempty(objB.GUI)
        hB = figure;
        showObservation(objB);
    end
    % Select axis
    ax = gca;
    hold(ax,'on');

    % Start selecting area
    title(ax,'Select region, press ESC to exit')
    coor = gregion_AxInFig();
    title(ax,'')
    hold(ax,'off');
    if ~isempty(coor)
        in = inpolygon(objB.Xreshape,objB.Yreshape,coor(:,1),coor(:,2));
        backVal = mean(objB.reshapeobs(in));
    end
    
    if isempty(objB.GUI)
        close(hB)
    end
    clear objB;
end
if isempty(backVal)
    % Procedure is somewhere cancelled
    obj.message = ['Making part of image equal to the background cancelled'];
    return
end

%% Select region which should be make equal to the background value
if isempty(obj.GUI)
    hf = figure;
    showObservation(obj);
end
   
% Select axis
ax = gca;
hold(ax,'on'); 

% Start selecting area
title(ax,'Select region to make equal to the background value')
coor = gregion_AxInFig();
title(ax,'')
hold(ax,'off');
if ~isempty(coor)
    in = inpolygon(obj.X,obj.Y,coor(:,1),coor(:,2));
    obj.obs = obj.obs.*(~in) + in.*backVal;
    obj.message = ['Background value equal to: ',num2str(backVal),'\nImage intensities in selected region modified'];
else
    obj.message = ['Making part of image equal to the background cancelled'];
end

if isempty(obj.GUI)
    close(hf)
end


