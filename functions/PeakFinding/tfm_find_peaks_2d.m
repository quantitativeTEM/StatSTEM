function [img_o, xy] = tfm_find_peaks_2d(img, sigma, pk_min, d_min)
% tfm_find_peaks_2d - Peak finding and denoising function
%
%   syntax: [img_o, xy] = tfm_find_peaks_2d(img, sigma, pk_min, d_min)
%
%   Input:
%       img      - the observation
%       sigma    - estimated feature radius in pixel
%       pk_min   - threshold value for peak detection (normalized 0-1)
%       d_min    - minimum peak distance in pixel
%
%   Output:
%       img      - denoised image
%       xy       - list of coordinates for detected peak locations

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2019, EMAT, University of Antwerp
% Author: Thomas Friedrich
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
   
    % Avoide negative values
    img = img+min(img(:));
    
    % This ratio corresponds roughly to the the visual column radius
    sigma = sigma/3;
    
    % Anscome transform to convert from poisson distribution to gaussian
    % distribution
    d = fcn_anscombe(img);

    % Estimate filter kernel sizes based on expected feature size
    nkr_w = max(1, 2*floor(sigma)+1);
    nkr_m = max(1, 2*floor(sigma)+1);

    % Apply Wiener filter
    d = wiener2(d,[nkr_w nkr_w]);
    
    % Apply Median filter to compensate salt/pepper-like artefacts
    d = medfilt2(d,[nkr_m nkr_m],'symmetric');
    
    % Inverse Anscombe transform
    d = fcn_anscombe_inv(d);
    
    d = max(min(img(:)), d);
    
    % Signal to noise ratio
    psnr = (var(d(:))/var(img(:)-d(:)));
    alpha = 1/psnr;

    % Perform deconvolution with gaussian, according to:
    % Van Dyck, D. (2012). Basics of Image Processing and Analysis. p. 74. https://doi.org/10.5281/zenodo.51511
    [ny, nx] = size(d);
    [gx,gy]=fcn_real_space_2_F_space(nx,ny);
    H = fcn_gauss_2d_fourier_space(gx,gy,sigma);
    Y = conj(H)./(abs(H).^2+(alpha));

    d_deconv = fftshift(ifft2(fft2(ifftshift(d)).*ifftshift(Y)));
    d_deconv = real(d_deconv);

    se = strel('disk',round(5*sigma));
    img_o = imtophat(d_deconv,se);
    
    sc = max(img_o(:));
    img_o = img_o/sc;
    
    if nargout > 1
        xy = fcn_local_max(img_o,pk_min,d_min);
    else
        xy = [];
    end
end

function xy_o = fcn_local_max(img, pk_min, d_min)
    xy = [];
    
    % Account for the border pixels
    pad = 1;
    [y_i,x_i]=find(img(pad+1:end-pad,pad+1:end-pad)>0);
    x_i = x_i+pad;
    y_i = y_i+pad;
    
    x = zeros(3,1);
    y = zeros(3,1);
    v = zeros(9,1);

    %Find local maxima and filter for minimum peak intensity
    for ix=1:length(x_i)
        % Get Kernel indices
        x(1) = x_i(ix)-1;
        x(2) = x_i(ix);
        x(3) = x_i(ix)+1;
        
        y(1) = y_i(ix)-1;
        y(2) = y_i(ix);
        y(3) = y_i(ix)+1;
        
        % Get Kernel intesities
        v(1) = img(y(1),x(1));
        v(2) = img(y(1),x(2));
        v(3) = img(y(1),x(3));
        v(4) = img(y(2),x(1));
        v(5) = img(y(2),x(3));
        v(6) = img(y(3),x(1));
        v(7) = img(y(3),x(2));
        v(8) = img(y(3),x(3));
        v(9) = img(y(2),x(2));
        v_s = sum(v);
        
        % Check for local maximum
        if  all(v(9)>=v) && (v(9)>= pk_min)   
            % Compute weightd average of coordinate for subpixel accuracy
            x_o = (v(1)*x(1) + v(2)*x(2) + v(3)*x(3) + v(4)*x(1) + v(5)*x(3) + v(6)*x(1) + v(7)*x(2) + v(8)*x(3) + v(9)*x(2))/v_s;
            y_o = (v(1)*y(1) + v(2)*y(2) + v(3)*y(3) + v(4)*y(1) + v(5)*y(3) + v(6)*y(1) + v(7)*y(2) + v(8)*y(3) + v(9)*y(2))/v_s;
            xy = cat(1,xy,[x_o y_o v(9)]);  
        end
    end
    
 
    if d_min > 0
        % Filter xy-list for minimum peak distances
        xy_o = [];
        d_min2 = d_min^2;
        ip = 1;
        while ~isempty(xy)
            b_dis = sum((xy(1,1:2)-xy(:,1:2)).^2, 2) < d_min2;
            if sum(b_dis) > 1
                xyi_s = xy(b_dis,:);
                [~, i_max] = max(xyi_s(:,3));
                [~,idx] = ismember(xy,xyi_s(i_max,:),'rows');
                xy_f = xy(logical(idx),:);
            else
                xy_f = xy(ip, :);
            end
            xy_o = cat(1,xy_o,xy_f);
            xy(b_dis,:) = [];
        end 
    else
        xy_o = xy;
    end
    if ~isempty(xy_o)
        xy_o(:,3) = []; 
    end
end

function [gx,gy] = fcn_real_space_2_F_space(nx,ny)
    dgx = 1/nx; dgy = 1/ny;                             % Pixel Size in Fourier Space [1/A]  
    nxh = nx/2; nyh = ny/2;                             % Image center Pixel [n]
    gx_l =((-nxh):1:(nxh-1))*dgx;                       % Discretized x-Grid in Fourier Space
    gy_l =((-nyh):1:(nyh-1))*dgy;                       % Discretized y-Grid in Fourier Space
    [gx, gy] = meshgrid(gx_l, gy_l);
end

function gauss2d_F = fcn_gauss_2d_fourier_space(gx,gy,Sigma)
    gauss2d_F = exp(-2*pi^2*Sigma^2*(gx.^2+gy.^2));  
end

% Anscombe transform according to:
% Makitalo, M., & Foi, A. (2011). 
% Optimal Inversion of the Anscombe Transformation in Low-Count Poisson Image Denoising. 
% IEEE Transactions on Image Processing, 20(1), 99–109. https://doi.org/10.1109/TIP.2010.2056693
function img_o = fcn_anscombe(x)
    img_o = 2*sqrt(x+3/8);
end
% Anscombe transform inverse
function img_o = fcn_anscombe_inv(x)
    a = 0.25;
    b = sqrt(3/2)/4; 
    c = -11/8;
    d = 5/8*sqrt(3/2);
    e = -1/8;
    
    ix = 1./x;
    idx = abs(x)<1e-5;
    if size(idx, 1)>0
        ix(idx) = 0;
    end
    img_o = max(0, a*x.^2+e+ix.*(b+ix.*(c+ix*d)));

end
 