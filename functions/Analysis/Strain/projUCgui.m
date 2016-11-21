function [unit,path,e2s] = projUCgui(unit,Name,Value,varargin)
% projUCgui - GUI to update or load 2D unit cell parameters
%
%   syntax: unit = projUCgui(unit)
%       unit  - structure containing all the 2D unit cell parameters
%       path  - pathname to find database
%       e2s   - status indicating whether values are exported to statstem
%       Name  - Name of the property
%       Value - Value of the property
%
%   Parameters of the unit cell are:
%       unit.a    	- a lattice parameter (Å)
%       unit.b   	- b lattice parameter (Å)
%       unit.ang    - angle between a and b lattice (rad)
%       unit.coor2D - relative coordinates in unit cell
%       unit.atom2D - Names of the atoms in unit cell
%
%   Name - Value pairs can be:
%       Name        Value
%       'Center'    Screenlocation of dialog box, 2 x 1 double value (pixels)
%       'PathData'  Path to database
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Inputs of function
if nargin<1
    % Use gold parameters
    unit.a = 4.078;
    unit.b = 4.078;
    unit.ang = 0.5*pi;
    unit.coor2D = zeros(1,2);
    unit.atom2D = repmat({'Au'},1,1);
end

% Standard output
screensize = get( 0, 'Screensize' );
cent = [screensize(3)/2 screensize(4)/2];
path = mfilename('fullpath');
path = path(1:end-9);
if nargin>2
    varargin = {Name,Value,varargin{:}};
end
for n=1:2:nargin-2
    Name  = varargin{n};
    Value = varargin{n+1};
    switch lower(Name)
        case 'center'
            cent = Value;
        case 'pathdata'
            if ~isempty(Value)
                if Value~=0
                    path = Value;
                end
            end
        otherwise
            if isa(Name,'char')
                error(['Invalid property name: ',Name]);
            else
                error('Invalid args')
            end
    end
end

%% Check if input structure is correct, if not use
if any(strcmp(fieldnames(unit),'a'))
    if ~isa(unit.a,'double')
        unit.a = 0;
    end
else
    unit.a = 0;
end
if any(strcmp(fieldnames(unit),'b'))
    if ~isa(unit.b,'double')
        unit.b = 0;
    end
else
    unit.b = 0;
end
if any(strcmp(fieldnames(unit),'ang'))
    if ~isa(unit.ang,'double')
        unit.ang = 0.5*pi;
    end
else
    unit.ang = 0.5*pi;
end
if any(strcmp(fieldnames(unit),'coor2D'))
    if ~isa(unit.coor2D,'double')
        errC2D = 1;
    else
        errC2D = 0;
    end
else
    errC2D = 1;
end
if any(strcmp(fieldnames(unit),'atom2D'))
    if ~isa(unit.atom2D,'cell')
        errA2D = 1;
    else
        errA2D = 0;
    end
else
    errA2D = 1;
end
if errC2D && errA2D
    unit.atom2D = {''};
    unit.coor2D = [0,0];
elseif errC2D
    l = length(unit.atom2D);
    unit.coor2D = zeros(l,2);
elseif errA2D
    l = size(unit.coor2D,1);
    unit.atom2D = repmat({''},l,1);
end

% Check if number of names and coordinates is the same
l1 = size(unit.coor2D,1);
l2 = size(unit.atom2D,1);
if l1~=l2
    if l2>l1
        unit.coor2D = [unit.coor2D,zeros(l2-l1,2)];
        l1 = l2;
    else
        unit.atom2D = [unit.atom2D;repmat({''},l1-l2,1)];
    end
end

% Convert coordinates to cell format and add to atom2D cell
data = cell(l1,3);
for n=1:l1
    data{n,1} = unit.atom2D{n,1};
    data{n,2} = unit.coor2D(n,1);
    data{n,3} = unit.coor2D(n,2);
end

% Rond angle to 4 decimals
angle = round(unit.ang/2/pi*360*10000)/10000;
e2s = 0;

%% Make GUI
s = [304,260];
h.fig = figure('units','pixels','outerposition',[cent(1)-s(1)/2 cent(2)-s(2)/2 s(1) s(2)],'Name','Update projected unit cell','NumberTitle','off','Visible','on','Resize','off','DeleteFCN',@deleteFigure,'MenuBar','none','Color',[0.94,0.94,0.94]);

uicontrol('Parent',h.fig,'Style','Text','String','a (Å)','Position',[10 198 80 22],'BackgroundColor',[0.94,0.94,0.94]);
uicontrol('Parent',h.fig,'Style','Text','String','b (Å)','Position',[110 198 80 22],'BackgroundColor',[0.94,0.94,0.94]);
uicontrol('Parent',h.fig,'Style','Text','String','angle (degrees)','Position',[210 198 80 22],'BackgroundColor',[0.94,0.94,0.94]);
h.editA = uicontrol('Parent',h.fig,'Style','Edit','String',unit.a,'Position',[10 180 80 22],'Callback',{@isVal,unit.a});
h.editB = uicontrol('Parent',h.fig,'Style','Edit','String',unit.b,'Position',[110 180 80 22],'Callback',{@isVal,unit.b});
h.editAng = uicontrol('Parent',h.fig,'Style','Edit','String',angle,'Position',[210 180 80 22],'Callback',{@isVal,angle});

