function RGBvec = getRGBvec(cmap,c_x,data,mode)
% getRGBvec - Determine the RGB values for a colormap
%
%   syntax: RGBvec = getRGBvec(cmap,data,mode)
%       RGBvec - vector with RGB values for data
%       cmap   - colormap (RGB matrix)
%       c_x    - data values with colormap
%       data   - data;
%       mode   - 'exact' or 'int', choose to find for each

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<3
    mode = 'int';
end

% Define colormap
RGBvec = zeros(size(data,1),3);
if strcmp(mode,'exact')
    % To speed up to plotting, devide range in 64 points for getting the colors
    unVal = unique(data);
    for n=1:length(unVal)
        % Get coordinates
        ind = data == unVal(n);

        if any(ind)
            % Get color
            if unVal(n)<c_x(1)
                clr = cmap(1,:);
            elseif unVal(n)>c_x(end)
                clr = cmap(end,:);
            else
                clr = [interp1(c_x,cmap(:,1),unVal(n),'linear') interp1(c_x,cmap(:,2),unVal(n),'linear') interp1(c_x,cmap(:,3),unVal(n),'linear')];
            end
            RGBvec(ind,1) = clr(1,1);
            RGBvec(ind,2) = clr(1,2);
            RGBvec(ind,3) = clr(1,3);
        end
    end
else
    s = size(cmap,1);
    for n=1:s
        if n==1
            ind = data<0.5*(c_x(n)+c_x(n+1));
        elseif n==s
            ind = data>=0.5*(c_x(n-1)+c_x(n));
        else
            ind = data>=0.5*(c_x(n-1)+c_x(n)) & data<0.5*(c_x(n)+c_x(n+1));
        end

        if any(ind)
            RGBvec(ind,1) = cmap(n,1);
            RGBvec(ind,2) = cmap(n,2);
            RGBvec(ind,3) = cmap(n,3);
        end
    end
end