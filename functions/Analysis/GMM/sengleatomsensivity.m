function Pc = sengleatomsensivity(atomcounting,sens)
% sengleatomsensivity - calculate atom counting sensitivity
%
% syntax: out = sengleatomsensivity(atomcounting,sens)
%       out          - array with the atom counting sensitivity
%       atomcounting - structure with atom counting results
%       sens         - sensitivity (1=single atom, 2 = single and 2 atom
%                                   sensitivity, etc.)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

mu = atomcounting.estimatedLocations;
sigma = atomcounting.estimatedWidth;
prop = atomcounting.estimatedProportions;

Pc = zeros(sens,1);
Pall = 0;
N = atomcounting.selMin;
for j = 1:N
    % Get intersection of jth component with kth neighbours
    for k=1:sens
        % Negative direction
        j1 = j-k; % For crossing point with kth neighbour
        j2 = j-(k-1); % For crossing point with (k-1)th neighbour
        int1 = zeros(2,1);
        if j1>0
            % Crossing point
            int1(1,1) = (2*sigma^2*log(prop(j)/prop(j1))-mu(j)^2+mu(j1)^2)/(2*(mu(j1)-mu(j)));
        else
            int1(1,1) = -Inf;
        end
        if j2>0
            if j2==j
                int1(2,1) = mu(j);
            else
                % Crossing point
                int1(2,1) = (2*sigma^2*log(prop(j)/prop(j2))-mu(j)^2+mu(j2)^2)/(2*(mu(j2)-mu(j)));
            end
        else
            int1(2,1) = -Inf;
        end
        
        % Positive direction
        j1 = j + k; % For crossing point with kth neighbour
        j2 = j + (k-1); % For crossing point with (k-1)th neighbour
        if j1<N+1
            % Crossing point
            int2(1,1) = (2*sigma^2*log(prop(j)/prop(j1))-mu(j)^2+mu(j1)^2)/(2*(mu(j1)-mu(j)));
        else
            int2(1,1) = Inf;
        end
        if j2<N+1
            if j2==j
                int2(2,1) = mu(j);
            else
                % Crossing point
                int2(2,1) = (2*sigma^2*log(prop(j)/prop(j2))-mu(j)^2+mu(j2)^2)/(2*(mu(j2)-mu(j)));
            end
        else
            int2(2,1) = Inf;
        end
        
        % Normalisation for normcdf is by the factor 1/sqrt(2*pi)
        Pc(k,1) = Pc(k,1) + (normcdf(int2(1,1),mu(j),sigma)-normcdf(int2(2,1),mu(j),sigma)+normcdf(int1(2,1),mu(j),sigma)-normcdf(int1(1,1),mu(j),sigma))*prop(j)/sqrt(2*pi);
    end
    Pall = Pall + normcdf(Inf,mu(j),sigma)*prop(j)/sqrt(2*pi);
end

Pc = Pc/Pall;
