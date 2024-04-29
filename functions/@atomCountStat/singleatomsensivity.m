function out = singleatomsensivity(atomcounting,sens)
% sengleatomsensivity - calculate atom counting sensitivity
%
% syntax: out = sengleatomsensivity(atomcounting,sens)
%       out          - array with the atom counting sensitivity
%       atomcounting - atomCountStat file
%       sens         - sensitivity (1=single atom, 2 = single and 2 atom
%                                   sensitivity, etc.)
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos & A. De Backer
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

if nargin==1
    sens = 1;
end

mu = atomcounting.estimatedLocations;
sigma = atomcounting.estimatedWidth;
prop = atomcounting.estimatedProportions;

if size(mu,1)~=1
    mu = mu';
end
if size(prop,1)~=1
    prop = prop';
end

if atomcounting.GMMType  == 5
    sigma = sigma(1);

    out = zeros(sens,1);
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

            % Calculate atom sensitivity for entire micture model
            %
            % Per component: P(phig|Ig) = P(Ig|phig) * P(phig) / P(Ig)
            %
            % For model: Psens = sum( P(phig|Ig) * P(Ig) ) = sum( P(Ig|phig) * P(phig) )
            %
            % No need to calculate P(Ig)!
            %
            PsensCg = (normcdf(int2(1,1),mu(j),sigma)-normcdf(int2(2,1),mu(j),sigma)+normcdf(int1(2,1),mu(j),sigma)-normcdf(int1(1,1),mu(j),sigma)).*prop(j); % Sum up right and left part
            out(k,1) = out(k,1) + PsensCg;
        end
    end
else
    out = zeros(sens,1);
    N = atomcounting.selMin;
    for j = 1:N
        for k=1:sens
            % Negative direction
            j1 = j-k; % For crossing point with kth neighbour
            j2 = j-(k-1); % For crossing point with (k-1)th neighbour
            int1 = zeros(2,1);
            if j1>0
                % Crossing point
                mu1 = mu(j);
                var1 = sigma(j)^2;
                prop1 = prop(j);
                mu2 = mu(j1);
                var2 = sigma(j1)^2;
                prop2 = prop(j1);
                yfun = @(mu,var,prop, x)prop*(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
                int1(1,1) = fzero(@(x) yfun(mu1, var1, prop1, x) - yfun(mu2, var2, prop2, x), mean([mu1,mu2]));
            else
                int1(1,1) = -Inf;
            end
            if j2>0
                if j2==j
                    int1(2,1) = mu(j);
                else
                    % Crossing point
                    mu1 = mu(j);
                    var1 = sigma(j)^2;
                    prop1 = prop(j);
                    mu2 = mu(j2);
                    var2 = sigma(j2)^2;
                    prop2 = prop(j2);
                    yfun = @(mu,var,prop, x)prop*(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
                    int1(2,1) = fzero(@(x) yfun(mu1, var1, prop1, x) - yfun(mu2, var2, prop2, x), mean([mu1,mu2]));
                end
            else
                int1(2,1) = -Inf;
            end

            % Positive direction
            j1 = j + k; % For crossing point with kth neighbour
            j2 = j + (k-1); % For crossing point with (k-1)th neighbour
            if j1<N+1
                % Crossing point
                mu1 = mu(j);
                var1 = sigma(j)^2;
                prop1 = prop(j);
                mu2 = mu(j1);
                var2 = sigma(j1)^2;
                prop2 = prop(j1);
                yfun = @(mu,var,prop, x)prop*(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
                int2(1,1) = fzero(@(x) yfun(mu1, var1, prop1, x) - yfun(mu2, var2, prop2, x), mean([mu1,mu2]));
            else
                int2(1,1) = Inf;
            end
            if j2<N+1
                if j2==j
                    int2(2,1) = mu(j);
                else
                    % Crossing point
                    mu1 = mu(j);
                    var1 = sigma(j)^2;
                    prop1 = prop(j);
                    mu2 = mu(j2);
                    var2 = sigma(j2)^2;
                    prop2 = prop(j2);
                    yfun = @(mu,var,prop, x)prop*(2*pi*(var))^(-0.5)* exp(-((x-mu).^2)/(2*(var)));
                    int2(2,1) = fzero(@(x) yfun(mu1, var1, prop1, x) - yfun(mu2, var2, prop2, x), mean([mu1,mu2]));
                end
            else
                int2(2,1) = Inf;
            end

            % Calculate atom sensitivity for entire micture model
            %
            % Per component: P(phig|Ig) = P(Ig|phig) * P(phig) / P(Ig)
            %
            % For model: Psens = sum( P(phig|Ig) * P(Ig) ) = sum( P(Ig|phig) * P(phig) )
            %
            % No need to calculate P(Ig)!
            %
            PsensCg = (normcdf(int2(1,1),mu(j),sigma(j))-normcdf(int2(2,1),mu(j),sigma(j))+normcdf(int1(2,1),mu(j),sigma(j))-normcdf(int1(1,1),mu(j),sigma(j))).*prop(j); % Sum up right and left part
            out(k,1) = out(k,1) + PsensCg;
        end

    end
end

