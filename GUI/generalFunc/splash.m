classdef splash
%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2016, EMAT, University of Antwerp
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

    properties
        image % The shown image (in matrix format)
        window % The window showing the image
        pos = [];% The location of the window in pixels (x,y)
    end

    methods
        function obj = splash(img,pos)
            % splash - create a splash screen
            %
            %   syntax: obj = splash(img,pos)
            %       img - image (in matlab format)
            %       pos - position on screen (pixels)
            %       obj - reference to splash screen
            %
            
            obj.image = img;
            
            % First convert to java
            splashImg = im2java(obj.image);
            
            % Create window with splash image
            obj.window = javax.swing.JWindow;
            icon = javax.swing.ImageIcon(splashImg);
            label = javax.swing.JLabel(icon);
            obj.window.getContentPane.add(label);
            obj.window.setAlwaysOnTop(true);
            obj.window.pack;
            
            if nargin==2
                if length(pos)~=2
                    obj.pos = pos;
                else
                    error('Wrong input argument, position must be a 1*2 vector')
                end
            end
            
            % Set location of window
            updateLocation(obj)
            show(obj)
        end
        
        function close(obj)
            obj.window.dispose
        end
        
        function show(obj)
            obj.window.show
        end
        
        function out = get.pos(obj)
            if isempty(obj.pos)
                screen = get(0,'ScreenSize');
                out = [screen(3)/2,screen(4)/2];
            else
                out = obj.pos;
            end
        end
        
        function obj = set.pos(obj,pos)
            if length(pos)==2
                obj.pos = pos;
            else
                error('Wrong input argument, position must be a 1 x 2 vector')
            end
        end
        
        function updateLocation(obj)
            % Set location of window
            imgHeight = size(obj.image,1)/2;
            imgWidth  = size(obj.image,2)/2;
            win = obj.window;
            p = obj.pos;
            win.setLocation(p(1)-imgWidth,p(2)-imgHeight);
        end
    end
    
end