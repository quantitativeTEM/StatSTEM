function [indices,types] = STEMindexing(coordinates,ref,unit,teta,a,b,dirTeta_ab,space,method,layLim,up)
% STEMdisplacement - Find relaxed coordinates to make a displacement map
%
%   syntax: [indices,types,coor_ref] = STEMindexing(coordinates,ref,...
%                                           unit,teta,a,b,dirTeta_ab,space,method,layLim,up)
%       indices     - indexed values of coordinates (in terms of distance in number of unit cells in a and b direction)
%       types       - type of coordinates (in terms of atom types present in the projected unit cell "unit"
%       coordinates - coordinates [x,y]
%       ref         - reference coordinates [x,y]
%       unit        - structure holding the parameters of the 2D unit cell
%       teta        - structure recording button events
%       a           - a-lattice
%       b           - b-lattice
%       dirTeta_ab  - direction of the angle between a and b (+ or -)
%       space       - maximum distance between found intermediate point and
%                     real coordinate (optional input)
%       method      - 'all' - try to identify all coordinates, 'lattice' - identify only the coordinates on a crystal lattice, 'allNoWarn' - try to identify all coordinates without warnings
%       layLim      - maximum number of rows and columns of coordinates to find (optional input, standard 100000)
%       up          - update parameter (optional input, standard 0.1)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Preparation
% Select reference coordinates
x = ref(1,1);
y = ref(1,2);

% Crystal parameters
teta_ab = unit.ang;
Rab = [cos(dirTeta_ab*teta_ab) -sin(dirTeta_ab*teta_ab);sin(dirTeta_ab*teta_ab) cos(dirTeta_ab*teta_ab)];
aDir = [a,0];
bDir = (Rab*[b;0])';
unitCoor = unit.coor2D(:,1)*aDir + unit.coor2D(:,2)*bDir;

% Atoms per unit cell
n_atoms = size(unitCoor,1);
% Find atom at position [0 0] and make sure it is the first atom in unit cell (for loop)
ind = find(unitCoor(:,1)==0 & unitCoor(:,2)==0);
unitType = (1:n_atoms)';
if ~isempty(ind)
    if ind~=1
        unitCoor = [unitCoor(ind,:); unitCoor(1:ind-1,:); unitCoor(ind+1:end,:)];
        unit.coor2D = [unit.coor2D(ind,:); unit.coor2D(1:ind-1,:); unit.coor2D(ind+1:end,:)];
        unit.atom2D = [unit.atom2D(ind,:); unit.atomsD(1:ind-1,:); unit.atom2D(ind+1:end,:)];
        unitType = [unitType(ind,:); unitType(1:ind-1,:); unitType(ind+1:end,:)];
    end
else
    errordlg('No atoms in unit cell at (0,0), make sure unit cell is correct')
    return
end

% Calculate minimum distance between 2 atoms, use half of this distance for upperlimit when searching for closest point
if nargin<8 || space==0
    if size(unitCoor,1)>1
        distance = sqrt(unitCoor(2:n_atoms,1).^2 + unitCoor(2:n_atoms,2).^2)/4;
    else
        distance = min(a/4,b/4);
    end
    space = min(distance*2)^2;
else
    space = space^2;
end
if nargin<9
    method = 'all';
end
if nargin<10
    layLim = 100000;
end
if nargin<11
    up = 0.1;
end

%% Relate coordinates with each other by expanding unit cell per unit cell
% Create rotation matrix to expand unit cell
R = [cos(teta) -sin(teta);sin(teta) cos(teta)];

% Unit cell rotation
unit_rot = ( R*unitCoor' )';        
% Transpose unit cell to [x;y]
unitT = unitCoor';

% Construct 2 new vectors
s = size(coordinates);
coor_exp = zeros(s(1),s(2));
types = zeros(s(1),1);
indices = zeros(s(1),2);

% Expand unit cell to the left for n1(1) times and right for n1 and to top for n2(1)
v1=[x;y];
ky=0;
% Create second rotation matrix to relate unit cells from the image more
% easily
teta_x0 = teta;
teta_y0 = teta;
Rx0 = [cos(teta) -sin(teta);sin(teta) cos(teta)];
Ry0 = Rx0;
fy0 = 1;
fx0 = 1;
m=0;
stop_b=0;
% Store indices found, for remove double positions
indFound = zeros(length(coordinates(:,2)),1); 
while stop_b~=1 && m<layLim
    v1=v1-Ry0*[0;b*ky];
    % In the negative a-direction
    stopLoop = zeros(n_atoms,1);
    for k=1:n_atoms % For each atom in the unit cell will be repeated individually
        v = v1 + Rx0*unitT(:,k);
        kx=0; % For displacement
        teta_x = teta_x0;
        fx = fx0;
        Rx = Rx0;
        n=0;
        stop_a = 0;
        while stop_a~=1
            % Each time create a new reference atom/point
            v = v-Rx*[a*kx;0];
            
            % Find points
            distance = (coordinates(:,1)-v(1)).^2+(coordinates(:,2)-v(2)).^2;
            if min(distance)<space %Angstrom
                ind = distance==min(distance);
                indFound = indFound + ind*1; % Store indices found, to remove double positions
                coor_exp(ind,:) = [x y] - (R*[a*n;b*m])' + unit_rot(k,:);
                types(ind) = k;
                indices(ind,:) = [-n,-m];
%                 % plot for checking
%                 quiver(coor_ref(distance==min(distance),1),coor_ref(distance==min(distance),2),coor_sel(distance==min(distance),1)-coor_ref(distance==min(distance),1),coor_sel(distance==min(distance),2)-coor_ref(distance==min(distance),2),0,'Color','b','MaxHeadSize',1);
                
                % Update parameters
                v2 = v + Rx*[a;0]; 
                v = coordinates(ind,:)';
                % modify rotation matrix to dynamically update unit cell displacement with current strain
                if n==0
                    v2 = v + Rx*[a;0];
                end
                v2 = v - v2;
                f_int = sqrt(v2(2)^2+v2(1)^2)/a;
                fx = (1-up)*fx + up*f_int; %Update parameter
                
                % Related angles -pi and pi, update parameter
                teta_int = atan(v2(2)/v2(1));
                if abs(teta_x-teta_int)>0.5*pi
                    teta_x = (1-up)*teta_x + up*(teta_int - sign(teta_int)*pi);
                else
                    teta_x = (1-up)*teta_x + up*teta_int;
                end
                Rx = fx*[cos(teta_x) -sin(teta_x);sin(teta_x) cos(teta_x)];
                
                % Modify rotation matrix at 0 based on first 2 points
                if n==1 && k==1
                    fx0 = fx;
                    teta_x0 = teta_x;
                    Rx0 = Rx;
                end
            else
                stop_a=1;
            end
            
            % Save coordinates for next loop
            if k==1 && n==0
                % modify rotation matrix for movement to the top
                v2 = v1 + Ry0*[0;b];
                v1 = v;                
                v2 = v1-v2;
                % Relate -pi and +pi
                teta_int = atan(-v2(1)/v2(2));
                if abs(teta_y0-teta_int)>0.5*pi
                    teta_y0 = (1-up)*teta_y0 + up*(teta_int - sign(teta_int)*pi);
                else
                    teta_y0 = (1-up)*teta_y0 + up*teta_int;
                end
                fy_int = sqrt(v2(2)^2+v2(1)^2)/b;
                fy0 = (1-up)*fy0 + up*fy_int; %Update parameter
                Ry0 = fy0*[cos(teta_y0) -sin(teta_y0);sin(teta_y0) cos(teta_y0)];

                % For positive a-direction
                vx_int = v;
                
                % To shift unit cell in the negative a-direction
                kx = 1;
            elseif n==0
                % For positive a-direction
                vx_int = v;
                kx = 1;
            end
            n=n+1;
        end
        if n==1
            % Stop function in next loop
            stopLoop(k,1) = 1;
        end
        
        v= vx_int;
        Rx = Rx0;
        teta_x = teta_x0;
        fx = fx0;
        stop_a = 0;
        n=1;
        while stop_a~=1 && stopLoop(k,1)==0
            % Each time create a new reference atom/point
            v = v+Rx*[a;0];
        
            % Find points
            distance = (coordinates(:,1)-v(1)).^2+(coordinates(:,2)-v(2)).^2;
            if min(distance)<space %Angstrom
                ind = distance==min(distance);
                indFound = indFound + ind*1; % Store indices found, to remove double positions
                coor_exp(ind,:) = [x y] + (R*[a*n;-b*m])' + unit_rot(k,:);
                types(ind) = k; 
                indices(ind,:) = [n,-m];
%                 % plot for checking
%                 quiver(coor_ref(distance==min(distance),1),coor_ref(distance==min(distance),2),coor_sel(distance==min(distance),1)-coor_ref(distance==min(distance),1),coor_sel(distance==min(distance),2)-coor_ref(distance==min(distance),2),0,'Color','b','MaxHeadSize',1);
                
                % Update parameters
                v2 = v - Rx*[a;0];
                v = coordinates(ind,:)';
                % modify rotation matrix to dynamically update unit cell displacement with
                % current strain
                v2 = v - v2;
                f_int = sqrt(v2(2)^2+v2(1)^2)/a;
                fx = (1-up)*fx + up*f_int; %Update parameter
                
                % Related angles -pi and pi, update parameter
                teta_int = atan(v2(2)/v2(1));
                if abs(teta_x-teta_int)>0.5*pi
                    teta_x = (1-up)*teta_x + up*(teta_int - sign(teta_int)*pi);
                else
                    teta_x = (1-up)*teta_x + up*teta_int;
                end
                Rx = fx*[cos(teta_x) -sin(teta_x);sin(teta_x) cos(teta_x)];
            else
                stop_a=1;
            end
            n=n+1;
        end
    end
    m=m+1;
    ky=1;
    % Check if loop must be stopped
    if all(stopLoop)
        stop_b = 1;
    end
%     drawnow
end

% Expand to the bottom, reset parameters
v1=[x;y];
teta_x0 = teta;
teta_y0 = teta;
Rx0 = [cos(teta) -sin(teta);sin(teta) cos(teta)];
Ry0 = Rx0;
fx0 = 1;
fy0 = 1;
stop_b=0;
m=1;
while stop_b~=1
    v1=v1-Ry0*[0;-b];

    % In the negative a-direction
    stopLoop = zeros(n_atoms,1);
    for k=1:n_atoms % For each atom in the unit cell will be repeated individually
        v = v1 + Rx0*unitT(:,k);
        kx=0; % For displacement
        teta_x = teta_x0;
        fx = fx0;
        Rx = Rx0;
        stop_a=0;
        n=0;
        while stop_a~=1
            % Each time create a new reference atom/point
            v = v-Rx*[a*kx;0];
            
            % Find points
            distance = (coordinates(:,1)-v(1)).^2+(coordinates(:,2)-v(2)).^2;
            if min(distance)<space %Angstrom
                ind = distance==min(distance);
                indFound = indFound + ind*1; % Store indices found, to remove double positions
                coor_exp(ind,:) = [x y] - (R*[a*n;-b*m])' + unit_rot(k,:);
                types(ind) = k;
                indices(ind,:) = [-n,m];
%                 % plot for checking
%                 quiver(coor_ref(distance==min(distance),1),coor_ref(distance==min(distance),2),coor_sel(distance==min(distance),1)-coor_ref(distance==min(distance),1),coor_sel(distance==min(distance),2)-coor_ref(distance==min(distance),2),0,'Color','b','MaxHeadSize',1);
                
                % Update parameters
                v2 = v + Rx*[a;0]; 
                v = coordinates(ind,:)';
                % modify rotation matrix to dynamically update unit cell displacement with
                % current strain
                if n==0
                    v2 = v + Rx*[a;0];
                end
                v2 = v - v2;
                f_int = sqrt(v2(2)^2+v2(1)^2)/a;
                fx = (1-up)*fx + up*f_int; %Update parameter
                
                % To make sure -pi and +pi are related
                teta_int = atan(v2(2)/v2(1));
                if abs(teta_x-teta_int)>0.5*pi
                    teta_x = (1-up)*teta_x + up*(teta_int - sign(teta_int)*pi);
                else
                    teta_x = (1-up)*teta_x + up*teta_int;
                end
                Rx = fx*[cos(teta_x) -sin(teta_x);sin(teta_x) cos(teta_x)];
                
                % Modify rotation matrix at a=0
                if n==1 && k==1
                    fx0 = fx;
                    teta_x0 = teta_x;
                    Rx0 = Rx;
                end
            else
                stop_a=1;
            end
            
            % Save coordinates for next loop
            if k==1 && n==0
                % modify rotation matrix for movement to the top
                v2 = v1 - Ry0*[0;b];
                v1 = v;                
                v2 = v1-v2;
                
                % Relate -pi and +pi
                teta_int = atan(-v2(1)/v2(2));
                if abs(teta_y0-teta_int)>0.5*pi
                    teta_y0 = (1-up)*teta_y0 + up*(teta_int - sign(teta_int)*pi);
                else
                    teta_y0 = (1-up)*teta_y0 + up*teta_int;
                end
                fy_int = sqrt(v2(2)^2+v2(1)^2)/b;
                fy0 = (1-up)*fy0 + up*fy_int;%Update parameter
                Ry0 = fy0*[cos(teta_y0) -sin(teta_y0);sin(teta_y0) cos(teta_y0)];

                % For positive a-direction
                vx_int = v;
                
                % To shift unit cell in the negative a-direction
                kx = 1;
            elseif n==0
                % For positive a-direction
                vx_int = v;
                kx = 1;
            end
            n=n+1;
        end
        
        if n==1
            % Stop function in next loop
            stopLoop(k,1) = 1;
        end
        
        v= vx_int;
        Rx = Rx0;
        teta_x = teta_x0;
        fx = fx0;
        stop_a=0;
        n=1;
        while stop_a~=1 && stopLoop(k,1)==0
            % Each time create a new reference atom/point
            v = v+Rx*[a;0];
        
            % Find points
            distance = (coordinates(:,1)-v(1)).^2+(coordinates(:,2)-v(2)).^2;
            if min(distance)<space %Angstrom
                ind = distance==min(distance);
                indFound = indFound + ind*1; % Store indices found, to remove double positions
                coor_exp(ind,:) = (R*[a*n;b*m])'+unit_rot(k,:) + [x y];
                types(ind) = k; 
                indices(ind,:) = [n,m];
%                 % plot for checking
%                 quiver(coor_ref(distance==min(distance),1),coor_ref(distance==min(distance),2),coor_sel(distance==min(distance),1)-coor_ref(distance==min(distance),1),coor_sel(distance==min(distance),2)-coor_ref(distance==min(distance),2),0,'Color','b','MaxHeadSize',1);
                
                % Update parameters
                v2 = v - Rx*[a;0];
                v = coordinates(ind,:)';
                % modify rotation matrix to dynamically update unit cell displacement with
                % current strain
                v2 = v - v2;
                f_int = sqrt(v2(2)^2+v2(1)^2)/a;
                fx = (1-up)*fx + up*f_int; %Update parameter
                
                % To make sure -pi and +pi are related
                teta_int = atan(v2(2)/v2(1));
                if abs(teta_x-teta_int)>0.5*pi
                    teta_x = (1-up)*teta_x + up*(teta_int - sign(teta_int)*pi);
                else
                    teta_x = (1-up)*teta_x + up*teta_int;
                end
                Rx = fx*[cos(teta_x) -sin(teta_x);sin(teta_x) cos(teta_x)];
            else
                stop_a=1;
            end
            n=n+1;
        end
    end
    m=m+1;
    
    % Check if loop must be stopped
    if all(stopLoop)
        stop_b = 1;
    end
end
indDouble = find(indFound>1);
for n=1:length(indDouble)
    coor_exp(indDouble(n),:) = [0 0];
    types(indDouble(n)) = 0; 
    indices(indDouble(n),:) = [0 0];
end

if ~any(strcmp({'all','allNoWarn'},method))
    return
end
%% Second method uses neighbouring distances to find the reference coordinate
R = [cos(teta) -sin(teta);sin(teta) cos(teta)];
Rinv = [cos(-teta) -sin(-teta);sin(-teta) cos(-teta)];
R180 = [cos(pi) -sin(pi);sin(pi) cos(pi)];

% Reference unit cell is needed in +a,-a,+b and -b direction
unit_int = zeros(n_atoms*3,3);
ind_int = zeros(n_atoms*3,2);
a_ref = R*[a;0];
b_ref = R*[0;b];
for n=-1:1
    unit_int(n_atoms*(n+1)+1:n_atoms*(n+2),:) = [unit_rot(:,1)+n*a_ref(1) unit_rot(:,2)+n*a_ref(2) (1:n_atoms)'];
    ind_int(n_atoms*(n+1)+1:n_atoms*(n+2),1) = n;
end
unit_ref = zeros(n_atoms*9,3);
ind_unit = zeros(n_atoms*9,2);
for n=-1:1
    unit_ref(n_atoms*3*(n+1)+1:n_atoms*3*(n+2),:) = [unit_int(:,1)+n*b_ref(1) unit_int(:,2)+n*b_ref(2) unit_int(:,3)];
    ind_unit(n_atoms*3*(n+1)+1:n_atoms*3*(n+2),:) = [ind_int(:,1),ind_int(:,2)+n];
end

% Find coordinates which were not found by previous method
ind = find(coor_exp(:,1)==0);
Ntotal = length(ind);
distCoor = zeros(Ntotal,1);
indCoor = zeros(Ntotal,1);
for point=1:Ntotal
    % Select coordinates which were found and which weren't
    coor_rem = coordinates(ind,:);
    ind_not = find(coor_exp(:,1)~=0);
    coor_found = coordinates(ind_not,:);
    ref_found  = coor_exp(ind_not,:);
    types_found = types(ind_not);
    ind_found = indices(ind_not,:);
    
    % Find coordinate closest to another coordinate, repeat process to
    % include also points found by this procedure
    ind_as=0;
    dist = Inf;
    while ind_as<length(ind) && sqrt(min(dist))>sqrt(space)+min(a,b);
        ind_as=ind_as+1;
        dist = (coor_found(:,1)-coor_rem(ind_as,1)).^2 + (coor_found(:,2)-coor_rem(ind_as,2)).^2;
    end
    
    if ind_as==length(ind)
        dist = zeros(length(ind),1);
        % Select closest point and continue
        for n=1:length(ind)
            distance = (coor_found(:,1)-coor_rem(n,1)).^2 + (coor_found(:,2)-coor_rem(n,2)).^2;
            dist(n,1) = min(distance);
        end
        if sqrt(min(dist))>sqrt(space)+max(a,b)
            if ~strcmp(method,'allNoWarn')
                hw = warndlg('Not all points found during iteration');
                waitfor(hw);
            end
%             coordinates = coordinates(coor_ref(1,:)~=0,:);
%             types = types(coor_ref(1,:)~=0,:);
%             coor_ref = coor_ref(coor_ref(1,:)~=0,:);
            break
        end
        
        ind_as = find(dist==min(dist));
        dist = (coor_found(:,1)-coor_rem(ind_as,1)).^2 + (coor_found(:,2)-coor_rem(ind_as,2)).^2;
    end
    
    % Get reference to closest coordinate
    ind_ref = dist == min( dist );
    
    if sum(ind_ref)>2
        if ~strcmp(method,'allNoWarn')
            hw = warndlg('Not all points found during iteration, double coordinates assigned');
            waitfor(hw);
        end
        break
    end
    try
        % Find rotation and expansion around closest coordinate
        [teta_add,f] = retrieveRotExp(ind_ref,ref_found,coor_found,a,b,R,R180,Rinv,space);

        % Rotate and expand unit cell
        R_int = [cos(teta_add) -sin(teta_add);sin(teta_add) cos(teta_add)];
        unit_int = (R_int*(unit_rot'*f))';
        a_int = (R_int*R*[a*f;0])';
        b_int = (R_int*R*[0;b*f])';

        % Repeat unit cell
        unit_temp = zeros(n_atoms*3,2);
        for n=-1:1
            unit_temp(n_atoms*(n+1)+1:n_atoms*(n+2),:) = [unit_int(:,1)+n*a_int(1) unit_int(:,2)+n*a_int(2)];
        end
        unit_comp = zeros(n_atoms*9,2);
        for n=-1:1
            unit_comp(n_atoms*3*(n+1)+1:n_atoms*3*(n+2),:) = [unit_temp(:,1)+n*b_int(1) unit_temp(:,2)+n*b_int(2)];
        end

        % Now correct for location in unit cell
        unit_comp = [unit_comp(:,1)-unit_int(types_found(ind_ref),1) unit_comp(:,2)-unit_int(types_found(ind_ref),2)];

        % Now compare dist with distances of unit cell
        distUnit = coor_rem(ind_as,:)-coor_found(ind_ref,:);
        dif = (unit_comp(:,1)-distUnit(1,1)).^2 + (unit_comp(:,2)-distUnit(1,2)).^2;
        int_typ = unit_ref(dif==min(dif),3);
        int_ind = ind_found(ind_ref,:) + ind_unit(dif==min(dif),:);
        % Check for double coordinates
        ind_double = ind_found(:,1)==int_ind(1,1) & ind_found(:,2)==int_ind(1,2) & types_found == int_typ;
        if sum(ind_double)>0
            coorD = coor_found(ind_double,:);
            % Current point doesn't work, use second closest point to find reference coordinate
            coorFoundND = coor_found(~ind_double,:);
            dist2 = sqrt((coorFoundND(:,1)-coorD(1,1)).^2 + (coorFoundND(:,2)-coorD(1,2)).^2);
            dist = sqrt((coorFoundND(:,1)-coor_rem(ind_as,1)).^2 + (coorFoundND(:,2)-coor_rem(ind_as,2)).^2);
            abM = max(a,b);
            refFoundND = ref_found(~ind_double,:);
            indFoundND = ind_found(~ind_double,:);
            typesFoundND = types_found(~ind_double,:);

            indSel1 = dist2<(abM+space/2);
            indSel2 = dist<(abM+space/2);
            if sum(indSel1)>=sum(indSel2)
                indSel = find(indSel1);
                coorSt = coorD;
                coorFin = coor_rem(ind_as,:);
            else
                indSel = find(indSel2);
                coorSt = coor_rem(ind_as,:);
                coorFin = coorD;
            end
            [avDifSel,avIndSel] = getIndiceFromMulti(indSel,n_atoms,refFoundND,coorFoundND,typesFoundND,indFoundND,a,b,R,R180,Rinv,space,ind_unit,unit_ref,unit_rot,coorSt);

            % Use best option
            ind_temp = coordinates(:,1)==coorSt(1,1) & coordinates(:,2)==coorSt(1,2);
            coor_exp(ind_temp,:) = refFoundND(indSel(1),:) + unit_ref(avDifSel==min(avDifSel),1:2)-unit_rot(typesFoundND(indSel(1)),:);
            types(ind_temp,:) = unit_ref(avDifSel==min(avDifSel),3);
            indices(ind_temp,:) = avIndSel(avDifSel==min(avDifSel),:);

            % Check if option is again not found double
            indDouble1 = indFoundND(:,1)==avIndSel(avDifSel==min(avDifSel),1) & indFoundND(:,2)==avIndSel(avDifSel==min(avDifSel),2) & typesFoundND==unit_ref(avDifSel==min(avDifSel),3);
            if any(indDouble1)
                % Remove option
                coorDouble1 = coorFoundND(indDouble1,:);
                coorFoundND = coorFoundND(~indDouble1,:);
                refFoundND = refFoundND(~indDouble1,:);
                indFoundND = indFoundND(~indDouble1,:);
                typesFoundND = typesFoundND(~indDouble1,:);
            end

            % Add found position to the not double matrices
            coorFoundND = [coorFoundND;coorSt];
            refFoundND = [refFoundND;coor_exp(ind_temp,:)];
            indFoundND = [indFoundND;indices(ind_temp,:)];
            typesFoundND = [typesFoundND;types(ind_temp,:)];

            % Add second position
            dist = sqrt((coorFoundND(:,1)-coorFin(1,1)).^2 + (coorFoundND(:,2)-coorFin(1,2)).^2);
            indSel = find(dist<(abM+space/2));
            [avDifSel,avIndSel] = getIndiceFromMulti(indSel,n_atoms,refFoundND,coorFoundND,typesFoundND,indFoundND,a,b,R,R180,Rinv,space,ind_unit,unit_ref,unit_rot,coorFin);

            % Use best option
            ind_temp = coordinates(:,1)==coorFin(1,1) & coordinates(:,2)==coorFin(1,2);
            coor_exp(ind_temp,:) = refFoundND(indSel(1),:) + unit_ref(avDifSel==min(avDifSel),1:2)-unit_rot(typesFoundND(indSel(1)),:);
            types(ind_temp,:) = unit_ref(avDifSel==min(avDifSel),3);
            indices(ind_temp,:) = avIndSel(avDifSel==min(avDifSel),:);

            % Check if option is again not found double
            indDouble2 = indFoundND(:,1)==avIndSel(avDifSel==min(avDifSel),1) & indFoundND(:,2)==avIndSel(avDifSel==min(avDifSel),2) & typesFoundND==unit_ref(avDifSel==min(avDifSel),3);
            if any(indDouble2)
                % Remove option
                coorDouble2 = coorFoundND(indDouble2,:);
                coorFoundND = coorFoundND(~indDouble2,:);
                refFoundND = refFoundND(~indDouble2,:);
                indFoundND = indFoundND(~indDouble2,:);
                typesFoundND = typesFoundND(~indDouble2,:);
            end

            % Add found position to the not double matrices
            coorFoundND = [coorFoundND;coorFin];
            refFoundND = [refFoundND;coor_exp(ind_temp,:)];
            indFoundND = [indFoundND;indices(ind_temp,:)];
            typesFoundND = [typesFoundND;types(ind_temp,:)];

            count = 0;
            coorFin1 = [Inf Inf];
            coorFin2 = [Inf Inf];
            avDifFin1 = [Inf,Inf];
            avDifFin2 = [Inf,Inf];
            avIndFin1 = [Inf Inf];
            avIndFin2 = [Inf Inf];
            while (any(indDouble1) || any(indDouble2)) && count<20
                count = count+1;
                if any(indDouble1)
                    % Add second position
                    dist = sqrt((coorFoundND(:,1)-coorDouble1(1,1)).^2 + (coorFoundND(:,2)-coorDouble1(1,2)).^2);
                    indSel = find(dist<(abM+space/2));
                    [avDifSel,avIndSel] = getIndiceFromMulti(indSel,n_atoms,refFoundND,coorFoundND,typesFoundND,indFoundND,a,b,R,R180,Rinv,space,ind_unit,unit_ref,unit_rot,coorDouble1);


                    % Check if option is again not found double
                    indDouble1 = indFoundND(:,1)==avIndSel(avDifSel==min(avDifSel),1) & indFoundND(:,2)==avIndSel(avDifSel==min(avDifSel),2) & typesFoundND==unit_ref(avDifSel==min(avDifSel),3);

                    % Use best option
                    ind_temp = coordinates(:,1)==coorDouble1(1,1) & coordinates(:,2)==coorDouble1(1,2);
                    coor_exp(ind_temp,:) = refFoundND(indSel(1),:) + unit_ref(avDifSel==min(avDifSel),1:2)-unit_rot(typesFoundND(indSel(1)),:);
                    types(ind_temp,:) = unit_ref(avDifSel==min(avDifSel),3);
                    indices(ind_temp,:) = avIndSel(avDifSel==min(avDifSel),:);
                    % Check if point are repeatively found
                    coorFin1Old = coorFin1;
                    avDifFin1Old = avDifFin1;
                    avIndFin1Old = avIndFin1;
                    coorFin1 = coorDouble1;
                    avDifFin1 = avDifSel;
                    avIndFin1 = avIndSel;
                    if any(indDouble1) && sum(coorFin1Old-coorDouble1)<eps;
                        % Use best second option
                        if min(avDifFin1Old)<min(avDifFin1) %Keep old value, update latest found values
                            avDif = avDifFin1;
                            avInd = avIndFin1;
                            coor1 = coorFin1;
                        else %Update old value, keep latest found values
                            avDif = avDifFin1Old;
                            avInd = avIndFin1Old;
                            coor1 = coorFin1Old;
                        end
                        arrangeAvDif = sort(avDif,'ascend');
                        indMin = avDif==arrangeAvDif(2);
                        % Check if this option is again not found double
                        indDouble1 = indFoundND(:,1)==avInd(indMin,1) & indFoundND(:,2)==avInd(indMin,2) & typesFoundND==unit_ref(indMin,3);

                        % Update values
                        ind_temp2 = coordinates(:,1)==coor1(1,1) & coordinates(:,2)==coor1(1,2);
                        coor_exp(ind_temp2,:) = coor_exp(ind_temp2,:) -  unit_ref(avDif==min(avDif),1:2) +  unit_ref(indMin,1:2);% - unit_rot(types(ind_temp,:),:) + unit_rot(unit_ref(indMin,3),:);
                        types(ind_temp2,:) = unit_ref(indMin,3);
                        indices(ind_temp2,:) = avInd(indMin,:);

                        % Update values
                        if min(avDifFin1Old)<min(avDifFin1) %Keep old value, update latest found values
                            ind_temp = ind_temp2;
                        else %Update old value, keep latest found values
                            refFoundND(end,:) = coor_exp(ind_temp2,:);
                            indFoundND(end,:) = indices(ind_temp2,:);
                            typesFoundND(end,:) = types(ind_temp2,:);
                        end
                    end
                    if any(indDouble1)
                        % Remove option
                        coorDouble1 = coorFoundND(indDouble1,:);
                        coorFoundND = coorFoundND(~indDouble1,:);
                        refFoundND = refFoundND(~indDouble1,:);
                        indFoundND = indFoundND(~indDouble1,:);
                        typesFoundND = typesFoundND(~indDouble1,:);
                    end

                    % Add found position to the not double matrices
                    coorFoundND = [coorFoundND;coorFin1];
                    refFoundND = [refFoundND;coor_exp(ind_temp,:)];
                    indFoundND = [indFoundND;indices(ind_temp,:)];
                    typesFoundND = [typesFoundND;types(ind_temp,:)];
                end
                if any(indDouble2)
                    % Add second position
                    dist = sqrt((coorFoundND(:,1)-coorDouble2(1,1)).^2 + (coorFoundND(:,2)-coorDouble2(1,2)).^2);
                    indSel = find(dist<(abM+space/2));
                    [avDifSel,avIndSel] = getIndiceFromMulti(indSel,n_atoms,refFoundND,coorFoundND,typesFoundND,indFoundND,a,b,R,R180,Rinv,space,ind_unit,unit_ref,unit_rot,coorDouble2);

                    % Check if option is again not found double
                    indDouble2 = indFoundND(:,1)==avIndSel(avDifSel==min(avDifSel),1) & indFoundND(:,2)==avIndSel(avDifSel==min(avDifSel),2) & typesFoundND==unit_ref(avDifSel==min(avDifSel),3);

                    % Use best option
                    ind_temp = coordinates(:,1)==coorDouble2(1,1) & coordinates(:,2)==coorDouble2(1,2);
                    coor_exp(ind_temp,:) = refFoundND(indSel(1),:) + unit_ref(avDifSel==min(avDifSel),1:2)-unit_rot(typesFoundND(indSel(1)),:);
                    types(ind_temp,:) = unit_ref(avDifSel==min(avDifSel),3);
                    indices(ind_temp,:) = avIndSel(avDifSel==min(avDifSel),:);
                    % Check if point are repeatively found
                    coorFin2Old = coorFin2;
                    avDifFin2Old = avDifFin2;
                    avIndFin2Old = avIndFin2;
                    coorFin2 = coorDouble2;
                    avDifFin2 = avDifSel;
                    avIndFin2 = avIndSel;
                    if any(indDouble2) && sum(coorFin2Old-coorDouble2)<eps;
                        % Use best second option
                        if min(avDifFin2Old)<min(avDifFin2) %Keep old value, update latest found values
                            avDif = avDifFin2;
                            avInd = avIndFin2;
                            coor2 = coorFin2;
                        else %Update old value, keep latest found values
                            avDif = avDifFin2Old;
                            avInd = avIndFin2Old;
                            coor2 = coorFin2Old;
                        end
                        arrangeAvDif = sort(avDif,'ascend');
                        indMin = avDif==arrangeAvDif(2);
                        % Check if this option is again not found double
                        indDouble2 = indFoundND(:,1)==avInd(indMin,1) & indFoundND(:,2)==avInd(indMin,2) & typesFoundND==unit_ref(indMin,3);

                        % Update values
                        ind_temp2 = coordinates(:,1)==coor2(1,1) & coordinates(:,2)==coor2(1,2);
                        coor_exp(ind_temp2,:) = coor_exp(ind_temp2,:) -  unit_ref(avDif==min(avDif),1:2) +  unit_ref(indMin,1:2);% - unit_rot(types(ind_temp,:),:) + unit_rot(unit_ref(indMin,3),:);
                        types(ind_temp2,:) = unit_ref(indMin,3);
                        indices(ind_temp2,:) = avInd(indMin,:);

                        % Update values
                        if min(avDifFin2Old)<min(avDifFin2) %Keep old value, update latest found values
                            ind_temp = ind_temp2;
                        else %Update old value, keep latest found values
                            refFoundND(end,:) = coor_exp(ind_temp2,:);
                            indFoundND(end,:) = indices(ind_temp2,:);
                            typesFoundND(end,:) = types(ind_temp2,:);
                        end
                    end
                    if any(indDouble2)
                        % Remove option
                        coorDouble2 = coorFoundND(indDouble2,:);
                        coorFoundND = coorFoundND(~indDouble2,:);
                        refFoundND = refFoundND(~indDouble2,:);
                        indFoundND = indFoundND(~indDouble2,:);
                        typesFoundND = typesFoundND(~indDouble2,:);
                    end

                    % Add found position to the not double matrices
                    coorFoundND = [coorFoundND;coorFin2];
                    refFoundND = [refFoundND;coor_exp(ind_temp,:)];
                    indFoundND = [indFoundND;indices(ind_temp,:)];
                    typesFoundND = [typesFoundND;types(ind_temp,:)];
                end
            end
        else
            ind_temp = coordinates(:,1)==coor_rem(ind_as,1) & coordinates(:,2)==coor_rem(ind_as,2);
            coor_exp(ind_temp,:) = ref_found(ind_ref,:) + unit_ref(dif==min(dif),1:2)-unit_rot(types_found(ind_ref),:);
            types(ind_temp,:) = int_typ;
            indices(ind_temp,:) = int_ind;
        end
        ind = find(coor_exp(:,1)==0); % For next loop
    
    catch
        if ~strcmp(method,'allNoWarn')
            hw = warndlg('Not all points found during iteration, double coordinates assigned');
            waitfor(hw);
        end
        break
    end
    
%     string = ['(',num2str(point),'/',num2str(Ntotal),')'];
%     waitbar(point/Ntotal,hwait,string);
end

% Update type because of the rearrangement in the beginning
for n=1:n_atoms
    ind = types==n;
    types(ind,:) = -unitType(n);
end
types = -types;

function [teta_add,f] = retrieveRotExp(ind_ref,ref_found,coor_found,a,b,R,R180,Rinv,space)

    % Find rotation and expansion around closest coordinate
    % a-direction
    f = zeros(4,1);
    teta_add = zeros(4,1);
    got_it = 0;
    for n=3:-1:1 % +a-direction
        coor_int = ref_found(ind_ref,:) + (R*[n*a;0])';
        % Find real coordinate to calculate angle and displacement
        dist = (ref_found(:,1)-coor_int(1)).^2 + (ref_found(:,2)-coor_int(2)).^2;
        if min(dist)<space
            coor_int = ( Rinv * ( coor_found(dist==min(dist),:) - coor_found(ind_ref,:) )' )';
            % Find rotation and expansion
            teta_add(1,1) = atan2(coor_int(2),coor_int(1));
            f(1,1) = sqrt(coor_int(1)^2 + coor_int(2)^2)/n/a;
            got_it = 1;
        end
        if got_it
            break
        end
    end
    got_it = 0;
    for n=3:-1:1 % -a direction
        coor_int = ref_found(ind_ref,:) - (R*[n*a;0])';
        % Find real coordinate to calculate angle and displacement
        dist = (ref_found(:,1)-coor_int(1)).^2 + (ref_found(:,2)-coor_int(2)).^2;
        if min(dist)<space
            coor_int = ( R180 * Rinv * ( coor_found(dist==min(dist),:) - coor_found(ind_ref,:))' )';
            % Find rotation and expansion
            teta_add(2,1) = atan2(coor_int(2),coor_int(1));
            f(2,1) = sqrt(coor_int(1)^2 + coor_int(2)^2)/n/a;
            got_it = 1;
        end
        if got_it
            break
        end
    end
    got_it = 0;
    for n=3:-1:1 % +b direction
        coor_int = ref_found(ind_ref,:) + (R*[0;n*b])';
        % Find real coordinate to calculate angle and displacement
        dist = (ref_found(:,1)-coor_int(1)).^2 + (ref_found(:,2)-coor_int(2)).^2;
        if min(dist)<space
            coor_int = ( Rinv * ( coor_found(dist==min(dist),:) - coor_found(ind_ref,:) )' )';
            % Find rotation and expansion
            teta_add(3,1) = -atan2(coor_int(1),coor_int(2));
            f(3,1) = sqrt(coor_int(1)^2 + coor_int(2)^2)/n/b;
            got_it = 1;
        end
        if got_it
            break
        end
    end
    got_it = 0;
    for n=3:-1:1 % -b direction
        coor_int = ref_found(ind_ref,:) - (R*[0;n*b])';
        % Find real coordinate to calculate angle and displacement
        dist = (ref_found(:,1)-coor_int(1)).^2 + (ref_found(:,2)-coor_int(2)).^2;
        if min(dist)<space
            coor_int = ( R180 * Rinv * ( coor_found(dist==min(dist),:) - coor_found(ind_ref,:) )' )';
            % Find rotation and expansion
            teta_add(4,1) = -atan2(coor_int(1),coor_int(2));
            f(4,1) = sqrt(coor_int(1)^2 + coor_int(2)^2)/n/b;
            got_it = 1;
        end
        if got_it
            break
        end
    end

    % Now delete empty entries
    teta_add = teta_add(f~=0);
    f = f(f~=0);
    if isempty(f)
        % If nothing was found use initial angles and displacement
        teta_add = 0;
        f = 1;
    else
        % If some angles were found, use average for not found angles
        teta_add = mean(teta_add);
        f = mean(f);
    end
    
function [avDifSel,avIndSel] = getIndiceFromMulti(indSel,n_atoms,refFoundND,coorFoundND,typesFoundND,indFoundND,a,b,R,R180,Rinv,space,ind_unit,unit_ref,unit_rot,coorSt)
    Nsel1 = length(indSel);
    difSel = zeros(9*n_atoms,Nsel1);
    indOptSel = zeros(9*n_atoms,2,Nsel1);
    typeSel = zeros(9*n_atoms,Nsel1);
    for k=1:Nsel1
        [teta_add,f] = retrieveRotExp(indSel(k),refFoundND,coorFoundND,a,b,R,R180,Rinv,space);
        % Rotate and expand unit cell
        R_int = [cos(teta_add) -sin(teta_add);sin(teta_add) cos(teta_add)];
        unit_int = (R_int*(unit_rot'*f))';
        a_int = (R_int*R*[a*f;0])';
        b_int = (R_int*R*[0;b*f])';

        % Repeat unit cell
        unit_temp = zeros(n_atoms*3,2);
        for n=-1:1
            unit_temp(n_atoms*(n+1)+1:n_atoms*(n+2),:) = [unit_int(:,1)+n*a_int(1) unit_int(:,2)+n*a_int(2)];
        end
        unit_comp = zeros(n_atoms*9,2);
        for n=-1:1
            unit_comp(n_atoms*3*(n+1)+1:n_atoms*3*(n+2),:) = [unit_temp(:,1)+n*b_int(1) unit_temp(:,2)+n*b_int(2)];
        end
        % Now correct for location in unit cell
        typeIntRef = typesFoundND(indSel(k),:);
        unit_comp = [unit_comp(:,1)-unit_int(typeIntRef,1) unit_comp(:,2)-unit_int(typeIntRef,2)];

        % Now compare dist with distances of unit cell
        distSel = coorSt-coorFoundND(indSel(k),:);
        difSel(:,k) = (unit_comp(:,1)-distSel(1,1)).^2 + (unit_comp(:,2)-distSel(1,2)).^2;
        indOptSel(:,:,k) = [ind_unit(:,1)+indFoundND(indSel(k),1),ind_unit(:,2)+indFoundND(indSel(k),2)];
        typeSel(:,k) = unit_ref(:,3);
    end
    % Find the average distance of the different indices
    avDifSel = zeros(9*n_atoms,2);
    avIndSel = indOptSel(:,:,1);
    for n=1:Nsel1
        for k=1:9*n_atoms
            indAvDifSel = indOptSel(:,1,n)==indOptSel(k,1,1) & indOptSel(:,2,n)==indOptSel(k,2,1) & typeSel(:,1)==typeSel(k,1);
            if any(indAvDifSel)
                avDifSel(k,1) = avDifSel(k,1)+difSel(indAvDifSel,n);
                avDifSel(k,2) = avDifSel(k,2)+1;
            end
        end
    end
    avDifSel = avDifSel(:,1)./avDifSel(:,2);
