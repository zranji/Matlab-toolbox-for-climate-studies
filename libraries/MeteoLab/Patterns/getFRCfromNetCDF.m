
function [data,dmn]=getFRCfromNetCDF(ctl,dmn,varargin)
% This function load the patterns or data of Climatic Models (GCMs) 
% Input:
	% - ctl: Struct with the next fields
		% - cam: path of the data.
		% - fil: This argument corresponds to the climatic scenario.
		% - model: String with the name of Model (MPI_ECHAM5, BCCR_BCM2, CSIRO_MK3, etc...).
		% - run: {1} default. This is an optional field with the run of the model.
	% - dmn: Struct with the domain information. This struct must have the next fields:
		% - lon= 1*nlon matrix with the longitudes.
		% - lat= 1*nlat matrix with the latitudes.
		% - tim= times
		% - startDate= startDate
		% - endDate= endDate
		% - par=Z,1000;Z,925;Z,850;Z,700;Z,500;Z,300;
		% - par=T,1000;T,925;T,850;T,700;T,500;T,300;
		% - format: this is the data set format {grib or netcdf}.
	% Optional parameters:
		% - dates: This argument define the dates loaded. In absence of it, the function
		% use the dates of the domain. The format used can be: 2 dimensional cell, datevec, 
		% datenum or datesym yyyymmdd.
		% - interpolator: {'linear'} for a bilinear interpolation (regular grids) or 'triangular' for a Delaunay interpolation (irregular grids).
% Output:
	% - data: Ndays x (Nvar*Nest) Matrix.
	% - dmn: Struct with the domain information. This struct must have the next fields:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example:
