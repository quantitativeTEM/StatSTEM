function [eps_xx,eps_xy,eps_yy,omg_xy,err] = STEMstrain(coordinates,coor_relaxed,a,b,dirTeta_ab,teta,unit,error_a,error_b)
% STEMstrain - determine the strain from coordinates
%
%   syntax: [coor_ref,types,indices] = STEMdisplacement(coordinates,ref,...
%                                           unit,teta,a,b,space,layLim)
%       coordinates - coordinates [x,y]
%       ref         - reference coordinates [x,y]
%       unit        - structure holding the parameters of the 2D unit cell
%       teta        - structure recording button events
%       a           - a-lattice
%       b           - b-lattice
%       dirTeta_ab  - direction of the angle between a and b (+ or -)
%       space       - maximum distance between found intermediate point and
%                     real coordinate (optional input)
%       layLim      - maximum number of rows and columns of coordinates to find (optional input)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

% Check if all inputs are given
if nargin<9
    error_b = 0;
end
if nargin<8
    error_a = 0;
end

teta_ab = unit.ang;
unit = [unit.coor2D(:,1)*a unit.coor2D(:,2)*b];
% Calculate minimum distance between 2 atoms, use half of this distance for upperlimit when searching for closest point
n_atoms = size(unit(:,1));
if size(unit,1)>1
    distance = sqrt(unit(2:n_atoms,1).^2 + unit(2:n_atoms,2).^2)/2;
else
    distance = min(a/4,b/4);
end
space = min(distance);

% Rotation matrix
R = [cos(teta) -sin(teta);sin(teta) cos(teta)];

% Strain will be calculate in x- and y-direction of the image. For this
% calculation the a and b direction of the sample in view will be used.
% To calculate the strain components per individual atomic column the
% displacement with respect to the first columns in the a and b directions 
% will be used. Both positive and negative a and b directions are used to
% calculate a sort of average strain per point
Rab = [cos(dirTeta_ab*teta_ab) -sin(dirTeta_ab*teta_ab);sin(dirTeta_ab*teta_ab) cos(dirTeta_ab*teta_ab)];
Vstrain = [(R*[a;0])';(R*Rab*[b;0])'];

% Calculate error on strain matrix
Verror = [(R*[error_a;0])';(R*[0;error_b])'];
ad_bc = Vstrain(1,1)*Vstrain(2,2)-Vstrain(1,2)*Vstrain(2,1);
Errad_bc = sqrt(Vstrain(1,1)^2*Verror(2,2)^2 + Vstrain(2,2)^2*Verror(1,1)^2 + ...
    Vstrain(1,2)^2*Verror(2,1)^2 + Vstrain(2,1)^2*Verror(1,2)^2);

invad_bc = 1/ad_bc;
Errinvad_bc = sqrt( (-1/(ad_bc^2))^2*Errad_bc^2 );

Vstrain_re = [Vstrain(2,2) -Vstrain(1,2);-Vstrain(2,1) Vstrain(1,1)];
Verror_re = [Verror(2,2) -Verror(1,2);-Verror(2,1) Verror(1,1)];

% Error on inverse strain matrix
INVV = invad_bc*Vstrain_re;
ErrINVV = sqrt( (invad_bc^2*Verror_re.^2) + Vstrain_re.^2*Errinvad_bc^2 );

