function rho = defineRho(input,Name,Value,varargin)
% defineRho - Open a dialog to define width for different column types
%
% syntax: rho = defineRho(input,Name,Value,...)
%           rho     - the given width per column type
%           input   - input structure with coordinates
%           Name    - Name of the property
%           Value   - Value of the property
%
%   Name - Value pairs can be:
%       Name        Value
%       'Types'      Cell structure with type names
%       'Center'    Screenlocation of dialog box, 2 x 1 double value (pixels)
%       'Rho'       The widths of the different columns
%       

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Standard output
rho = [];
types = [];
screensize = get( 0, 'Screensize' );
cent = [screensize(3)/2 screensize(4)/2];
rho_in = [];
if nargin>1
    varargin = {Name,Value,varargin{:}};
end
for n=1:2:nargin-1
    Name  = varargin{n};
    Value = varargin{n+1};
    switch lower(Name)
        case 'types'
            types = Value;
        case 'center'
            cent = Value;
        case 'rho'
            rho_in = Value;
        otherwise
            if isa(Name,'char')
                error(['Invalid property name: ',Name]);
            else
                error('Invalid args')
            end
    end
end

if size(input.coordinates,2)~=3
    input.coordinates(:,3) = ones(size(input.coordinates,1),1);
end

% Get names for types
Ntypes = max(input.coordinates(:,3));
Ltypes = length(types);
if size(types,1)~=Ltypes
    types = types';
end
if length(types)<Ntypes
    types = [types;cell(Ntypes-Ltypes,1)];
    for n=Ltypes+1:Ntypes
        types{n} = num2str(n);
    end
end
Ntypes = length(types);

% Standard width: 0 angstrom
if size(rho_in,1)~=length(rho_in)
    rho_in = rho_in';
end
if length(rho_in)<Ntypes
    rho_in = [rho_in;zeros(Ntypes-length(rho_in),1)];
else
    rho_in = rho_in(1:Ntypes,1);
end

data = cell(Ntypes,2);
for n=1:Ntypes
    data{n,1} = types{n};
    data{n,2} = rho_in(n);
end
    
% First create a new figure
addPix = 17.8;
if Ntypes>10
    Ntypes = 10;
    addPix = 0;
end
s = [234 125+18.25*Ntypes];
hfig = figure('units','pixels','outerposition',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)],'Name','Edit column width','NumberTitle','off','Visible','on','Resize','off','DeleteFCN',@deleteFigure,'MenuBar','none');

text = uicontrol('Parent',hfig,'Style','Text','String','Modify the width of each atom type:','Position',[10 65+18.25*Ntypes 175 22]);
table = uitable('Parent',hfig,'Position',[10 45 209 18*Ntypes+22],'ColumnFormat',{'char','numeric'},'Data',data,'ColumnEditable',[false true],'RowName',[],'ColumnName',{'Type','Width (Å)'},...
    'ColumnWidth',{70 120+addPix});

saveBut = uicontrol('Parent',hfig,'Style','pushbutton','String','OK','Position',[10 10 100 22],'Callback',{@storeRho,hfig});
cancelBut = uicontrol('Parent',hfig,'Style','pushbutton','String','Cancel','Position',[120 10 100 22],'Callback',{@cancelRho,hfig});

uiwait(hfig)

    function storeRho(hObject,~,hfig)
        values = get(table,'Data');
        values = cell2mat(values(:,2));
        ind = isnan(values);
        if any(ind)
            num = find(ind);
            str = [];
            for m=1:length(num)
                str = [str,num2str(num(m)),', '];
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
        ind = values<0;
        if any(ind)
            num = find(ind);
            str = [];
            for m=1:length(num)
                str = [str,num2str(num(m)),', '];
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
        rho = values;
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