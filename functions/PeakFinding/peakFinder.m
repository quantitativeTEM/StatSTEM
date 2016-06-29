function varargout = peakFinder(obs,settings)
% peakFinder - simple function finding the peak location in an image
%
%   The function will search for local optima in the image. Filter and
%   threshold values can be used to optimize the routine
%
%   syntax: varargout = peakFinder(obs,settings);
%       obs       - the observation (in double precision)
%       settings  - structure array containing all filter and threshold values
%
%   Outputs:
%       varargout - A 2*N vector with peak locations [x y] or 2 1*N vectors
%                   with peak locations x and y
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin<2
    settings.thres = max( min(max(obs,[],1)) , min(max(obs,[],2)) );
else
    if ~any(strcmp(fieldnames(settings),'thres'))
        settings.thres = settings;
    end
end

%% First check if 3 filters are given, if not use standard filters
% Filter 1
if ~any(strcmp(fieldnames(settings),'filter1'))
    settings.filter1.type = 'gaussian';
    settings.filter1.val = 2;
end
% Filter 2
if ~any(strcmp(fieldnames(settings),'filter2'))
    settings.filter2.type = 'none';
    settings.filter2.val = 1;
end
% Filter 3
if ~any(strcmp(fieldnames(settings),'filter3'))
    settings.filter3.type = 'none';
    settings.filter3.val = 1;
end

%% Apply filters and threshold on image
s = size(obs);
filt1 = getFilt(settings.filter1.type,settings.filter1.val,s);
filt2 = getFilt(settings.filter2.type,settings.filter2.val,s);
filt3 = getFilt(settings.filter3.type,settings.filter3.val,s);

obsF = fftshift(fft2(ifftshift(obs)));
obsFilt = real(fftshift(ifft2(ifftshift(obsF.*filt1.*filt2.*filt3))));
% Function should also work for negative obs values
obs = (obsFilt>settings.thres).*obsFilt + (obsFilt<=settings.thres).*settings.thres;

%% Peak finding routine
xy = [];
if any(any(obs>settings.thres))
    edge = 1;
    [x,y]=find(obs(edge+1:s(1)-edge,edge+1:s(2)-edge));
    x = x+edge;
    y = y+edge;
    for j=1:length(y)
        if (obs(x(j),y(j))>obs(x(j)-1,y(j)-1 )) &&...
                (obs(x(j),y(j))>obs(x(j)-1,y(j))) &&...
                (obs(x(j),y(j))>obs(x(j)-1,y(j)+1)) &&...
                (obs(x(j),y(j))>obs(x(j),y(j)-1)) && ...
                (obs(x(j),y(j))>=obs(x(j),y(j)+1)) && ...
                (obs(x(j),y(j))>=obs(x(j)+1,y(j)-1)) && ...
                (obs(x(j),y(j))>=obs(x(j)+1,y(j))) && ...
                (obs(x(j),y(j))>=obs(x(j)+1,y(j)+1));
            xy = [xy;[y(j) x(j)]]; % Coordinates are reversed
        end
    end
end

if nargout==1
    varargout{1} = xy;
elseif nargout==2
    if isempty(xy)
        varargout{1} = [];
        varargout{2} = [];
    else
        varargout{1} = xy(:,1);
        varargout{2} = xy(:,2);
    end
end


function filt = getFilt(filter,val,s)
if strcmp(filter,'none')
    filt = ones(s(1),s(2));
elseif strcmp(filter,'average')
    if val~=round(val)
        val = round(val);
    end
    filt = zeros(s(1),s(2));
    filt(ceil(s(1)/2)-val+2:ceil(s(1)/2)+val,ceil(s(2)/2)-val+2:ceil(s(2)/2)+val) = 1/val^2;
    filt = fftshift(fft2(ifftshift(filt)));
elseif strcmp(filter,'disk')
    [x,y] = meshgrid(-ceil(s(2)/2):ceil(s(2)/2)-1 , -ceil(s(1)/2):ceil(s(1)/2)-1);
    R = sqrt(x.^2+y.^2)+1;
    filt = (R<=val)/max( sum(sum(R<=val)), 1);
    filt = fftshift(fft2(ifftshift( filt )));
else
    filt = fftshift(fft2(ifftshift(fspecial(filter,[s(1) s(2)],val))));
end