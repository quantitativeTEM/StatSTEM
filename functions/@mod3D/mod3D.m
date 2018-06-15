classdef mod3D < StatSTEMfile
% mod3D - Class to hold the parameters of a 3D model
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
    
    properties (SetAccess=private)
        z % Depth location of each coordinate
    end
    properties
        rad % Radius to find coordination number (in Å)
        pForCoor = 100;% Percentage of atoms used to calculate the coordination number 
    end
    
    properties (Dependent)
        Color % RGB color of each coordinate when plotting
        coorNumPos % Variable indicating whether it is possible to determine the coordination number
        % Run getCoorNum to get values
        coorNum % Coordination number of each atom
    end
    
    properties (Hidden, SetAccess = private)
        % Run getCoorNum to get values
        coorNumP = [] % Coordination number of each atom
    end
    
    methods
        obj = getCoorNum(obj)
        export3Dcoor(obj,FileName)
        export3DcoorNum(obj,FileName)
    end
    
    methods
        function obj = mod3D(coordinates,z,types,rad)
            obj.coordinates = coordinates;
            obj.z = z;
            obj.types = types;
            obj.rad = rad;
        end
        
        function createAxes(obj)
            if isempty(obj.GUI)
                ax = gca;
            else
                ax = obj.ax;
            end
            surf(ax,[],[],[],'Tag','Dummy')
        end
            
        function showModel(obj)
            uniTypes = unique(obj.types,'stable');
            colors = obj.Color;
            if isempty(obj.GUI)
                ax = gca;
            else
                ax = obj.ax;
            end
            ms = obj.mscale*1.5;
            [xC,yC,zC] = sphere(9);
            xC = reshape(xC'*ms,1,100);
            yC = reshape(yC'*ms,1,100);
            zC = reshape(zC'*ms,1,100);
            s = zeros(length(uniTypes),1);
            col = zeros(length(uniTypes),3);
            for i=1:length(uniTypes)
                indT = strcmp(obj.types,uniTypes{i});
                colInt = colors(indT,:);
                col(i,:) = colInt(1,:);
                Ncol = sum(indT);
                coorX = repmat(obj.coordinates(indT,1),1,100)+repmat(xC,Ncol,1); %
                coorY = repmat(obj.coordinates(indT,2),1,100)+repmat(yC,Ncol,1); %
                coorZ = repmat(obj.z(indT,1),1,100)+repmat(zC,Ncol,1); %
                coorX = reshape(coorX',10,Ncol*10)';
                coorY = reshape(coorY',10,Ncol*10)';
                coorZ = reshape(coorZ',10,Ncol*10)';
                if i==1
                    hold off
                else
                    hold on
                end
                s(i) = surf(ax,coorX,coorY,coorZ);
                set(s(i),'Userdata',{'Z: %f Å',coorZ})
            end
            shading interp
            % Colors
            for i=1:length(uniTypes)
                set(s(i),'FaceColor',col(i,:),'Tag','Color per type')
            end
            camlight
            lighting phong
            hold off;axis equal
            legend(uniTypes{:})
        end
        
        function val = get.Color(obj)
            uniTypes = unique(obj.types,'stable');
            k=0;
            val = zeros(length(obj.types),3);
            for i=1:length(uniTypes)
                switch uniTypes{i}
                    case 'Au'
                        colors = [212 175 55];
                    case 'Ag'
                        colors = [192 192 192];
                    case 'Pt'
                        colors = [229 228 226];
                    otherwise
                        k=k+1;
                        colors = colorAtoms(i)*255;
                end
                indT = strcmp(obj.types,uniTypes{i});
                val(indT,:) = repmat(colors/255,sum(indT),1);
            end
        end
        
        function obj = set.rad(obj,val)
            obj.rad = val;
            obj.coorNumP = [];
        end
        
        function obj = set.pForCoor(obj,val)
            obj.pForCoor = val;
            obj.coorNumP = [];
        end
        
        function val = get.coorNumPos(obj)
            uniTypes = unique(obj.types,'stable');
            if length(uniTypes)==1
                val = true;
            else
                val = [];
            end
        end
        
        function val = get.coorNum(obj)
            val = obj.coorNumP;
        end

        function showModelCoorNum(obj)
            if isempty(obj.coorNum)
                warning('Coordination number not available')
                return
            end
            if isempty(obj.GUI)
                ax = gca;
            else
                ax = obj.ax;
            end
            ms = obj.mscale*1.5;
            [xC,yC,zC] = sphere(9);
            xC = reshape(xC'*ms,1,100);
            yC = reshape(yC'*ms,1,100);
            zC = reshape(zC'*ms,1,100);
            legNames = cell(1,max(obj.coorNum));
            s = zeros(max(obj.coorNum),1);
            for i=1:max(obj.coorNum)
                indT = obj.coorNum==i;
                Ncol = sum(indT);
                coorX = repmat(obj.coordinates(indT,1),1,100)+repmat(xC,Ncol,1); %
                coorY = repmat(obj.coordinates(indT,2),1,100)+repmat(yC,Ncol,1); %
                coorZ = repmat(obj.z(indT,1),1,100)+repmat(zC,Ncol,1); %
                coorX = reshape(coorX',10,Ncol*10)';
                coorY = reshape(coorY',10,Ncol*10)';
                coorZ = reshape(coorZ',10,Ncol*10)';
                if i==1
                    hold off
                else
                    hold on
                end
                s(i) = surf(ax,coorX,coorY,coorZ);
                set(s(i),'Userdata',{'Z: %f Å',coorZ})
                legNames{i} = num2str(i);
            end
            shading interp
            for i=1:max(obj.coorNum)
                col = getColorCoorNum(obj,i);
                set(s(i),'FaceColor',col(1,:),'Tag','Coordination number')
            end
            camlight
            lighting phong
            hold off;axis equal
            legend(legNames{:})
        end
        
        
        function val = getColorCoorNum(~,num)
            switch num
                case 1
                    colors = [229 25 0];
                case 2
                    colors = [251 123 21];
                case 3
                    colors = [254 178 56];
                case 4
                    colors = [249 220 60];
                case 5
                    colors = [154 239 15];
                case 6
                    colors = [0 255 0];
                case 7
                    colors = [38 253 181];
                case 8
                    colors = [39 252 244];
                case 9
                    colors = [129 178 214];
                case 10
                    colors = [83 124 208];
                case 11
                    colors = [7 65 251];
                case 12
                    colors = [0 0 175];
                otherwise
                    colors = [255 255 255];
            end
            val = colors/255;
        end
        
    end
end
        