% MPEH5 Snowfall :
% ctl.cam='//oceano.macc.unican.es/gmeteo/DATA/CERA/MPEH5/20C3M_r3/';ctl.fil='20C3M';
% ctl.model='MPI_ECHAM5';ctl.run=3;
% dmn=readDomain('//oceano.macc.unican.es/gmeteo/DATA/CERA/MPEH5/20C3M_r3/domain.cfg');
% dmn.src='//oceano.macc.unican.es/gmeteo/DATA/CERA/MPEH5/20C3M_r3/';
% daysExample=datesym(datenum('01-Jan-1991'):datenum('31-Dec-1991')','yyyymmdd');
% [data,dmn1]=getFRCfromNetCDF(ctl,dmn,'dates',daysExample);
% [data1,dmn2]=loadGCM(ctl,dmn,'dates',daysExample);
% figure,
% subplot(1,2,1), plot(nansum(data-data1))
% subplot(1,2,2), plot(nansum(data-data1,2))
import java.io.*;
import java.util.*;
import java.util.zip.*;
import ucar.nc2.dt.grid.*
import ucar.nc2.dt.grid.GridDataset.*

if isempty(dmn)
	dmn=readDomain([ctl.cam '/domain.cfg']);
elseif ischar(dmn)
	dmn=readDomain(dmn);
elseif ~isstruct(dmn)
	error('The domain must be empty, a structure or a string');
end

switch dmn.step
    case 'Y'
        fechaIni=datevec(datenum(dmn.startDate));
        anios=datevec(datenum(dmn.startDate):datenum(dmn.endDate)');
        anios=unique(anios(:,1));
        anDate=[anios repmat(fechaIni(2:end),length(anios),1)];
    case 'M'
        format='yyyymm';
        anDate=datevec(datenum(dmn.startDate):datenum(dmn.endDate)');
        [anDate1,I1,I2]=unique(anDate(:,1:2),'rows');
        anDate=[anDate1 anDate(I1,3:end)];
    otherwise
        anDate=datevec(datenum(dmn.startDate):datenum(stepvec(dmn.step)):datenum(dmn.endDate)');
end

tableFileName='';
anHour=[];
interpolator='linear';
warnings='on';
landMask=0;rootPath=[];threshold=[];boundingBox=[];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
		case 'dates',  anDate = varargin{i+1};
        case 'tablefilename', tableFileName= varargin{i+1};
		case 'anhour', anHour=varargin{i+1};
		case 'interpolator', interpolator=varargin{i+1};
		case 'warning', warnings=varargin{i+1};
		case 'landmask', landMask=varargin{i+1};
		case 'threshold', threshold=varargin{i+1};
		case 'boundingbox', boundingBox=varargin{i+1};
		case 'path', rootPath=varargin{i+1};
		otherwise, warning('Unknown optional argument: %s',varargin{i});
    end
end
if(iscell(anDate))
	switch dmn.step
		case 'Y'
			fechaIni=datevec(datenum(dmn.startDate));
			anios=datevec(datenum(dmn.startDate):datenum(dmn.endDate)');
			anios=unique(anios(:,1));
			anDate=[anios repmat(fechaIni(2:end),length(anios),1)];
		case 'M'
			format='yyyymm';
			anDate=datevec(datenum(dmn.startDate):datenum(dmn.endDate)');
			[anDate1,I1,I2]=unique(anDate(:,1:2),'rows');
			anDate=[anDate1 anDate(I1,3:end)];
		otherwise
			anDate=datevec(datenum(dmn.startDate):datenum(stepvec(dmn.step)):datenum(dmn.endDate)');
	end
end

switch warnings
	case {'on';1;'yes'}
		warning('on','all');
	case {'off';0;'no'}
		warning('off','all');
end

ctlname=[ctl.cam ctl.fil];
if(isempty(tableFileName))
    tableFileName=[ctl.cam 'Table.txt'];
    if isempty(dir(tableFileName))
        tableFileName=[ctl.cam 'table.txt'];
    end
end

urls=textread(ctlname,'%s','delimiter','\n');
headerlines=strmatch('#!',urls);
if ~isempty(headerlines)
	urls=strvcat(urls{headerlines});urls=urls(:,3:end);
	root=strmatch('rootDir',urls);
	if ~isempty(root)
		sd=findstr('=',urls(root,:));
		ctl.cam=deblank(urls(root,sd(1)+1:end));
	end
end

dmn=parseDomain(dmn,tableFileName);
years=unique(anDate(:,1));
dmn.dailyList=unique(datesym(datenum(anDate),'yyyymmdd'),'rows');
ndata=size(dmn.dailyList,1);
dmn.startDate=datestr(datenum(anDate(1,:)));
dmn.endDate=datestr(datenum(anDate(end,:)));
variab=size(dmn.par,1);
% nnodes=size(dmn.nod,2);
% data=NaN(ndata,variab*nnodes);
[anio,varCode,levels,nameFile]=textread(ctlname,'%s%s%s%s%*[^\n]','delimiter',',','commentstyle','shell');
C=[anio varCode levels];
for v=1:variab,
	if isnumeric(dmn.par{v,3})
		anDates=unique(datesym(datenum([anDate(:,1:3) dmn.par{v,3}*ones(size(anDate,1),1) anDate(:,5:6)]),'yyyymmddhh'),'rows');
	else
		anDates=unique(datesym(datenum([anDate(:,1:3) 12*ones(size(anDate,1),1) anDate(:,5:6)]),'yyyymmddhh'),'rows');
	end
	indFile=find(strcmp(dmn.varTable.Id{v},C(:,2)) & strcmp(num2str(dmn.par{v,2}),C(:,3)));
	[aux,aux1,aux2]=intersect(strvcat(C(indFile,1)),anDates(:,1:4),'rows');indFile=indFile(aux1);
	CC=C(indFile,:);
	files=unique(nameFile(indFile));
    coordSystem=[];
	for i=1:length(files)
		if isempty(dir(deblank(files{i}))) & ~isempty(dir([ctl.cam deblank(files{i})]))
			file=[ctl.cam deblank(files{i})];
        else            
			file=deblank(files{i});
        end,
		if isempty(coordSystem)
			try
				[variable,time,coordSystem]=getFieldfromNetCDF(file,dmn.varTable.Id{v},'landmask',landMask,'threshold',threshold,'path',rootPath);
			catch
				[variable,time,coordSystem]=getFieldfromNetCDF(file,[dmn.varTable.Id{v} num2str(dmn.par{v,2})],'landmask',landMask,'threshold',threshold,'path',rootPath);
			end
            d=length(coordSystem.Dimensions);
            if d==3
                nlat=coordSystem.Dimensions(2);
                nlon=coordSystem.Dimensions(3);
            elseif d==4
                nlat=coordSystem.Dimensions(3);
                nlon=coordSystem.Dimensions(4);
            end
            % 			[nlat,nlon]=size(coordSystem.lat);
            ilat=1:nlat;ilon=1:nlon;
			coordSystem.lon(coordSystem.lon>180)=coordSystem.lon(coordSystem.lon>180)-360;
			[coordSystem.lon,ilon2]=sort(coordSystem.lon,2);ilon2=unique(ilon2,'rows');
			if ~isfield(dmn,'nod') & ~isempty(boundingBox)
				indLon=find(coordSystem.lon>=boundingBox(1,1) & coordSystem.lon<=boundingBox(2,1));
				indLat=find(coordSystem.lat>=boundingBox(1,2) & coordSystem.lat<=boundingBox(2,2));
				indNod=intersect(indLon,indLat);dmn.nod=[coordSystem.lon(indNod) coordSystem.lat(indNod)]';clear indLon indLat indNod
			elseif ~isfield(dmn,'nod') & isempty(boundingBox)
				dmn.nod=[coordSystem.lon(:) coordSystem.lat(:)]';
			end
			nnodes=size(dmn.nod,2);
			if ~exist('data','var')
				data=NaN(ndata,variab*nnodes);
			end
			xi=double(dmn.nod(1,:));yi=double(dmn.nod(2,:));
			coordSystem.land=coordSystem.land(:,ilon2);
			landPoints=find(coordSystem.land==1);seaPoints=find(coordSystem.land==0);
            if strcmp(interpolator,'triangular')
                INTP=DelaunayTri(double(coordSystem.lon(landPoints)),double(coordSystem.lat(landPoints)));
            elseif strcmp(interpolator,'nearest')
                [INTP.ind,INTP.dist]=MLknn([xi' yi'],[double(coordSystem.lon(landPoints)) double(coordSystem.lat(landPoints))],1,'Norm-2');
            end
		else
			try
				[variable,time]=getFieldfromNetCDF(file,dmn.varTable.Id{v},'landmask',landMask,'threshold',threshold,'path',rootPath);
			catch
				[variable,time]=getFieldfromNetCDF(file,[dmn.varTable.Id{v} num2str(dmn.par{v,2})],'landmask',landMask,'threshold',threshold,'path',rootPath);
			end
        end,
        if ismember(dmn.step,{'D','24:00','24h'})
			time.dailyList=strcat(time.dailyList(:,1:8),'00');nstep=8;
        elseif ismember(dmn.step,{'M'})
			time.dailyList=strcat(time.dailyList(:,1:6),'01');nstep=6;
        else
			nstep=10;
        end
		days=time.dailyList;
		switch lower(time.Calendar{:})
			case 'standard'
				ind1=[1:size(time.dailyList,1)]';ind2=ind1;
            otherwise
                if ismember(dmn.step,{'D','24:00','24h'})
                    [days,ind1,ind2]=datesym2datesym(time.dailyList(:,1:nstep),lower(time.Calendar{:}),'standard');
                else
                    ind1=[1:size(time.dailyList,1)]';ind2=ind1;
                end
		end
		[temp,ind,ie]=intersect(days(:,1:nstep),anDates(:,1:nstep),'rows');
		[ind,a1,a2]=intersect(ind,ind2);ind1=ind1(a2);
		d=length(coordSystem.Dimensions);
		disp(sprintf('loading ... %s %s', dmn.varTable.Id{v}, num2str(dmn.par{v,2})));
		zi=[];
		for ti=1:length(ind),
            readShape=double(getShape(variable));readShape=readShape(:)';readShape=[ones(1,length(readShape)-2) readShape(end-1:end)];
			if d==4,
				l=find(dmn.par{v,2}==coordSystem.pressure);
% 				data1=variable.read([ind1(ti)-1 l-1 0 0],[1 1 nlat nlon]);
				data1=variable.read([ind1(ti)-1 l-1 0 0],readShape);
				data1=double(squeeze(copyToNDJavaArray(data1)));
			elseif d==3,
% 				data1=variable.read([ind1(ti)-1 0 0],[1 nlat nlon]);
				data1=variable.read([ind1(ti)-1 0 0],readShape);
				data1=double(squeeze(copyToNDJavaArray(data1)));
			end
			data1=data1*str2num(dmn.varTable.Scale{v})+str2num(dmn.varTable.Offset{v});
            if nlon==size(data1,1),data1=data1';end
			data1=data1(:,ilon2);
			minimo=str2num(dmn.varTable.Minimum{v});
			maximo=str2num(dmn.varTable.Maximum{v});
			if ~isempty(minimo)
				data1(find(data1<minimo))=minimo;
			end
			if ~isempty(maximo)
				data1(find(data1>maximo))=maximo;
			end
			switch interpolator
				case 'linear'
					data1(seaPoints)=NaN;
					[INTP.nrows,INTP.ncols,INTP.s,INTP.t,INTP.ndx,INTP.sout,INTP.tout]=linearInterpInit(coordSystem.lon,coordSystem.lat,data1,xi,yi);
					zi=linearInterp(data1,INTP.nrows,INTP.ncols,INTP.s,INTP.t,INTP.ndx,INTP.sout,INTP.tout);
				case 'triangular'
					F=TriScatteredInterp(INTP,data1(landPoints));
					zi=F(xi,yi);
				case 'nearest'
                    data1=data1(landPoints);
					zi=data1(INTP.ind);
			end
			data(ie(a1(ti)),(1:nnodes)+nnodes*(v-1))=zi;
		end,
	end
end
