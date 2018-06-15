classdef popupmenu < StatSTEMbutton
    
    properties
        name = '';
        func = '';
        enable = 1;
        keepName = 0; % Keep name in list of options
        equalTo = {''};
        selOptInput = ''; % Reference to StatSTEM file variable that determines the selected option of the menu
    end
    
    methods
        function obj = popupmenu(name,value,varargin)
            if nargin>0
                varargin = [{name},{value},varargin];
            end
            obj.button = javax.swing.JComboBox;
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
                value = {value};
                obj.name = value;
            elseif isa(value,'cell')
                N=length(value);
                inOK = 1;
                for n=1:N
                    if ~isa(value{n},'char')
                        inOK = 0;
                    end
                end
                if inOK==0
                    error('StatSTEMbutton: Names in cell structure should be a string')
                else
                    obj.name = value;
                end
            else
                error('StatSTEMbutton: Name should be a string or a cell structure with strings')
            end
            obj.button.setModel(javax.swing.DefaultComboBoxModel(value))
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
        
        function obj = set.keepName(obj,value)
            % Make sure the value is a logical
            if value==1 || value==0
                obj.keepName = value==true;
            else
                error('StatSTEMbutton: keepName should be a logical value')
            end
        end
        
        function obj = set.selOptInput(obj,value)
            % Make sure the name is a string
            if isa(value,'char')
                obj.selOptInput = value;
            else
                error('StatSTEMbutton: selOpt should be a string')
            end
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
    end
    
    methods (Hidden)
        function delete(obj)
            delete@StatSTEMbutton(obj);
            set(obj.button,'PopupMenuWillBecomeInvisibleCallback',[])
        end
    end
end
    