n1 = size(coordinates,1);
eps_xx = zeros(n1,1);
eps_xy = zeros(n1,1);
eps_yy = zeros(n1,1);
err.xx = zeros(n1,1);
err.xy = zeros(n1,1);
err.yx = zeros(n1,1);
err.yy = zeros(n1,1);
omg_xy = zeros(n1,1);
for n=1:n1
    u = zeros(2,2);
    e_u = zeros(2,2);
    v = zeros(2,2);
    e_v = zeros(2,2);
    
    % Use ref coodinates to find points in a direction
    dist = sqrt( (coor_relaxed(:,1)-coor_relaxed(n,1)-Vstrain(1,1)).^2 + (coor_relaxed(:,2)-coor_relaxed(n,2)-Vstrain(1,2)).^2 );
    if min(dist)<space
        ind = dist==min(dist);
        if sum(ind)~=1
            ind = find(ind);
            if length(ind)==2
                c = coordinates(ind,1:2);
                error(['Double coordinates found: (',c(1,1),',',c(1,2),') and (',c(2,1),',',c(2,2),')']);
            else
                c = coordinates(ind(1),1:2);
                error(['Multiple coordinates found around: (',c(1,1),',',c(1,2),')']);
            end
        end
        % Reference point exist
        u(1,:) = coordinates(ind,1:2) - coordinates(n,1:2) - Vstrain(1,:);
        e_u(1,:) = sqrt( Verror(1,:).^2 );
    else
        u(1,:) = [NaN;NaN];
        e_u(1,:)  = [NaN;NaN];
    end
    
    % Use ref coodinates to find points in -a direction
    dist = sqrt( (coor_relaxed(:,1)-coor_relaxed(n,1)+Vstrain(1,1)).^2 + (coor_relaxed(:,2)-coor_relaxed(n,2)+Vstrain(1,2)).^2 );
    if min(dist)<space
        ind = dist==min(dist);
        if sum(ind)~=1
            ind = find(ind);
            if length(ind)==2
                c = coordinates(ind,1:2);
                error(['Double coordinates found: (',c(1,1),',',c(1,2),') and (',c(2,1),',',c(2,2),')']);
            else
                c = coordinates(ind(1),1:2);
                error(['Multiple coordinates found around: (',c(1,1),',',c(1,2),')']);
            end
        end
        % Reference point exist
        u(2,:) = coordinates(n,1:2) - coordinates(ind,1:2) - Vstrain(1,:);
        e_u(2,:) = sqrt( Verror(1,:).^2 );
    else
        u(2,:) = [NaN;NaN];
        e_u(2,:)  = [NaN;NaN];
    end
    
    % If possible, average both displacements
    if any(isnan(u))
        u = u(~isnan(u(:,1)),:);
        e_u = e_u(~isnan(e_u(:,1)),:);
    else
        e_u = [sqrt( 1/2*u(1,1)^2*e_u(1,2)^2 + 1/2*u(1,2)^2*e_u(1,1)^2) sqrt( 1/2*u(2,1)^2*e_u(2,2)^2 + 1/2*u(2,2)^2*e_u(2,1)^2)];
        u = [mean(u(:,1)) mean(u(:,2))];
    end
        
    
    % Use ref coodinates to find points in b direction
    dist = sqrt( (coor_relaxed(:,1)-coor_relaxed(n,1)-Vstrain(2,1)).^2 + (coor_relaxed(:,2)-coor_relaxed(n,2)-Vstrain(2,2)).^2 );
    if min(dist)<space
        ind = dist==min(dist);
        if sum(ind)~=1
            ind = find(ind);
            if length(ind)==2
                c = coordinates(ind,1:2);
                error(['Double coordinates found: (',c(1,1),',',c(1,2),') and (',c(2,1),',',c(2,2),')']);
            else
                c = coordinates(ind(1),1:2);
                error(['Multiple coordinates found around: (',c(1,1),',',c(1,2),')']);
            end
        end
        % Reference point exist
        v(1,:) = coordinates(ind,1:2) - coordinates(n,1:2) - Vstrain(2,:);
        e_v(1,:) = sqrt( Verror(2,:).^2 );
    else
        v(1,:) = [NaN;NaN];
        e_v(1,:)  = [NaN;NaN];
    end
    
    % Use ref coodinates to find points in -b direction
    dist = sqrt( (coor_relaxed(:,1)-coor_relaxed(n,1)+Vstrain(2,1)).^2 + (coor_relaxed(:,2)-coor_relaxed(n,2)+Vstrain(2,2)).^2 );
    if min(dist)<space
        ind = dist==min(dist);
        if sum(ind)~=1
            ind = find(ind);
            if length(ind)==2
                c = coordinates(ind,1:2);
                error(['Double coordinates found: (',c(1,1),',',c(1,2),') and (',c(2,1),',',c(2,2),')']);
            else
                c = coordinates(ind(1),1:2);
                error(['Multiple coordinates found around: (',c(1,1),',',c(1,2),')']);
            end
        end
        % Reference point exist
        v(2,:) = coordinates(n,1:2) - coordinates(ind,1:2) - Vstrain(2,:);
        e_v(2,:) = sqrt( Verror(2,:).^2 );
    else
        v(2,:) = [NaN;NaN];
        e_v(2,:)  = [NaN;NaN];
    end
    
    % If possible, average both displacements
    if any(isnan(v))
        v = v(~isnan(v(:,1)),:);
        e_v = e_v(~isnan(e_v(:,1)),:);
    else
        e_v = [sqrt( 1/2*v(1,1)^2*e_v(1,2)^2 + 1/2*v(1,2)^2*e_v(1,1)^2) sqrt( 1/2*v(2,1)^2*e_v(2,2)^2 + 1/2*v(2,2)^2*e_v(2,1)^2)];
        v = [mean(v(:,1)) mean(v(:,2))];
    end
    
    if ~isempty(u) && ~isempty(v)
        D = INVV*[u;v];
        Eerr = [sqrt( u(1)^2*ErrINVV(1,1)^2 + INVV(1,1)^2*e_u(1)^2 + v(1)^2*ErrINVV(1,2)^2 + INVV(1,2)^2*e_v(1)^2 ),...
            sqrt( u(2)^2*ErrINVV(1,1)^2 + INVV(1,1)^2*e_u(2)^2 + v(2)^2*ErrINVV(1,2)^2 + INVV(1,2)^2*e_v(2)^2 );...
            sqrt( u(1)^2*ErrINVV(2,1)^2 + INVV(2,1)^2*e_u(1)^2 + v(1)^2*ErrINVV(2,2)^2 + INVV(2,2)^2*e_v(1)^2 ),...
            sqrt( u(2)^2*ErrINVV(2,1)^2 + INVV(2,1)^2*e_u(2)^2 + v(2)^2*ErrINVV(2,2)^2 + INVV(2,2)^2*e_v(2)^2 )];
    else
        D = [NaN NaN;NaN NaN];
        Eerr = [NaN NaN;NaN NaN];
    end
    E = 1/2*(D+D');
    O = 1/2*(D-D');
    eps_xx(n,1) = E(1,1);
    eps_xy(n,1) = E(2,1);
    eps_yy(n,1) = E(2,2);
    omg_xy(n,1) = O(2,1);
    err.xx(n,1) = Eerr(1,1);
    err.xy(n,1) = Eerr(2,1);
    err.yx(n,1) = Eerr(1,2);
    err.yy(n,1) = Eerr(2,2);
end

% figure;
% minplaneimg = min(min(obs));
% scaledimg = (floor(((obs - minplaneimg) ./ (max(max(obs)) - minplaneimg)) * 255)); 
% colorimg = ind2rgb(scaledimg,gray(256));
% ax_x = dx:dx:size(obs,2)*dx;
% ax_y = dx:dx:size(obs,1)*dy;
% ax_x = ax_x/dx;
% ax_y = ax_y/dy;
% coordinates(:,1) = coordinates(:,1)/dx;
% coordinates(:,2) = coordinates(:,2)/dy;
% imagesc(ax_x,ax_y,colorimg); axis equal off, hold off, colormap jet; colorbar,
% pixels = 1;
% for i=1:n1
%     hold on,
%     imagesc(coordinates(i,1)-pixels:coordinates(i,1)+pixels, coordinates(i,2)-pixels:coordinates(i,2)+pixels,epsxx(i));
% end
% title('\epsilon_x_x')
% caxis([-max(abs(epsxx)),max(abs(epsxx))])
% 
% figure;
% minplaneimg = min(min(obs));
% scaledimg = (floor(((obs - minplaneimg) ./ (max(max(obs)) - minplaneimg)) * 255)); 
% colorimg = ind2rgb(scaledimg,gray(256));
% imagesc(ax_x,ax_y,colorimg); axis equal off, hold off, colormap jet; colorbar,
% % pixels = 1*dx;
% for i=1:n1
%     hold on,
%     imagesc(coordinates(i,1)-pixels:coordinates(i,1)+pixels, coordinates(i,2)-pixels:coordinates(i,2)+pixels,epsxy(i));
% end
% title('\epsilon_x_y')
% caxis([-max(abs(epsxy)),max(abs(epsxy))])
% 
% figure;
% minplaneimg = min(min(obs));
% scaledimg = (floor(((obs - minplaneimg) ./ (max(max(obs)) - minplaneimg)) * 255)); 
% colorimg = ind2rgb(scaledimg,gray(256));
% imagesc(ax_x,ax_y,colorimg); axis equal off, hold off, colormap jet; colorbar,
% % pixels = 1*dx;
% for i=1:n1
%     hold on,
%     imagesc(coordinates(i,1)-pixels:coordinates(i,1)+pixels, coordinates(i,2)-pixels:coordinates(i,2)+pixels,omgxy(i));
% end
% title('\omega_x_y')
% caxis([-max(abs(omgxy)),max(abs(omgxy))])
% 
% figure;
% minplaneimg = min(min(obs));
% scaledimg = (floor(((obs - minplaneimg) ./ (max(max(obs)) - minplaneimg)) * 255)); 
% colorimg = ind2rgb(scaledimg,gray(256));
% imagesc(ax_x,ax_y,colorimg); axis equal off, hold off, colormap jet; colorbar,
% % pixels = 1*dx;
% % pixels = 1*dx;
% for i=1:n1
%     hold on,
%     imagesc(coordinates(i,1)-pixels:coordinates(i,1)+pixels, coordinates(i,2)-pixels:coordinates(i,2)+pixels,epsyy(i));
% end
% title('\epsilon_y_y')
% caxis([-max(abs(epsyy)),max(abs(epsyy))])