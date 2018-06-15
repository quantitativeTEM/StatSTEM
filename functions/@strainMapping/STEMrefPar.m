function strainmapping = STEMrefPar(strainmapping)
% STEMrefPar - Find directions of a and b-direction by fitting
%
%   syntax: strainmapping = STEMrefPar(strainmapping)
%       strainmapping - strainMapping file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Get start parameters
coordinates = strainmapping.coordinates(:,1:2);
ref = strainmapping.refCoor;
x = ref(1,1);
y = ref(1,2);
teta_start = strainmapping.teta;
a = strainmapping.projUnit.a;
b = strainmapping.projUnit.b;
teta_ab = strainmapping.projUnit.ang;
dirTeta = strainmapping.dirTeta;
n_units = strainmapping.nUC;
space = strainmapping.space;

R = [cos(teta_start) -sin(teta_start);sin(teta_start) cos(teta_start)];
dist_a = (R*[a; 0])';
Rab = [cos(dirTeta*teta_ab) -sin(dirTeta*teta_ab);sin(dirTeta*teta_ab) cos(dirTeta*teta_ab)];
dist_b = (Rab*R*[b;0])';

% First get all points
N = 1+4*(n_units*(n_units+1)/2);
% Get reference numbers
ref_num = zeros(N,2);
coor_ref = zeros(N,2);
k=1;
for n=-n_units:n_units
    for m=-(n_units-abs(n)):(n_units-abs(n))
        ref_num(k,:) = [m,n];
        coor_ref(k,:) = [x,y] + m*dist_a + n*dist_b;
        k=k+1;
    end
end

for n=0:n_units % Move in +b direction
    in = ref_num(:,1)==0 & ref_num(:,2)==n-1;
    coor_int = coor_ref(in,:)+dist_b;
    distance = (coordinates(:,1)-coor_int(1)).^2+(coordinates(:,2)-coor_int(2)).^2;
    in = ref_num(:,1)==0 & ref_num(:,2)==n;
    if min(distance)<space
        coor_ref(in,:) = coordinates(distance==min(distance),:);
    else
        coor_ref(in,:) = [Inf Inf];
    end
    
    
%     if max_a==n_units
%         Nmaxa = max_a-n;
%     else
%         Nmaxa = min(max_a,n_units-n);
%     end
    for m=1:n_units-n
        % Now go in + a-drection
        in = ref_num(:,1)==m-1 & ref_num(:,2)==n;
        coor_int = coor_ref(in,:)+dist_a;
        distance = (coordinates(:,1)-coor_int(1)).^2+(coordinates(:,2)-coor_int(2)).^2;
        in = ref_num(:,1)==m & ref_num(:,2)==n;
        if min(distance)<space
            coor_ref(in,:) = coordinates(distance==min(distance),:);
        else
            coor_ref(in,:) = [Inf Inf];
        end
        
        % Now go in - a-drection
        in = ref_num(:,1)==-m+1 & ref_num(:,2)==n;
        coor_int = coor_ref(in,:)-dist_a;
        distance = (coordinates(:,1)-coor_int(1)).^2+(coordinates(:,2)-coor_int(2)).^2;
        in = ref_num(:,1)==-m & ref_num(:,2)==n;
        if min(distance)<space
            coor_ref(in,:) = coordinates(distance==min(distance),:);
        else
            coor_ref(in,:) = [Inf Inf];
        end
    end
end

