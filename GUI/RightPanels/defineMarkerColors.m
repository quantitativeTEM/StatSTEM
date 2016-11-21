function colors = defineMarkerColors(types,colors,Name,Value,varargin)
% defineMarkerColors - Open a dialog to define colors for different column types
%
% syntax: colors = defineMarkerColors(types,colors)
%           colors - the marker color used to show each different type (cell format)
%           types  - the different column types (cell format)
%           Name    - Name of the property
%           Value   - Value of the property
%
% When the number of colors does not match with the number of column types,
% colors will be repeatively used for the different column types.
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

% Check input
if ~isa(types,'cell')
    error('Invalid input structure of types argument')
end
if ~isa(colors,'cell')
    error('Invalid input structure of colors argument')
end


% Standard output
screensize = get( 0, 'Screensize' );
cent = [screensize(3)/2 screensize(4)/2];
if nargin>2
    varargin = {Name,Value,varargin{:}};
end
for n=1:2:nargin-2
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

l1 = length(types);
c1 = size(colors,1);
c2 = size(colors,2);
if size(types)~=l1
    types = types';
end
if c1==1 && c2~=1 && isa(colors{1,1},'char')
    colors = colors';
    c1 = size(colors,1);
end
if l1>c1
    rep = ceil(l1/c1);
    colors = repmat(colors,rep,1);
    colors = colors(1:l1,:);
elseif c1>l1
    types = [types;cell(c1-l1,1)];
    for n=l1+1:c1
        types{n,1} = num2str(n);
    end
    l1 = c1;
end
Ntypes = l1;
% Construct data for GUI
data = [types,colors];

% First create a new figure
addPix = 17.8;
if Ntypes>10
    Ntypes = 10;
    addPix = 0;
end

%check if input is in char a rgb format
if size(colors,2)==1
    RGB = 0;
    cnames = {'Type','Color'};
    cedit = [false true];
    cformat = {'char','char'};
    cwidth = {70 120+addPix};
elseif size(colors,2)==3
    RGB = 1;
    cnames = {'Type','R','G','B'};
    cedit = [false true true true];
    cformat = {'char','numeric','numeric','numeric'};
    cwidth = {70 (120+addPix)/3 (120+addPix)/3 (120+addPix)/3};
else
    error('Invalid input structure of colors argument')
end

s = [234 145+18.25*Ntypes];
hfig = figure('units','pixels','outerposition',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)],'Name','Edit marker colors','NumberTitle','off','Visible','on','Resize','off','DeleteFCN',@deleteFigure,'MenuBar','none','Color',[0.94,0.94,0.94]);
text = uicontrol('Parent',hfig,'Style','Text','String','Used marker colors for each atom type','Position',[10 90+18.25*Ntypes 193 22],'BackgroundColor',[0.94,0.94,0.94]);
colortext = uicontrol('Parent',hfig,'Style','Text','String','Color Mode:','Position',[10 65+18.25*Ntypes 64 22],'BackgroundColor',[0.94,0.94,0.94]);
colorSTR = uicontrol('Parent',hfig,'Style','togglebutton','String','String','Position',[90 70+18.25*Ntypes 64 22],'Value',~RGB);
colorRGB = uicontrol('Parent',hfig,'Style','togglebutton','String','RGB','Position',[154 70+18.25*Ntypes 64 22],'Value',RGB);
table = uitable('Parent',hfig,'Position',[10 45 209 18*Ntypes+22],'ColumnFormat',cformat,'Data',data,'ColumnEditable',cedit,'RowName',[],'ColumnName',cnames,...
    'ColumnWidth',cwidth);

saveBut = uicontrol('Parent',hfig,'Style','pushbutton','String','OK','Position',[10 10 100 22],'Callback',{@storeColor,hfig});
cancelBut = uicontrol('Parent',hfig,'Style','pushbutton','String','Cancel','Position',[120 10 100 22],'Callback',{@cancelColor,hfig});

