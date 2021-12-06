function [variable,time,coordSystem]=getFieldfromNetCDF(file,gridName,varargin)

import ucar.nc2.dt.grid.*
import ucar.nc2.dt.grid.GridDataset.*

landMask=0;rootPath=[];threshold=[];
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'landmask', landMask=varargin{i+1};
		case 'threshold', threshold=varargin{i+1};
		case 'path', rootPath=varargin{i+1};
		otherwise
			warning(sprintf('Option ''%s'' not defined',varargin{i}))
	end
end

dataset=GridDataset.open(deblank(file));
nc=getNetcdfDataset(dataset);
grids=getGrids(dataset);
grids=toString(grids);
grids=toCharArray(grids)';grids=grids(2:end-1);
if isempty(grids) | isempty(strfind(grids,gridName))
    grid=nc.findVariable(gridName);
else
    grids=strread(grids,'%s','delimiter',',');
    sd=findstr('.',gridName);
    if ~isempty(sd)
        gridName1=gridName(1:sd(1)-1);
        if isempty(strmatch(gridName,grids)) & isempty(strmatch(gridName1,grids))
            error(['There is not grids called: ' gridName ' in file: ' deblank(file) ' (check the name)']);
        elseif isempty(strmatch(gridName,grids))
            gridName=gridName1;grid=dataset.findGridByName(gridName);
        else
            grid=dataset.findGridByName(gridName);
        end
    else
        grid=dataset.findGridByName(gridName);
    end
end

