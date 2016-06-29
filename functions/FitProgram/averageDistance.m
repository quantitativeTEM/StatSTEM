function dist = averageDistance(coordinates,FP)
% averageDistance - calculate the average distance between coordinates
%
%   The nearest neighbour of each coordinate is used to find the average
%   distance between coordinates
%
%   syntax: dist = averageDistance(coordinates,FP)
%       coordinates - the coordinates
%       FP          - structure containing all fitting parameters
%       dist        - distance
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

dist_test = zeros(length(coordinates(:,1)),1);
job = cell(FP.numWorkers,1);
if FP.numWorkers == 1
    dist = ceil(mean(getDist(coordinates,FP.indAllWorkers{1,1})));
else
    % Calculate distance per worker
    for k=1:FP.numWorkers
        job{k} = parfeval(@getDist,1,coordinates,FP.indAllWorkers{k,1});
    end
    % Receive distance
    for k=1:FP.numWorkers
        [~,dist_test(FP.indAllWorkers{k,1})] = fetchNext(job{k});
    end
    dist = ceil(mean(dist_test)); 
end
    
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
