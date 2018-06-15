function Box = calcBoxSize(obs,coordinates,dx,zeta)
% calcBoxSize - Determine size of box to cut out from image for fitting
%
%   syntax: Box = calcBoxSize(obs,coordinates,dx,zeta)
%       obs - the observation
%       coordinates - the coordinates
%       dx          - the pixel size
%       zeta        - background value (for negative or positive contrast)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<4
    zeta = 0;
end

% Refine size of box per atom type, start from original
if size(coordinates,2)==2
    coordinates(:,3) = ones(size(coordinates,1),1);
end

% If only 1 coordinates is given use entire observation to fit
if size(coordinates,1)==1
    Box = Inf;
    return
end


% Calculate different size per atom type
Box = zeros(max(coordinates(:,3)),1);
for i=1:max(coordinates(:,3))
    ind = coordinates(:,3)==i;
    if any(ind)
        % Central point is defined as the centre of mass of the selected
        % coordinates
        coor_temp = coordinates(ind,:);
        Xcen = mean(coor_temp(:,1));
        Ycen = mean(coor_temp(:,2));
        
        % Select most central point to calculate box size
        dist = sqrt( (coor_temp(:,1) - Xcen).^2 + (coor_temp(:,2) - Ycen).^2);
        BetaX = coor_temp(dist==min(dist),1);
        BetaY = coor_temp(dist==min(dist),2);
        
        % Get starting value for box size, use distance with respect to
        % closest point
        coor_temp = coordinates(coordinates(:,1)~=BetaX,:);
        dist = sqrt( (coor_temp(:,1) - BetaX).^2 + (coor_temp(:,2) - BetaY).^2);
        BetaX2 = coor_temp(dist==min(dist),1)/dx+1;
        BetaY2 = coor_temp(dist==min(dist),2)/dx+1;
        BetaX  = BetaX/dx+1;
        BetaY  = BetaY/dx+1;
        
        % Starting value
        Box(i) = round( sqrt( (BetaX-BetaX2)^2 + (BetaY-BetaY2)^2 ) );
        % Use pixels along horizontal or vertical line
        dist = [BetaX;size(obs,2)-BetaX;BetaY;size(obs,1)-BetaY];
        if min(dist)==dist(3) || min(dist)==dist(4) % Horizontal option is better
            Cmin = max(0,round(BetaX)-Box(i));
            Cmax = min(size(obs,2),round(BetaX)+Box(i));
            profile = obs(round(BetaY),Cmin:Cmax)';
        else
            Cmin = max(0,round(BetaY)-Box(i));
            Cmax = min(size(obs,1),round(BetaY)+Box(i));
            profile = obs(Cmin:Cmax,round(BetaX));
        end
        
        % Select box by 5 pixels
        % Positive or negative gaussians
        peak = obs(round(BetaX),round(BetaY))-zeta;
        if sign(peak)==1
            % Search for minimum
            [~,ind_box] = sort(profile,'ascend');
            % Use distance of 5 smallest values
            dist = sqrt( (Box(i)+1-ind_box(1:5)).^2 );
        else
            % Search for maximum
            [~,ind_box] = sort(profile,'descend');
            % Use distance of 5 largest values
            dist = sqrt( (Box(i)+1-ind_box(1:5)).^2 );
        end
        % Check if values are all within a range of 20% of the starting
        % value. Use mean values for new box size
        if max(dist)-min(dist)<0.2*Box(i)
            Box(i) = round(mean(dist));
        else
            while max(dist)-min(dist)<0.2*Box(i)
                % Delete outlier
                Box(i) = mean(dist);
                dist2 = sqrt( (dist-Box(i)).^2 );
                dist = dist(dist2~=max(dist2));
            end
            Box(i) = round(mean(dist));
        end
    else
        Box(i) = FP.box;
    end
end