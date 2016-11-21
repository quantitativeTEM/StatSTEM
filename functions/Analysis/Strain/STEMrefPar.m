function [teta,e_teta,a,e_a,b,e_b] = STEMrefPar(coordinates,ref,teta_start,a,b,teta_ab,dirTeta_ab,n_units,space)
% STEMrefPar - Find directions of a and b-direction by fitting
%
%   syntax: [teta,e_teta,a,e_a,b,e_b] = STEMrefPar(coordinates,ref,...
%                                           teta_start,a,b,teta_ab,n_units,space)
%       coordinates - coordinates from which direction must be found [x,y]
%       ref         - reference coordinate [x,y]
%       teta_start  - initial guess of angle a-lattice
%       a           - a lattice parameter
%       b           - b lattice parameter
%       teta_ab     - angle between a and b lattice parameter (mrad)
%       dirTeta_ab  - direction of the angle between a and b (+ or -)
%       n_units     - Number of unit cells used for fitting
%       teta        - Measured angle of a lattice direction
%       e_teta      - Error on measured angle
%       e_a         - Error on measured a lattice parameter
%       e_b         - Error on measured b lattice parameter
%       space       - Distance to find closest values (optional)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

%% Get start parameters
x = ref(1,1);
y = ref(1,2);

if nargin<9
    space = min([a/4,b/4]);
end

R = [cos(teta_start) -sin(teta_start);sin(teta_start) cos(teta_start)];
dist_a = (R*[a; 0])';
Rab = [cos(dirTeta_ab*teta_ab) -sin(dirTeta_ab*teta_ab);sin(dirTeta_ab*teta_ab) cos(dirTeta_ab*teta_ab)];
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

%% Fit to find all parameters
if nargout==2
    start = [teta_start,0,0];
    options = optimset('lsqnonlin');
    options.Display = 'none';
    [EstPar,~,residual,~,~,~,jacobian] = lsqnonlin('planes',start,[],[],options,coor_ref,ref,ref_num,teta_ab,a,b);
    ci = nlparci(EstPar,residual,jacobian);

    teta = EstPar(1); e_teta = ci(1,2)-EstPar(1);
else
    start = [teta_start,0,0,a,b];
    options = optimset('lsqnonlin');
    options.Display = 'none';
    [EstPar,~,residual,~,~,~,jacobian] = lsqnonlin('planes',start,[],[],options,coor_ref,ref,ref_num,teta_ab);
    ci = nlparci(EstPar,residual,jacobian);

    teta = EstPar(1); e_teta = ci(1,2)-EstPar(1);
    a = EstPar(4); e_a = ci(4,2)-EstPar(4);
    b = EstPar(5); e_b = ci(5,2)-EstPar(5);
end
    