met=methods(grid);
% The object is a GeoGrid ot a variable.
if ismember('VariableDS',met)
    variable=grid;
    ncgds=getCoordinateSystems(nc);
    gdsDims=toCharArray(toString(ncgds))';
    sd=strfind(gdsDims,',');
    if ~isempty(sd)
    	sd=[1 sd length(gdsDims)];
		sd1=strfind(gdsDims,toCharArray(toString(getDimensionsString(variable)))');
		gds=get(ncgds,find(sd1>sd(1:end-1) & sd1<sd(2:end))-1);
	else
		gds=ncgds;
	end
	try
		tim=getTimeAxis(gds);
	catch
		tim=getTaxis(gds);
	end
elseif ismember('GeoGrid',met)
   	variable=getVariable(grid);
	gds=getCoordinateSystem(grid);
	try
		tim=getTimeAxis(gds);
	catch
		tim=getTaxis(gds);
	end
end
if nargout>1
	fechaRef=getUnitsString(tim);fechaRef=toCharArray(fechaRef)';
	sd=findstr('since',fechaRef);fechaRef=fechaRef(sd+6:end);
    fechaRef(strfind(upper(fechaRef),'T'))=' ';fechaRef(strfind(upper(fechaRef),'Z'))=' ';fechaRef(strfind(upper(fechaRef),';'))=' ';fechaRef(strfind(upper(fechaRef),'"'))=' ';
   	if strmatch('0000',fechaRef),
   	    time.fechaRef=datenum(fechaRef)-datenum([2001 1 1 0 0 0])+1;
   	elseif strmatch('0001',fechaRef),
		time.fechaRef=datenum(fechaRef)-datenum([2000 1 1 0 0 0])+1;
   	elseif strmatch(':units = "hours since 1-1-1 00:00:0.0";',fechaRef)
   	    time.fechaRef=datenum([1 1 1 0 0 0])-2;
   	elseif strmatch(':units = "hours since 1-01-01 00:00:00";',fechaRef)
   	    time.fechaRef=datenum([1 1 1 0 0 0])-2;
   	else
   	    time.fechaRef=datenum(fechaRef);
   	end
	dates=getCalendarDates(tim);dates=toCharArray(toString(dates))';
	% Remove characters:
	dates(strfind(upper(dates),'T'))=' ';dates(strfind(upper(dates),'Z'))=' ';
	dates=strread(dates,'%s','delimiter',',');dates=strvcat(dates);dates=datenum(dates);
   	time.StartDate=min(dates);time.EndDate=max(dates);
   	time.dailyList=datesym(dates,'yyyymmddhh');
	time.Calendar={'Standard'};calendar=0;
	if ~isempty(findAttribute(tim,'Calendar'))
		aux=lower(toCharArray(toString(getAttributes(tim)))');
		sd=strfind(aux,'calendar');
		if ~isempty(sd)
			sd=union(findstr('360_day',aux),findstr('360day',aux));
			sd1=union(union(findstr('no_leap',aux),findstr('noleap',aux)),union(findstr('365_day',aux),findstr('365day',aux)));
			if isempty(sd) & isempty(sd1),
				time.Calendar={'Standard'};
				calendar=0;
			elseif isempty(sd1),
				time.Calendar={'360_day'};
				calendar=1;
			else,
				time.Calendar={'no_leap'};
				calendar=2;
			end
		end
	end
end
if nargout>2
	dimensiones=grid.getShape();
	dimensiones=double(dimensiones);
	coordSystem.Dimensions=dimensiones;
	lat=getLatAxis(gds);lat=lat.read;coordSystem.lat=double(squeeze(copyToNDJavaArray(lat)));
	lon=getLonAxis(gds);lon=lon.read;coordSystem.lon=double(squeeze(copyToNDJavaArray(lon)));
    if (length(double(getShape(lon)))==1)
        [coordSystem.lon,coordSystem.lat]=meshgrid(coordSystem.lon,coordSystem.lat);
    end
    if hasVerticalAxis(gds), % pressName=toCharArray(getName(alt))';
        mm=methods(gds);indH=find(ismember(mm,{'getHeightAxis';'getZaxis';'getVerticalAxis';'getElevationAxis'}));
        if ~isempty(indH)
            h=1;
            while h<=length(indH)
                try
                    alt=eval([mm{indH(h)} '(gds)']);altValues=alt.read;coordSystem.pressure=double(squeeze(copyToNDJavaArray(altValues)));
                    if strcmp(alt.getUnitsString,'Pa'),coordSystem.pressure=coordSystem.pressure/100;end
                    h=length(indH)+1;
                catch
                    h=h+1;
                end
            end
        end
    end
	switch landMask
		case {0;'no';'false'}
			coordSystem.land=repmat(1,size(coordSystem.lon));
		case {1;'yes';'true'}
			coordSystem.land=repmat(1,size(coordSystem.lon));
			sftlfile=textread([rootPath '/sftlf.txt'],'%s','delimiter','\n');
			sftlfDataset=GridDataset.open(deblank(sftlfile));
			sftlfNC=getNetcdfDataset(sftlfDataset);
			sftlfGrids=getGrids(sftlfDataset);sftlfGrids=toString(sftlfGrids);
			sftlfGrids=toCharArray(sftlfGrids)';sftlfGrids=sftlfGrids(2:end-1);
		    sftlfGrids=strread(sftlfGrids,'%s','delimiter',',');sftlfGrid=[];
			if isempty(union(strmatch('sftlf',sftlfGrids),strmatch('sftls',sftlfGrids)))
				sftlfGrid=sftlfNC.findVariable('sftlf');sftlsGrid=sftlfNC.findVariable('sftls');
				if isempty(sftlfGrid) & isempty(sftlsGrid),
					warning(['There is not sftlf or sftls nc-file for this model or the url is wrong']);
				elseif ~isempty(sftlsGrid)
					sftlfGrid=sftlsGrid;
				end
			elseif isempty(strmatch('sftlf',sftlfGrids))
				sftlfGrid=sftlfDataset.findGridByName('sftls');
			else
				sftlfGrid=sftlfDataset.findGridByName('sftlf');
			end
			if ~isempty(sftlfGrid)
				met=methods(sftlfGrid);
				if ismember('VariableDS',met)
					sftlf=sftlfGrid;
				elseif ismember('GeoGrid',met)
					sftlf=getVariable(sftlfGrid);
				end
				sftlf=sftlf.read;
				coordSystem.land=double(squeeze(copyToNDJavaArray(sftlf)));
				if isempty(threshold)
					threshold=0.5*nanmax(coordSystem.land(:));
				end
				coordSystem.land(find(coordSystem.land<threshold))=0;
				coordSystem.land(find(coordSystem.land>=threshold))=1;
			end
	end
end

function d = div(a,b)
% DIV Integer division
% d = div(a,b)

d = floor(a / b);        