for n=1:n_units % Move in -b direction
    in = ref_num(:,1)==0 & ref_num(:,2)==-n+1;
    coor_int = coor_ref(in,:)-dist_b;
    distance = (coordinates(:,1)-coor_int(1)).^2+(coordinates(:,2)-coor_int(2)).^2;
    in = ref_num(:,1)==0 & ref_num(:,2)==-n;
    if min(distance)<space
        coor_ref(in,:) = coordinates(distance==min(distance),:);
    else
        coor_ref(in,:) = [Inf Inf];
    end
    
    for m=1:n_units-n
        % Now go in + a-drection
        in = ref_num(:,1)==m-1 & ref_num(:,2)==-n;
        coor_int = coor_ref(in,:)+dist_a;
        distance = (coordinates(:,1)-coor_int(1)).^2+(coordinates(:,2)-coor_int(2)).^2;
        in = ref_num(:,1)==m & ref_num(:,2)==-n;
        if min(distance)<space
            coor_ref(in,:) = coordinates(distance==min(distance),:);
        else
            coor_ref(in,:) = [Inf Inf];
        end
        
        % Now go in - a-drection
        in = ref_num(:,1)==-m+1 & ref_num(:,2)==-n;
        coor_int = coor_ref(in,:)-dist_a;
        distance = (coordinates(:,1)-coor_int(1)).^2+(coordinates(:,2)-coor_int(2)).^2;
        in = ref_num(:,1)==-m & ref_num(:,2)==-n;
        if min(distance)<space
            coor_ref(in,:) = coordinates(distance==min(distance),:);
        else
            coor_ref(in,:) = [Inf Inf];
        end
    end
end

% Now delete points outside image
in = coor_ref(:,1)~=Inf;
ref_num = ref_num(in,:);
coor_ref = coor_ref(in,:);

%% Fit to find parameters
if strainmapping.fitABang
    start = [teta_start,0,0];
    options = optimset('lsqnonlin');
    options.Display = 'none';
    [EstPar,~,residual,~,~,~,jacobian] = lsqnonlin('planes',start,[],[],options,coor_ref,ref,ref_num,teta_ab,dirTeta,a,b);
    ci = nlparci(EstPar,residual,jacobian);

    strainmapping.tetaP = EstPar(1); 
    strainmapping.errTetaP = ci(1,2)-EstPar(1);
    strainmapping.aP = a;
    strainmapping.bP = b;
else
    start = [teta_start,0,0,a,b];
    options = optimset('lsqnonlin');
    options.Display = 'none';
    [EstPar,~,residual,~,~,~,jacobian] = lsqnonlin('planes',start,[],[],options,coor_ref,ref,ref_num,teta_ab,dirTeta);
    ci = nlparci(EstPar,residual,jacobian);

    strainmapping.tetaP = EstPar(1); 
    strainmapping.errTetaP = ci(1,2)-EstPar(1);
    strainmapping.aP = EstPar(4); 
    strainmapping.errAP = ci(4,2)-EstPar(4);
    strainmapping.bP = EstPar(5); 
    strainmapping.errBP = ci(5,2)-EstPar(5);
end

function FUN = planes(par,coordinates,ref,indices,teta_ab,dirTeta,a,b)
% planes - function to find the angle of the lattice by fitting
%
%   syntax: FUN = planes(par,coordinates,ref,indices,teta_ab,a,b)
%       FUN         - Difference between model and coordinates
%       par         - vector to fit (ang, offset a, offset b, a, b)
%       coordinates - the coordinates [x,y]
%       ref         - the reference coordinate [x,y]
%       indices     - indices of the coordinates (in function of a and b)
%       teta_ab     - angle between a- and b-direction (mrad)
%       a           - a-lattice
%       b           - b-lattice
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

ang = par(1);
offa = par(2);
offb = par(3);
if nargin<7
    a = par(4);
    b = par(5);
end

%% a- and b-direction
R = [cos(ang) -sin(ang);sin(ang) cos(ang)];
Rab = [cos(dirTeta*teta_ab) -sin(dirTeta*teta_ab);sin(dirTeta*teta_ab) cos(dirTeta*teta_ab)];
aDir = (R*[a;0])';
bDir = (Rab*R*[b;0])';

% Create model coordinates
coorMod = indices(:,1)*aDir + indices(:,2)*bDir;

% Find central coordinate
coorMod = [coorMod(:,1) + ref(1,1) + offa , coorMod(:,2) + ref(1,2) + offb];

FUN = coorMod-coordinates;