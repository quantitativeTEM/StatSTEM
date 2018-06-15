function input = defineRho(input,Name,Value,varargin)
% defineRho - Open a dialog to define width for different column types
%
% syntax: rho = defineRho(input,Name,Value,...)
%           rho     - the given width per column type
%           input   - inputStatSTEM file
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
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if ~isempty(input.GUI)
    % Get position GUI, to center dialog
    pos = get(input.GUI,'Position');
    cent = [pos(1)+pos(3)/2 pos(2)+pos(4)/2];
else
    screensize = get( 0, 'Screensize' );
    cent = [screensize(3)/2 screensize(4)/2];
end

% Standard output
types = input.types;
rho_in = input.rhoT;
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

% Standard width: 0 angstrom
Nr = length(rho_in);
Nt = length(types);
if Nr<Nt
    rho_in = [rho_in;zeros(Nt-Nr,1)];
else
    rho_in = rho_in(1:Nt,1);
end

data = cell(Nt,2);
for n=1:Nt
    data{n,1} = types{n};
    data{n,2} = rho_in(n);
end
    
% First create a new figure
addPix = 17.8;
if Nt>10
    Nt = 10;
    addPix = 0;
end
s = [234 125+18.25*Nt];
hfig = figure('units','pixels','outerposition',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)],'Name','Edit column width','NumberTitle','off','Visible','on','Resize','off','DeleteFCN',@deleteFigure,'MenuBar','none');

text = uicontrol('Parent',hfig,'Style','Text','String','Modify the width of each atom type:','Position',[10 65+18.25*Nt 175 22]);
table = uitable('Parent',hfig,'Position',[10 45 209 18*Nt+22],'ColumnFormat',{'char','numeric'},'Data',data,'ColumnEditable',[false true],'RowName',[],'ColumnName',{'Type',['Width (',char(197),')']},...
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
        input.rhoT = values;
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