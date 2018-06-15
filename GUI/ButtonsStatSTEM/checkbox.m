classdef checkbox < StatSTEMbutton
    
    properties
        name = '';
        func = '';
        enable = 1;
        equalTo = {''};
        selected = 1;
        selWhen = {}; % Specify the input value in the StatSTEM file that must be true/false to select button {value, 'input....'}
    end
    
    methods
        function obj = checkbox(name,value,varargin)
            if nargin>0
                varargin = [{name},{value},varargin];
            end
            obj.button = javax.swing.JCheckBox;
            obj.height = 18;
            obj.Focusable = false;
            obj.button.setFont(obj.font);
            N = length(varargin);
            for n=1:N/2
                obj.(varargin{2*n-1}) = varargin{2*n};
            end
        end
        
        function obj = set.name(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                obj.name = value;
            else
                error('StatSTEMbutton: Name should be a string')
            end
            set(obj.button,'Text',value)
        end
        
        function obj = set.func(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                obj.func = value;
            end
        end
        
        function obj = set.enable(obj,value)
            % Make sure the value is a logical
            if value==1 || value==0
                obj.enable = value==true;
            else
                error('StatSTEMbutton: Enable should be a logical value')
            end
            obj.setEnabled(value);
        end
        
        function obj = set.equalTo(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                obj.equalTo = {value};
            elseif isa(value,'cell')
                obj.equalTo = value;
            else
                error('StatSTEMbutton: equalTo should be a string or a cell structure with strings')
            end
        end
        
        function obj = set.selected(obj,value)
            % Make sure the value is a logical
            if value==1 || value==0
                obj.selected = value==true;
            else
                error('StatSTEMbutton: selected should be a logical value')
            end
            obj.button.setSelected(value==1);
        end
    end
end
    