set(colorSTR,'Callback',{@rgb2str,colorRGB})
set(colorRGB,'Callback',{@str2rgb,colorSTR})
uiwait(hfig)

    function rgb2str(hObject,~,but2)
        val = get(hObject,'Value');
        set(but2,'Value',~val)
        dat = get(table,'Data');
        if val
            dat = convert2STR(dat);
            ColumnName = {'Type','Color'};
            ColumnWidth = {70 120+addPix};
            ColumnFormat = {'char','char'};
        else
            dat = convert2RGB(dat);
            ColumnName = {'Type','R','G','B'};
            ColumnWidth = {70 (120+addPix)/3 (120+addPix)/3 (120+addPix)/3};
            ColumnFormat = {'char','numeric','numeric','numeric'};
        end
        set(table,'Data',dat,'ColumnName',ColumnName,'ColumnWidth',ColumnWidth,'ColumnFormat',ColumnFormat)
    end

    function str2rgb(hObject,~,but2)
        val = get(hObject,'Value');
        set(but2,'Value',~val)
        dat = get(table,'Data');
        if val
            dat = convert2RGB(dat);
            ColumnName = {'Type','R','G','B'};
            ColumnWidth = {70 (120+addPix)/3 (120+addPix)/3 (120+addPix)/3};
            ColumnFormat = {'char','numeric','numeric','numeric'};
        else
            dat = convert2STR(dat);
            ColumnName = {'Type','Color'};
            ColumnWidth = {70 120+addPix};
            ColumnFormat = {'char','char'};
        end
        set(table,'Data',dat,'ColumnName',ColumnName,'ColumnWidth',ColumnWidth,'ColumnFormat',ColumnFormat)
    end

    function newdat = convert2RGB(dat)
        newdat = cell(size(dat,1),4);
        newdat(:,1) = dat(:,1);
        for k=1:size(dat,1)
            if strcmp(dat{k,2},'y')
                newdat{k,2} = 255;
                newdat{k,3} = 255;
                newdat{k,4} = 0;
            elseif strcmp(dat{k,2},'m')
                newdat{k,2} = 255;
                newdat{k,3} = 0;
                newdat{k,4} = 255;
            elseif strcmp(dat{k,2},'c')
                newdat{k,2} = 0;
                newdat{k,3} = 255;
                newdat{k,4} = 255;
            elseif strcmp(dat{k,2},'r')
                newdat{k,2} = 255;
                newdat{k,3} = 0;
                newdat{k,4} = 0;
            elseif strcmp(dat{k,2},'g')
                newdat{k,2} = 0;
                newdat{k,3} = 255;
                newdat{k,4} = 0;
            elseif strcmp(dat{k,2},'b')
                newdat{k,2} = 0;
                newdat{k,3} = 0;
                newdat{k,4} = 255;
            elseif strcmp(dat{k,2},'w')
                newdat{k,2} = 255;
                newdat{k,3} = 255;
                newdat{k,4} = 255;
            elseif strcmp(dat{k,2},'k')
                newdat{k,2} = 0;
                newdat{k,3} = 0;
                newdat{k,4} = 0;
            else
                newdat{k,2} = NaN;
                newdat{k,3} = NaN;
                newdat{k,4} = NaN;
            end
        end
    end

    function newdat = convert2STR(dat)
        newdat = cell(size(dat,1),2);
        newdat(:,1) = dat(:,1);
        for k=1:size(dat,1)
            if dat{k,2}==255 && dat{k,3}==255 && dat{k,4}==0
                newdat{k,2} = 'y';
            elseif dat{k,2}==255 && dat{k,3}==0 && dat{k,4}==255
                newdat{k,2} = 'm';
            elseif dat{k,2}==0 && dat{k,3}==255 && dat{k,4}==255
                newdat{k,2} = 'c';
            elseif dat{k,2}==255 && dat{k,3}==0 && dat{k,4}==0
                newdat{k,2} = 'r';
            elseif dat{k,2}==0 && dat{k,3}==255 && dat{k,4}==0
                newdat{k,2} = 'g';
            elseif dat{k,2}==0 && dat{k,3}==0 && dat{k,4}==255
                newdat{k,2} = 'b';
            elseif dat{k,2}==255 && dat{k,3}==255 && dat{k,4}==255
                newdat{k,2} = 'w';
            elseif dat{k,2}==0 && dat{k,3}==0 && dat{k,4}==0
                newdat{k,2} = 'k';
            else
                newdat{k,2} = '';
            end
        end
    end


    function storeColor(hObject,~,hfig)
        dat = get(table,'Data');
        if size(dat,2)~=4
            % Convert all values to RGB and check if all values are correct
            dat = convert2RGB(dat);
        end
        
        % Check if al
        
        val = cell2mat(dat(:,2:4));
        ind = isnan(val(:,1)) | isnan(val(:,2)) | isnan(val(:,3));
        if any(ind)
            num = find(ind);
            str = [];
            for m=1:length(num)
                str = [str,dat{(num(m)),1},', '];
            end
            str = str(1:end-2);
            if m==1
                str = ['Error: the given width for type ',str,' is not a number'];
            else
                str = ['Error: the given width for types ',str,' are not numbers'];
            end
            errordlg(str)
            return
        end
        ind = val(:,1)<0 | val(:,2)<0 | val(:,3)<0;
        if any(ind)
            num = find(ind);
            str = [];
            for m=1:length(num)
                str = [str,dat{(num(m)),1},', '];
            end
            str = str(1:end-2);
            if m==1
                str = ['Error: the given width for type ',str,' is negative'];
            else
                str = ['Error: the given width for types ',str,' are negative'];
            end
            errordlg(str)
            return
        end
        ind = val(:,1)>255 | val(:,2)>255 | val(:,2)>255;
        if any(ind)
            num = find(ind);
            str = [];
            for m=1:length(num)
                str = [str,dat{(num(m)),1},', '];
            end
            str = str(1:end-2);
            if m==1
                str = ['Error: the given width for type ',str,' is too high'];
            else
                str = ['Error: the given width for types ',str,' are too high'];
            end
            errordlg(str)
            return
        end
        colors = dat(:,2:4);
        close(hfig)
    end

    function cancelColor(hObject,~,hfig)
        close(hfig)
    end
        
    function deleteFigure(hObject,~)
        uiresume(hObject)
        delete(hObject)
    end
end