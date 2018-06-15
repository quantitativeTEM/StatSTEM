function names = typeNames(names,Name,Value,varargin)
% typeNames - Open a dialog to define a name for different column types
%
% syntax: names = typeNames(names,Name,Value,...)
%           names   - the given names per column type
%           Name    - Name of the property
%           Value   - Value of the property
%
%   Name - Value pairs can be:
%       Name        Value
%       'Center'    Screenlocation of dialog box, 2 x 1 double value (pixels)
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Standard output
screensize = get( 0, 'Screensize' );
cent = [screensize(3)/2 screensize(4)/2];
if nargin>1
    varargin = {Name,Value,varargin{:}};
end
for n=1:2:nargin-1
    Name  = varargin{n};
    Value = varargin{n+1};
    switch lower(Name)
        case 'center'
            cent = Value;
        otherwise
            if isa(Name,'char')
                error(['Invalid property name: ',Name]);
            else
                error('Invalid args')
            end
    end
end

% Get names for types
if isa(names,'char')
    names = {names};
end

Ntypes = length(names);
if size(names,1)~=1 && size(names,2)~=1
    error('Invalid names, must be a (n x 1) vector')
elseif size(names,1) ~= Ntypes
    names = names';
end

% Data for table
data = [names,names];
    
% First create a new figure
addPix = 17.8;
if Ntypes>10
    Ntypes = 10;
    addPix = 0;
end
s = [234 125+18.25*Ntypes];
hfig = figure('units','pixels','outerposition',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)],'Name','Edit type names','NumberTitle','off','Visible','on','Resize','off','DeleteFCN',@deleteFigure,'MenuBar','none');

uicontrol('Parent',hfig,'Style','Text','String','Modify the names of each column type:','Position',[10 65+18.25*Ntypes 195 22]);
table = uitable('Parent',hfig,'Position',[10 45 209 18*Ntypes+22],'ColumnFormat',{'char','numeric'},'Data',data,'ColumnEditable',[false true],'RowName',[],'ColumnName',{'Old names','New names'},...
    'ColumnWidth',{95+addPix/2 95+addPix/2});

uicontrol('Parent',hfig,'Style','pushbutton','String','OK','Position',[10 10 100 22],'Callback',{@storeNames,hfig});
uicontrol('Parent',hfig,'Style','pushbutton','String','Cancel','Position',[120 10 100 22],'Callback',{@cancelRho,hfig});

uiwait(hfig)

    function storeNames(hObject,~,hfig)
        values = get(table,'Data');
        names = values(:,2);
        close(hfig)
    end

    function cancelRho(hObject,~,hfig)
        close(hfig)
    end
        
    function deleteFigure(hObject,~)
        uiresume(hObject)
        delete(hObject)
    end
end