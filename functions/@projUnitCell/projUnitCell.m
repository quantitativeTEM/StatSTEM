classdef projUnitCell
    
    properties
        % Standard values are for Au
        a = 4.078; % Lattice parameter a in Å
        b = 4.078; % Lattice parameter b in Å
        c = 4.078; % Lattice parameter c in Å
        ang = 0.5*pi; % Angle between a- and b-direction
        coor2D = [0,0;0.5,0;0,0.5;0.5,0.5]; % Projected 2D coordinates [x,y;...]
        atom2D = {'Au';'Au';'Au';'Au'}; % Names of the column types {'Name';...}
        zInfo = {{'Au',0};{'Au',0.5};{'Au',0.5};{'Au',0}} % Z-Information per column type { {'NameCol1Atom1',zCol1Atom1,'NameCol1Atom2',zCol1Atom2,etc.};{'NameCol2Atom1',zCol2Atom1,'NameCol2Atom2',zCol2Atom2,etc.};...};
    end
    
    methods
        [unit,path,e2s] = projUCgui(unit,Name,Value,varargin)
        unit = zInfoUCgui(unit,Name,Value,varargin)
    end
    
    methods
        function obj = projUnitCell(a,b,ang,coor2D,atom2D,c,zInfo)
            if nargin==0
                % Use gold parameters
            elseif nargin==1 && isa(a,'char') && strcmpi(a,'load')
                obj = projUCgui();
            elseif nargin>4
                obj.a = a;
                obj.b = b;
                obj.ang = ang;
                obj.coor2D = coor2D;
                obj.atom2D = atom2D;
                if nargin>6
                    obj.c = c;
                    obj.zInfo = zInfo;
                else
                    obj.c = 0;
                    obj.zInfo = cell(0,0);
                end
            end
        end
        
        function val = get.zInfo(obj)
            N = length(obj.atom2D);
            if isempty(obj.zInfo)
                val = cell(1,N);
                for i=1:N
                    val{i,1} = {obj.atom2D{i},0};
                end
            else
                % Check if zInfo is available for every atom
                val = obj.zInfo;
                Nz = length(val);
                for i=1:N
                    if i>Nz || isempty(val{i,1})
                        val{i,1} = {obj.atom2D{i},0};
                    end
                end
            end
        end
    end
end
            