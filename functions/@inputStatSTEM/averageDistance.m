function obj = averageDistance(obj)
% averageDistance - calculate the average distance between coordinates
%
%   The nearest neighbour of each coordinate is used to find the average
%   distance between coordinates
%
%   syntax: obj = averageDistance(obj)
%       obj - inputStatSTEM file
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------


if length(obj.coordinates(:,1))==1
    dist = min(size(obj.obs))*obj.dx;
else
    par = 0;
    % Don't use parpool at this moment if not yet created (takes time to start)
    if obj.numWorkers ~= 1
        if ~isempty(gcp('nocreate'))
            par = 1;
        end
    end
    if isempty(obj.indAllWorkers)
        obj = devideIndices(obj);
    end

    if par == 0
        dist = ceil(mean(getDist(obj.coordinates,obj.indAllWorkers{1,1})));
    else
        % Calculate distance per worker
        distInt = zeros(length(obj.coordinates(:,1)),1);
        job = cell(obj.numWorkers,1);
        for k=1:obj.numWorkers
            job{k} = parfeval(@getDist,1,obj.coordinates,obj.indAllWorkers{k,1});
        end
        % Receive distance
        for k=1:obj.numWorkers
            [~,distInt(obj.indAllWorkers{k,1})] = fetchNext(job{k});
        end
        dist = ceil(mean(distInt)); 
    end
end
obj.pDist = dist;
    
function dist = getDist(coordinates,ind)
dist = zeros(length(ind),1);
for n = 1:length(ind)
    i = ind(n);
    betaX_translated = coordinates(:,1) - coordinates(i,1);
    betaY_translated = coordinates(:,2) - coordinates(i,2);
    r = betaX_translated.^2+betaY_translated.^2;
    sr = sort(r);
    dist(n) = sqrt(sr(2));
end
