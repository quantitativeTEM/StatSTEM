function changeMS(hObject,event,tab)
% changeMS - Callback for changing the marker size
%
%   syntax: changeMS(hObject,event,ref)
%       hObject - Reference to object
%       event   - structure recording button events
%       tab     - reference to selected tab
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

str = get(hObject,'String');
scaleMarker = str2double(str);
if isempty(str) || strcmp(str,'-')
    error = 1;
elseif isnan(scaleMarker)
    error = 1;
elseif scaleMarker<0 || abs(scaleMarker)~=scaleMarker
    error = 1;
else
    error = 0;
end

% Load tab userdata
usr = get(tab,'Userdata');

% If the number is incorrect, cancel operation
if error
    set(hObject,'String',usr.oldMarkerSize);
    h_error = errordlg('Error: Please insert a positive number');
    waitfor(h_error)
    return
end

% Check if an image is shown
if strcmp(get(tab,'Title'),'+')
    return
end

% Check if marker size is changed
if usr.oldMarkerSize == scaleMarker
    return
end

% Check which image options are shown
data = get(usr.images.ax,'Userdata');
if ~isempty(data)
    % Input coordinates
    ind = strcmp(data(:,1),'Input coordinates');
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'.',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'MarkerSize',msize);
            end
        end
    end

    % Fitted coordinates
    ind = strcmp(data(:,1),'Fitted coordinates');
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'+',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'MarkerSize',msize);
            end
        end
    end

    % Coor atomcounting
    ind = strcmp(data(:,1),'Coor atomcounting');
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'d',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'MarkerSize',msize);
            end
        end
    end

    % Coor strainmapping
    ind = strcmp(data(:,1),'Coor strainmapping');
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'d',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'MarkerSize',msize);
            end
        end
    end
    
    % Atom Counts
    ind = strcmp(data(:,1),'Atom Counts');
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'s',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'SizeData',msize);
            end
        end
    end

    % Library Counts
    ind = strcmp(data(:,1),'Lib Counts');
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'s',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'SizeData',msize);
            end
        end
    end

    % Reference strainmapping
    ind = strcmp(data(:,1),'Ref strainmapping');
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'x',scaleMarker*2);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'MarkerSize',msize);
            end
        end
    end

    % Strain maps
    ind = strcmp(data(:,1),[char(949),'_xx']);
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'.',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'SizeData',msize);
            end
        end
    end
    ind = strcmp(data(:,1),[char(949),'_xy']);
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'.',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'SizeData',msize);
            end
        end
    end
    ind = strcmp(data(:,1),[char(949),'_yy']);
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'.',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'SizeData',msize);
            end
        end
    end
    ind = strcmp(data(:,1),[char(969),'_xy']);
    h_peaks = data(ind,2);
    if ~isempty(h_peaks)
        msize = coorMarkerSize(usr.images.ax,'.',scaleMarker);
        for i=1:length(h_peaks{1})
            if h_peaks{1}(i)~=0
                set(h_peaks{1}(i),'SizeData',msize);
            end
        end
    end
end

% Update userdata
usr.oldMarkerSize = scaleMarker;
set(tab,'Userdata',usr)