h.tableAt = uitable('Parent',h.fig,'Position',[10 45 190 112],'ColumnFormat',{'char','numeric','numeric'},'Data',data,'ColumnEditable',[true,true,true],'RowName',[],'ColumnName',{'Atoms','x','y'},'ColumnWidth',{54,54,54});
if l1>1
    en = 'on';
else
    en = 'off';
end
delBut = uicontrol('Parent',h.fig,'Style','pushbutton','String','Delete','Position',[210 105 80 22],'Callback',{@delAtom,h.tableAt},'Enable',en);
uicontrol('Parent',h.fig,'Style','pushbutton','String','Clear','Position',[210 75 80 22],'Callback',{@clearAtom,h.tableAt});
uicontrol('Parent',h.fig,'Style','pushbutton','String','New','Position',[210 135 80 22],'Callback',{@addAtom,h.tableAt,delBut});

uicontrol('Parent',h.fig,'Style','pushbutton','String','Export to StatSTEM','Position',[10 10 135 22],'Callback',{@exportVal,h});
uicontrol('Parent',h.fig,'Style','pushbutton','String','Load file','Position',[155 10 135 22],'Callback',{@loadUC,h});
uiwait(h.fig)

    function addAtom(~,~,tab,dBut)
        dat = get(tab,'Data');
        dat = [dat;{'',0,0}];
        set(tab,'Data',dat)
        set(dBut,'Enable','on')
    end

    function delAtom(hO,~,tab)
        dat = get(tab,'Data');
        si = size(dat,1);
        ena = 'on';
        if si>1
            dat = dat(1:end-1,:);
        end
        if si==2
            ena = 'off';
        end
        set(tab,'Data',dat)
        set(hO,'Enable',ena)
    end

    function clearAtom(~,~,tab)
        dat = get(tab,'Data');
        dat = dat(1,:);
        set(tab,'Data',dat)
    end

    function isVal(hObject,~,refVal)
        val = get(hObject,'String');
        val = str2double(val);
        if isnan(val) || val<0
            val = refVal;
            set(hObject,'String',val);
        end
    end

    function loadUC(~,~,h)
        [FileName,path] = uigetfile('.txt','Select a suitable StatSTEM database file',path);
        if FileName==0
            return
        end
        
        % Extract the values from the text file
        fid = fopen([path,filesep,FileName],'rt');
        % Search for parameter
        line = 1;
        a = [];
        b = [];
        ang = [];
        while line~=-1
            line = fgets(fid);
            C = textscan(line,'%s','delimiter',{sprintf('\t'),sprintf(' ')});
            C = C{1,1};
            if strcmp(C{1,1},'length_a')
                a = str2double(C{2,1});
            elseif strcmp(C{1,1},'length_b')
                b = str2double(C{2,1});
            elseif strcmp(C{1,1},'angle_ab')
                ang = str2double(C{2,1});
            end
            if ~isempty(a) && ~isempty(b) && ~isempty(ang)
                break
            end
        end
        
        % Search for coordinates
        st = 0;
        atom = cell(0,0);
        coor = zeros(0,2);
        coorS = cell(0,2);
        k = 0;
        line = fgets(fid);
        while line~=-1
            C = textscan(line,'%s','delimiter',{sprintf('\t'),sprintf(' ')});
            C = C{1,1};
            if st
                if line~=1
                    k = k+1;
                    atom{k,1} = C{1,1};
                    coorS(k,:) = {str2double(C{2,1}),str2double(C{3,1})};
                    coor(k,:) = [str2double(C{2,1}),str2double(C{3,1})];
                end
            end
            
            if size(C,1)>2 && st==0
                if strcmpi(C{1},'atoms') && strcmpi(C{2},'x') && strcmpi(C{3},'y')
                    st = 1;
                end
            end
            
            line = fgets(fid);
        end
        fclose(fid);
        if isempty(a) || isempty(b) || isempty(ang) || isempty(atom) || isempty(coor) 
            h_err = errordlg('Selected file not supported');
            waitfor(h_err)
            return
        end
        
        % Store coordinates in GUI
        unit.a = a;
        unit.b = b;
        unit.ang = ang;
        unit.atom2D = atom;
        unit.coor2D = coor;
        
        % Update GUI components
        set(h.editA,'String',unit.a,'Callback',{@isVal,unit.a});
        set(h.editB,'String',unit.b,'Callback',{@isVal,unit.b});
        set(h.editAng,'String',unit.ang,'Callback',{@isVal,unit.ang});
        set(h.tableAt,'Data',[atom,coorS]);
    end

    function exportVal(~,~,h)
        % Load all values
        unit.a = str2double(get(h.editA,'String'));
        unit.b = str2double(get(h.editB,'String'));
        unit.ang = str2double(get(h.editAng,'String'))/360*2*pi; % Convert to mrad
        
        dat = get(h.tableAt,'Data');
        unit.atom2D = dat(:,1);
        unit.coor2D = cell2mat(dat(:,2:3));
        e2s = 1;
        close(h.fig)
    end
        
    function deleteFigure(hObject,~)
        uiresume(hObject)
        delete(hObject)
    end
end