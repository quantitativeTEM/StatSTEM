function [file,message] = loadMatFile(FileName)
% loadMatFile - Load a matlab file suitable for StatSTEM
%
%   syntax: [file,message,dx] = loadMatFile(PathName,FileName)
%       FileName - Filename
%       file     - Structure containing the file information
%       message  - message for indicating if anything goes wrong
%

%--------------------------------------------------------------------------
% This file is part of StatSTEM
%
% Copyright: 2018, EMAT, University of Antwerp
% Author: K.H.W. van den Bos
% License: Open Source under GPLv3
% Contact: sandra.vanaert@uantwerpen.be
%--------------------------------------------------------------------------

file = load(FileName);
message = '';

% Find FileName
loc = strfind(FileName,filesep);
FileName = FileName(loc(end)+1:end);

%% Convert file to correct StatSTEM structure (1/5)
% inputStatSTEM structure
fNames = fieldnames(file);
N = length(fNames);
ind = false(N,1);
pUC = [];
for n=1:N
    ind(n,1) = isa(file.(fNames{n}),'inputStatSTEM');
end
if sum(double(ind))>1
    message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
    file = [];
    errordlg('Invalid input structure')
    return
elseif sum(double(ind))==1
    if ~strcmp(fNames{ind},'input')
        file.input = file.(fNames{ind});
        file = rmfield(file,fNames{ind});
    end
elseif isfield(file,'input')
    % Convert old StatSTEM file format to new one
    if isfield(file.input,'projUnit')
        if isa(file.input.projUnit,'projUnitCell')
            % Store projected unit cell
            pUC = file.input.projUnit;
        else
            % Store and convert to new class format
            pUC = file.input.projUnit;
            pUC = projUnitCell(pUC.a,pUC.b,pUC.ang,pUC.coor2D,pUC.atom2D);
        end
    end
    if isfield(file.input,'obs')
        obs = file.input.obs;
        if isfield(file.input,'dx')
            dx = file.input.dx;
            if isfield(file.input,'coordinates')
                coordinates = file.input.coordinates;
                if isfield(file.input,'types')
                    file.input = inputStatSTEM(obs,dx,coordinates,file.input.types);
                else
                    file.input = inputStatSTEM(obs,dx,coordinates);
                end
            else
                file.input = inputStatSTEM(obs,dx);
            end  
        else
            file.input = inputStatSTEM(obs);
        end
    elseif length(fNames)==1 && ~isa(file.input,'struct') && size(file.input,1)>1 && size(file.input,2)>1
        file.input = inputStatSTEM(file.input);
    else
        file = [];
        message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
        errordlg('Invalid input structure')
        return
    end
    
else
    % loaded matlab file must be an image
    if length(fNames)==1 && ~isa(file.(fNames{1}),'struct') && size(file.(fNames{1}),1)>1 && size(file.(fNames{1}),2)>1
        file.input = inputStatSTEM(file.(fNames{1}));
    else
        file = [];
        message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
        errordlg('Invalid input structure')
        return
    end
end
% Update filename
file.input.name = FileName;
file.input.projUnit = pUC;

%% Convert file to correct StatSTEM structure (2/5)
% outputStatSTEM structure
fNames = fieldnames(file);
N = length(fNames);
ind = false(N,1);
for n=1:N
    ind(n,1) = isa(file.(fNames{n}),'outputStatSTEM');
end
if sum(double(ind))>1
    file = [];
    message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
    errordlg('Invalid input structure')
    return
elseif isfield(file,'output') && ~isa(file.output,'outputStatSTEM')
    % This means a model has been fitted before, convert structure
    names = fieldnames(file.output);
    if any(strcmp(names,'BetaX')) % Convert coordinates to newer version
        file.output.coordinates = [file.output.BetaX,file.(fNames{ind}).BetaY];
        file.output = rmfield(file.output,{'BetaX','BetaY'});
    end 
    out = file.output;
    file = rmfield(file,'output');
    file.output = outputStatSTEM([out.coordinates,file.input.coordinates(:,3)],out.rho,out.eta,out.zeta,file.input.dx);
    file.output.types = file.input.types;
    file.output = loadModel(file.output,out.model);
    file.output.lsq = out.lsq;
