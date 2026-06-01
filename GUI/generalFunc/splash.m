classdef splash
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------
% Modified: replaced Java/im2java implementation with native MATLAB figure

    properties
        image       % The shown image (in matrix format)
        window      % The figure handle showing the image
        pos = [];   % The location of the window in pixels (x,y)
        maxTime = 60;
    end

    methods
        function obj = splash(img, pos, t)
            if nargin > 2
                obj.maxTime = t;
            end
            obj.image = img;

            % Get screen size and image size
            screen = get(0, 'ScreenSize');
            imgH = size(img, 1);
            imgW = size(img, 2);

            if nargin >= 2 && length(pos) == 2
                obj.pos = pos;
                x = pos(1) - imgW/2;
                y = pos(2) - imgH/2;
            else
                x = screen(3)/2 - imgW/2;
                y = screen(4)/2 - imgH/2;
            end

            % Create borderless figure
            obj.window = figure( ...
                'MenuBar',      'none', ...
                'ToolBar',      'none', ...
                'NumberTitle',  'off', ...
                'Name',         '', ...
                'Resize',       'off', ...
                'Units',        'pixels', ...
                'Position',     [x, y, imgW, imgH], ...
                'WindowStyle',  'normal');

            % Show image filling the whole figure
            ax = axes('Parent', obj.window, ...
                      'Units', 'normalized', ...
                      'Position', [0 0 1 1]);
            imshow(img, 'Parent', ax);
            drawnow;
        end

        function delete(obj)
            if ishandle(obj.window)
                close(obj.window);
            end
        end

        function close(obj)
            if ishandle(obj.window)
                close(obj.window);
            end
        end

        function show(obj)
            if ishandle(obj.window)
                figure(obj.window);
            end
        end

        function out = get.pos(obj)
            if isempty(obj.pos)
                screen = get(0, 'ScreenSize');
                out = [screen(3)/2, screen(4)/2];
            else
                out = obj.pos;
            end
        end

        function obj = set.pos(obj, pos)
            if length(pos) == 2
                obj.pos = pos;
            else
                error('Wrong input argument, position must be a 1 x 2 vector')
            end
        end

        function updateLocation(obj)
            if ishandle(obj.window)
                screen = get(0, 'ScreenSize');
                imgH = size(obj.image, 1);
                imgW = size(obj.image, 2);
                p = obj.pos;
                set(obj.window, 'Position', [p(1)-imgW/2, p(2)-imgH/2, imgW, imgH]);
            end
        end
    end
end