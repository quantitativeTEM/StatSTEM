function h = quiverColor(x,y,u,v,scale,ax,RGBvec)
% quiverColor - Make a quiver map with colored arrows
%
% syntax: h = quiverColor(x,y,u,v,scale,RGBvec)
%   x      - x-coordinates
%   y      - y-coordinates
%   u      - displacement in x
%   v      - displacement in y
%   scale  - length of the arrows (optional, standard equal to 1)
%   RGBvec - RGB vector containing colors for each displacement arrow (optional)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<5
    scale = 1;
end
mag = sqrt(u.^2+v.^2);
N = length(mag);
ang   = atan2(v,u);
magN = mag/max(mag);
if nargin<7
    cmap = jet(256);
    c_x = linspace(0,max(mag),size(cmap,1));
    RGBvec = getRGBvec(cmap,c_x,mag,'exact');
end

% Convert RGB vector to appropriate length for patches
RGBvecP = zeros(7*N,3);
for i=1:N
    RGBvecP( (1+7*(i-1)):7*i ,:) = repmat(RGBvec(i,:),7,1);
end

%% Create arrows
Ax = [0;0;0.6;0.5;1;0.5;0.6]*scale;
Ay = [-0.15;0.15;0.15;0.4;0;-0.4;-0.15]*scale;

Ax = repmat(Ax,1,N);
Ax(1,:) = 0.5-magN'*0.5;
Ax(2,:) = 0.5-magN'*0.5;
Ax = Ax -repmat(0.5-magN'*0.5,7,1); % - Ax(5,:);%
Ay = repmat(Ay,1,N);

% Rotate arrows
Vx = Ax.*repmat(cos(ang'),7,1)-Ay.*repmat(sin(ang'),7,1);
Vy = Ax.*repmat(sin(ang'),7,1)+Ay.*repmat(cos(ang'),7,1);

% Put arrows at correct place
Vx = Vx + repmat(x',7,1);
Vy = Vy + repmat(y',7,1);

Vx = reshape(Vx,N*7,1);
Vy = reshape(Vy,N*7,1);

Faces = 1:7*N; Faces = reshape(Faces,7,N)';

%% Create quiver map
if nargin<6
    ax = gca;
end
cr = caxis(ax);
axes(ax)
p = patch(Vx,Vy,[0 0 0],'Visible','off');
set(p,'Faces',Faces,'FaceColor','flat','FaceVertexCData',RGBvecP,'Visible','on');
caxis(ax,cr)
if nargout>0
    h = p;
end