end

% Update filename
if isfield(file,'output')
    file.output.name = FileName;
end

%% Convert file to correct StatSTEM structure (3/5)
% atomCountStat structure
fNames = fieldnames(file);
N = length(fNames);
ind = false(N,1);
for n=1:N
    ind(n,1) = isa(file.(fNames{n}),'atomCountStat');
end
if sum(double(ind))>1
    file = [];
    message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
    errordlg('Invalid input structure')
    return
elseif isfield(file,'atomcounting') && ~isa(file.atomcounting,'atomCountStat')
    % This means a model has been fitted before, convert structure
    out = file.atomcounting;
    try
        file.output.selRegion = out.selRegion;
    catch
        file.output.selRegion = [];
    end
    try
        file.output.selType = out.selType;
    catch
        file.output.selType = [];
    end
    try
        file.output.rangeVol = [out.minVol,out.maxVol];
    catch
        file.output.rangeVol = [];
    end
    file = rmfield(file,'atomcounting');
    file.atomcounting = atomCountStat(file.output.selCoor,out.volumes,file.input.dx,out.estimatedDistributions,out.mLogLik,out.selMin);
    file.output.n_c = length(file.atomcounting.ICL);
end

% Update filename
if isfield(file,'atomcounting')
    file.atomcounting.name = FileName;
end

%% Convert file to correct StatSTEM structure (4/5)
% atomCountLib structure
fNames = fieldnames(file);
N = length(fNames);
ind = false(N,1);
for n=1:N
    ind(n,1) = isa(file.(fNames{n}),'libCountStat');
end
if sum(double(ind))>1
    file = [];
    message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
    errordlg('Invalid input structure')
    return
elseif isfield(file,'libcounting') && ~isa(file.libcounting,'atomCountLib')
    % This means a model has been fitted before, convert structure
    out = file.libcounting;
    file = rmfield(file,'libcounting');
    file.libcounting = atomCountLib(file.output.selCoor,file.output.selVol,file.input.dx,out.library(:,2),out.library(:,1));
end

% Update filename
if isfield(file,'libcounting')
    file.libcounting.name = FileName;
end

%% Convert file to correct StatSTEM structure (5/5)
% strainMapping structure
fNames = fieldnames(file);
N = length(fNames);
ind = false(N,1);
for n=1:N
    ind(n,1) = isa(file.(fNames{n}),'strainMapping');
end
if sum(double(ind))>1
    file = [];
    message = sprintf(['The file ', FileName, ' cannot be loaded, invalid input structure']);
    errordlg('Invalid input structure')
    return
elseif isfield(file,'strainmapping') && ~isa(file.strainmapping,'strainMapping')
    % This means a model has been fitted before, convert structure
    out = file.strainmapping;
    file = rmfield(file,'strainmapping');
    if isfield(out,'coor_sel')
        coorSel = out.coor_sel;
    else
        coorSel = file.output.selCoor;
    end
    file.strainmapping = strainMapping(coorSel,file.input.dx,pUC,out.refCoor);
    if isfield(out,'teta')
        file.strainmapping = setTeta(file.strainmapping,out.teta,out.dir_teta_ab);
        file.strainmapping = setAB(file.strainmapping,out.a,out.b);
    end
    if isfield(out,'coor_relaxed')
        file.strainmapping = setCoorRelTypeInd(file.strainmapping,out.coor_relaxed,out.types,out.indices);
    end
    if isfield(out,'eps_xx')
        file.strainmapping = setEps(file.strainmapping,out.eps_xx,out.errEps_xx,out.eps_xy,out.errEps_xy,...
            out.eps_yy,out.errEps_yy,out.omg_xy,out.errOmg_xy);
    end
end

% Update filename
if isfield(file,'strainmapping')
    file.strainmapping.name = FileName;
end

%% Removing all remaining fields that are not part of the StatSTEMfile class
fNames = fieldnames(file);
for i=1:length(fNames)
    if ~isa(file.(fNames{i}),'StatSTEMfile')
        file = rmfield(file,fNames{i});
    end
end