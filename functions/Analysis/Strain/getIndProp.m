function [coor_ref,types,indices,indFound] = getIndProp(coordinates,coor_cen,unitT,teta,a,b,up,n_atoms,layLim,space,ind0)

s = size(coordinates);
coor_ref = zeros(s(1),s(2));
types = zeros(s(1),1);
indices = zeros(s(1),2);
indFound = zeros(s(1),1);
if ind0
    ky=0;
    m=0;
else
    ky=1;
    m=1;
end
R = [cos(teta) -sin(teta);sin(teta) cos(teta)];
unit_rot = ( R*unitT )';  
Rx0=R;
Ry0=R;
stop_b = 0;
v1 = coor_cen';
x = coor_cen(1);
y = coor_cen(2);
fy0 = 1;
fx0 = 1;
teta_x0 = teta;
teta_y0 = teta;
while stop_b~=1 && m<layLim
    v1=v1-Ry0*[0;b*ky];
    % In the negative a-direction
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
                coor_ref(ind,:) = [x y] - (R*[a*n;b*m])' + unit_rot(k,:);
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
%                 if abs(teta_x-teta_int)>0.5*pi
                teta_x = (1-up)*teta_x + up*(teta_int + round( (teta_x-teta_int)/pi )*pi);
%                 else
%                     teta_x = (1-up)*teta_x + up*teta_int;
%                 end
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
%                 if abs(teta_y0-teta_int)>0.5*pi
                teta_y0 = (1-up)*teta_y0 + up*(teta_int + round( (teta_y0-teta_int)/pi )*pi);
%                 else
%                     teta_y0 = (1-up)*teta_y0 + up*teta_int;
%                 end
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
        if n==1;
            % Stop function in next loop
            stop_b = 1;
        end
        
        v= vx_int;
        Rx = Rx0;
        teta_x = teta_x0;
        fx = fx0;
        stop_a = 0;
        n=1;
        while stop_a~=1 && stop_b==0
            % Each time create a new reference atom/point
            v = v+Rx*[a;0];
        
            % Find points
            distance = (coordinates(:,1)-v(1)).^2+(coordinates(:,2)-v(2)).^2;
            if min(distance)<space %Angstrom
                ind = distance==min(distance);
                indFound = indFound + ind*1; % Store indices found, to remove double positions
                coor_ref(ind,:) = [x y] + (R*[a*n;-b*m])' + unit_rot(k,:);
                types(ind) = k; 
                indices(ind,:) = [n,-m];
%                 % plot for checking
%                 quiver(coor_ref(distance==min(distance),1),coor_ref(distance==min(distance),2),coordinates(distance==min(distance),1)-coor_ref(distance==min(distance),1),coordinates(distance==min(distance),2)-coor_ref(distance==min(distance),2),0,'Color','r','MaxHeadSize',4);
                
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
%                 if abs(teta_x-teta_int)>0.5*pi
                teta_x = (1-up)*teta_x + up*(teta_int + round( (teta_x-teta_int)/pi )*pi);
%                 else
%                     teta_x = (1-up)*teta_x + up*teta_int;
%                 end
                Rx = fx*[cos(teta_x) -sin(teta_x);sin(teta_x) cos(teta_x)];
            else
                stop_a=1;
            end
            n=n+1;
        end
    end
    m=m+1;
    ky=1;
%     drawnow
end