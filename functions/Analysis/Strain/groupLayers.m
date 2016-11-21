function out = groupLayers(coordinates,a,b,ang_ab,alimit,blimit,Radd)
% 

if nargin<4
    ang_ab = 0.5*pi;
end
if nargin<5
    alimit = 10000;
end
if nargin<6
    blimit = 10000;
end
if nargin<7
    Radd = 0;
end
Rab = [cos(ang_ab) -sin(ang_ab);sin(ang_ab) cos(ang_ab)];

%% Rotate crystal
% Find most central coordinates and find rotation
ang = zeros(4,1);
dist = sqrt( (coordinates(:,1)-mean(coordinates(:,1)) ).^2 + (coordinates(:,2)-mean(coordinates(:,2)) ).^2 );
ind = find(dist==min(dist));
% a-dir - positive
distPa = sqrt( (coordinates(:,1)-coordinates(ind,1) ).^2 + (coordinates(:,2)-coordinates(ind,2) ).^2 );
indCa = find( abs(distPa-a)==min(abs(distPa-a)) );
aDir = coordinates(indCa(1),:) - coordinates(ind,:);
ang(1,1) = atan(aDir(2)/aDir(1))-0.5*pi;
% a-dir - negative
distNa = sqrt( (coordinates(:,1)-coordinates(ind,1)+aDir(1) ).^2 + (coordinates(:,2)-coordinates(ind,2)+aDir(2) ).^2 );
indCa2 = find( distNa==min(distNa) );
aDir2 = coordinates(indCa2(1),:) - coordinates(ind,:);
ang(2,1) = atan(aDir2(2)/aDir2(1))-0.5*pi;
% b-dir - positive
intDir = (Rab*aDir')'*b/a;
distPb = sqrt( (coordinates(:,1)-coordinates(ind,1)-intDir(1) ).^2 + (coordinates(:,2)-coordinates(ind,2)-intDir(2) ).^2 );
indCb = find( distPb==min(distPb) );
bDir = coordinates(indCb(1),:) - coordinates(ind,:);
ang(3,1) = atan(bDir(2)/bDir(1));
% b-dir - negative
distNb = sqrt( (coordinates(:,1)-coordinates(ind,1)+intDir(1) ).^2 + (coordinates(:,2)-coordinates(ind,2)+intDir(2) ).^2 );
indCb2 = find( distNb==min(distNb) );
bDir2 = coordinates(indCb2(1),:) - coordinates(ind,:);
ang(4,1) = atan(bDir2(2)/bDir2(1));
% Rotate crystal by mean angle
out.ang = mean(ang)+Radd;
R = [cos(out.ang) -sin(out.ang);sin(out.ang) cos(out.ang)];
coorRot = (R\coordinates')';
L = length(coorRot(:,1));
% plot(coorRot(:,1),coorRot(:,2),'m+')
% hold on

%% Find layers in a-direction
ind_found = false(L,1);
indices = zeros(L,2);
n=0;
space = 0.4*a;
while sum(ind_found)~=L && n<alimit
    n=n+1;
    ind = find( coorRot(:,2)==min(coorRot(~ind_found,2)) );
    coor_int = coorRot(ind(1),:);
    ind_int = coorRot(:,2)>=coor_int(1,2) & coorRot(:,2)<coor_int(1,2)+space;
    ind_found = ind_found | ind_int;
    indices(ind_int,1) = n;
%     plot(coorRot(ind_int,1),coorRot(ind_int,2),'b+')
%     waitforbuttonpress
end

%% Find layers in b-direction
ind_found = false(L,1);
m=0;
space = 0.4*b;
while sum(ind_found)~=L && n<alimit
    m=m+1;
    ind = find( coorRot(:,1)==min(coorRot(~ind_found,1)) );
    coor_int = coorRot(ind(1),:);
    ind_int = coorRot(:,1)>=coor_int(1,1) & coorRot(:,1)<coor_int(1,1)+space;
    ind_found = ind_found | ind_int;
    indices(ind_int,2) = m;
%     plot(coorRot(ind_int,1),coorRot(ind_int,2),'b+')
%     waitforbuttonpress
end

out.indices = indices;



