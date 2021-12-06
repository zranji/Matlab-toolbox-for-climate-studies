function [data,STRUCT]=loadObservations(STRUCT,varargin);
%[data,STRUCT]=loadObservations(STRUCT,varargin);
% Loading the observations stored in the stations defined in STRUCT.
%
% Input:
%	STRUCT: is a structure of the form
%        STRUCT.Network     - path of the stations' network directory
%		 STRUCT.Variable    - variable to be loaded (from STRUCT.Network/data)
%		 STRUCT.Stations    - file with stations ID's to be loaded.
%                             If empty [Example.Variable{1} '.stn'] is used, otherwise 'Master.stn' is used.
%                             Not required with 'ID' or 'BoundingBox' optional arguments.
%                
%	varargin: optional parameters
%       'ID'        -   cell with station IDs to be loaded.
%       'BoundingBox' - Geographical domain to be loaded. boundingBox=[minimum(longitude) minimum(latitude);maximum(longitude) maximum(latitude)];
%		'dates'		-	{'dd-mmm-yyyy','dd-mmm-yyyy'} for the start and end dates.
%       'aggregation' - window used to aggregate the data using the format 'L',
%                       where L is M, S, or Y for monthly, seasonal (DJF,MAM,JJA,SON) and
%                       yearly data, respectively.
%       'function'  -   aggregation function ({'nanmean'}, 'mean', 'max', ...).
%       'missing'   -   Maximum ratio of missing data within each
%                       aggregation window (0.1 by default). Otherwise NaN.
%       'netcdf'    -   {1, 'yes' or 'true'} if netCDF format. Default 0.
% Output:
%	data	    : m*n matrix with m data values for the n stations
%	STRUCT      : struct augmented with the fields
%				STRUCT.Unit           : for the loaded data
%				STRUCT.StartDate	  : for the loaded data
%				STRUCT.EndDate	      : for the loaded data
%               STRUCT.StepDate       : for the loaded data in hours (24:00 or D for daily),
%                                       also (M, S, Y, for monthly, seasonal or yearly data).
%               STRUCT.Length         : for the loaded data
%               STRUCT.MissingPercent : relative to the loaded data
%				STRUCT.Info           : struct with particular info for each of the stations
%					STRUCT.Info.Id
%					STRUCT.Info.Name
%					STRUCT.Info.Heigth
%					STRUCT.Info.Location
%					STRUCT.Info.StartDate	: relative to the complete stored period
%					STRUCT.Info.EndDate 	: relative to the complete stored period
%
% Example:
%        % Example 1: Loading data for Barcelona (code 8181) and Salamanca (code 8202)
%        GSN.Network={'GSN_demo'};    % Using predefined Network in '\ObservationsData'
% 		 GSN.Variable={'Precip'};
%		 [data,GSN]=loadObservations(GSN,'ID',{'8181','8202'},'dates',{'1-Jan-1990','31-Dec-1990'});
%        % WARNING: Using an absolute path. Modify it according to your path!!!!
%        GSN2.Network={'Y:\METEOLAB\MLToolbox_R2008a\ObservationsData\GSN'};  
% 		 GSN2.Variable={'Tmax'};
%        GSN2.Stations={'Europe.stn'};  % Loading stations defined in europe.stn
%		 [data2,GSN2]=loadObservations(GSN2,'dates',{'1-Jan-1990','31-Dec-1990'});
%        dat=nanmean(data2); loc=GSN2.Info.Location;  % Drawing mean temperature
%        drawStationsValue(dat,loc,'marker','t','size',1,'colorbar','true');
%
%        % Example 2: Loading aggregated data
%        GSN.Network={'Y:\METEOLAB\ObservationsData\GSN_Europe'};
%        GSN.Stations={'Europe.stn'}; 
%        GSN.Variable={'Tmax'};
%        period={'1-Jan-1971','31-Dec-2000'};
%        [dM,GSN]=loadObservations(GSN,'dates',period,'aggregation','M'); % Monthly
%        % Maximum yearly values
%        [dY,GSN]=loadObservations(GSN,'dates',period,'aggregation','Y','function','nanmax');
%
%        % Example 3: Obtaining and drawing seasonal means
%        [dS,GSN]=loadObservations(GSN,'dates',{'1-Dec-1970','30-Nov-2000'},'aggregation','S');
%        seas=squeeze(nanmean(reshape(dS,[4 30 31]),2));  % Grouping by season and averaging
%        loc=GSN.Info.Location;
%        drawStationsValue(seas,loc,'marker','t','size',2,'colorbar','true','titles',{'DJF','MAM','JJA','SON'});
%
%        % Example 4: Loading netCDF format:
%        example.Network={'Spain02'};    % Using predefined Network in '\ObservationsData'
% 		 example.Variable={'Precip'};
% 		 example.Stations={'master.stn'};
%		 [data,network]=loadObservations(example,'dates',{'1-Jan-1990','31-Dec-1990'},'netcdf',1);
%		 Using the bounding box argument:
%		 [data,network]=loadObservations(example,'boundingbox',[-10 34;5 44],'dates',{'1-Jan-1990','31-Dec-1990'},'netcdf',1);

import java.io.*;
import java.util.*;
import java.util.zip.*;
import ucar.nc2.dt.grid.*;
import ucar.nc2.dt.grid.GridDataset.*;

ZIPFILE=0;ASCFILE=0;BINFILE=1;NCFILE=0;VALUE=0;
ID=[];BB=[];
FechInic=datevec(1);
FechFinal=datevec(now);
step=[];   % Original time step of the data
block=[];  % For aggregation
funct='nanmean';
missing=0.1;
Dates={};indDates=[];
changeCalendar=0;
% User Data Getway authentication:
user='';password='';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'id', ID= varargin{i+1};
        case 'boundingbox', BB= varargin{i+1};
        case 'dates', Dates= varargin{i+1};
        case 'inddates', indDates= varargin{i+1};
        case 'aggregation', block = varargin{i+1};
        case 'function', funct = varargin{i+1};
        case 'missing', missing = varargin{i+1};
        case 'netcdf', NCFILE = varargin{i+1};
        case 'changecalendar', changeCalendar = varargin{i+1};
        case 'user',     user=varargin{i+1};
        case 'password', password=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
funct2=funct;
Precission='int16';Format='ieee-be';
NotAtNumber='';NotAtNumber=feval(Precission,-inf);

if ~isempty(user) && ~isempty(password)
    ucar.nc2.util.net.HTTPSession.setGlobalCredentialsProvider(ucar.nc2.util.net.HTTPBasicProvider(user,password));
end

datCam=STRUCT.Network{1};
if(isempty(dir(datCam)))   % The network is not in the specified directory
    METEOLAB=getMETEOLAB;  % Setting the network directory to the default one
    datCam=[METEOLAB.home '/../ObservationsData/' STRUCT.Network{1}];
    if(isempty(dir(datCam)))    % The network is not in 'ObservationsData' directory
        error(['Directory ' STRUCT.Network{1} ' cannot be found in path ' STRUCT.Network{1} ' nor ' [METEOLAB.home '/../ObservationsData/']]);
    end
end

if(~isempty(dir([datCam '/' STRUCT.Variable{1} '.txt'])))
	VALUE=1;
elseif(~isempty(dir([datCam '/data/' STRUCT.Variable{1} '.zip'])))
	ZIPFILE=1;
elseif (~isempty(dir([datCam '/data/' STRUCT.Variable{1}])))
	d=dir([datCam '/data/' STRUCT.Variable{1}]);[path,name,ext]=fileparts(d(3).name);
    if (~isempty(dir([datCam '/data/' STRUCT.Variable{1} '/url.txt'])) | ismember(ext,{'.nc';'.ncml'})),NCFILE=1;end
elseif (isempty(dir([datCam '/data/' STRUCT.Variable{1}])))
	error(['Variable ' STRUCT.Variable{1} ' cannot be found in ' [datCam '/data/'] ' (check the name)']);
end

if (~isfield(STRUCT,'Stations'))   % If no .stn file is defined using variable.stn or Master.stn
    nnvv=[STRUCT.Variable{1} '.stn'];
    if ~isempty(dir([datCam '/' nnvv]))
        STRUCT.Stations={nnvv};
        disp(['Using stations file: ' nnvv]);
    else
		if VALUE==1
			STRUCT.Stations={'stations.txt'};
			disp('Using stations file: stations.txt');
		else
			STRUCT.Stations={'Master.stn'};
			disp('Using stations file: Master.stn');
		end
    end
end

if(isempty(ID)) & (isempty(BB))  % Selecting stations from '.stn' file when no 'ID' argument is given
    d=dir(STRUCT.Stations{1});
    if isempty(d)
        stnFil=[datCam '/' STRUCT.Stations{1}]; % Default directory
        if isempty(dir(stnFil))
            error(['File ' STRUCT.Stations{1} ' cannot be found (check the name)']);
        end
    else
        stnFil=[STRUCT.Stations{1}]; % Current directory
    end
	if VALUE==1
		stnFil=[datCam '/stations.txt']; % Default directory
		fid=fopen(stnFil,'rb','ieee-be');headerLine=fgetl(fid);sd=findstr(',',headerLine);headers=cell(length(sd)+1,1);
		[headers(1),aux]=strread(headerLine,'%s%[^\n]',length(sd),'delimiter',',');
		for i=2:length(sd)
			[headers(i),aux]=strread(aux{:},'%s%[^\n]',length(sd),'delimiter',',');
		end,headers(length(sd)+1)=aux;
		[tf,idPosition]=ismember('station_id',lower(headers));
		if tf
			[ID]=textread(stnFil,[repmat('%*s',1,idPosition-1) '%s%*[^\r\n]'],'delimiter',',','headerlines',1);
            ID=ID(find(~ismember(deblank(ID(:)),{''})));
		else
            error(['Check the header of the file: ' stnFil]);
		end
	else
		[ID]=textread(stnFil,'%s','whitespace',',\n');
	end
elseif(size(ID,1)==1),
	ID=ID';
end,

if ~isempty(BB)
	if VALUE
		fid=fopen([datCam '/stations.txt'],'rb','ieee-be');headerLine=fgetl(fid);sd=findstr(',',headerLine);headers=cell(length(sd)+1,1);
		[headers(1),aux]=strread(headerLine,'%s%[^r\n]',length(sd),'delimiter',',');
		for i=2:length(sd)
			[headers(i),aux]=strread(aux{:},'%s%[^r\n]',length(sd),'delimiter',',');
		end,headers(length(sd)+1)=aux;
		[tf,idPosition]=ismember('station_id',lower(headers));[ID1]=textread([datCam '/stations.txt'],[repmat('%*s',1,idPosition-1) '%s%*[^r\n]'],'delimiter',',','headerlines',1);
		[tf,lonPosition]=ismember('longitude',lower(headers));[lon]=textread([datCam '/stations.txt'],[repmat('%*s',1,lonPosition-1) '%s%*[^r\n]'],'delimiter',',','headerlines',1);lon=str2num(strvcat(lon));
		[tf,latPosition]=ismember('latitude',lower(headers));[lat]=textread([datCam '/stations.txt'],[repmat('%*s',1,latPosition-1) '%s%*[^r\n]'],'delimiter',',','headerlines',1);lat=str2num(strvcat(lat));
	else
		[ID1,lon,lat]=textread([datCam '/Master.txt'],'%s%*s%f%f%*[^\n]','delimiter',',');
	end
	ind1=find(lon>=BB(1,1) & lon<=BB(2,1));ind2=find(lat>=BB(1,2) & lat<=BB(2,2));
	ind=intersect(ind1,ind2);ID1=ID1(ind);clear id lon lat ind1 ind2 ind
	if isempty(ID)
		ID=ID1;clear ID1
	else
		ID=intersect(deblank(ID),deblank(ID1));
	end
end,

switch NCFILE
	case {1;'yes';'true'}
        if isempty(Dates),
			[STRUCT,coord,files,gridName,Dates]=getCoordSystemfromNetCDF(datCam,ID,STRUCT,Dates);
		else
			[STRUCT,coord,files,gridName]=getCoordSystemfromNetCDF(datCam,ID,STRUCT,Dates);
        end
        Nest=length(STRUCT.Info.Height);Nfiles=size(files,1);ID=strvcat(ID);
        if (~isempty(block)) % Aggregation is only for daily data
            if(~strcmp(STRUCT.StepDate,'24:00') & ~strcmp(STRUCT.StepDate,'D'))
                error('Aggregation option is only for daily data, i.e., step=24:00 or step=D');
            elseif (~strcmp(block,'M') & ~strcmp(block,'S') & ~strcmp(block,'Y'))
                error('Aggregation parameter must be M, S, or Y.');
            end
            aggregation=1;
        else
            block='D';funct='';aggregation=0;
        end
        [variable,time,coordSystem]=getGridfromNetCDF(files(1,:),gridName);
        nDim=length(coordSystem.Dimensions);
        if nDim==3
            nlat=coordSystem.Dimensions(2);nlon=coordSystem.Dimensions(3);
        elseif nDim==4
            nlat=coordSystem.Dimensions(3);nlon=coordSystem.Dimensions(4);
        end
        switch STRUCT.StepDate
            case 'Y'
                datDate=datenum(Dates{1}):datenum(Dates{2});ncorte=4;
            case 'M'
                datDate=datenum(Dates{1}):datenum(Dates{2});ncorte=6;
            case {'D','24:00','24h','1D'}
                datDate=datenum(Dates{1}):datenum(Dates{2});ncorte=8;
            otherwise
                datDate=datenum(Dates{1}):datenum(stepvec(STRUCT.StepDate)):datenum(Dates{2});ncorte=10;
        end
        dailyList=datesym(datDate,'yyyymmddhh');dailyList=unique(dailyList(:,1:ncorte),'rows');
        STRUCT.StartDate=Dates{1};
        STRUCT.EndDate=Dates{2};
        STRUCT.dailyList=dailyList;
        switch lower(time.Calendar{:})
            case 'standard'
                STRUCT.Calendar={'standard'};
            case 'no_leap'
                STRUCT.Calendar={'no_leap'};
                [dailyList,ind1,ind2]=datesym2datesym(dailyList,'standard','no_leap');
            case '360_day'
                STRUCT.Calendar={'360_day'};
                [dailyList,ind1,ind2]=datesym2datesym(dailyList,'standard','360_day');
        end
        switch block
            case 'D'
                if changeCalendar
                    STRUCT.origCalendar=network.Calendar;
                    STRUCT.Calendar={'standard'};
                else
                    STRUCT.dailyList=dailyList;
                end
            case 'M'
                STRUCT.Aggregation=block;
                STRUCT.Function=funct;
                STRUCT.dailyList=unique(datesym(datDate,'yyyymm'),'rows');
            case 'Y'
                STRUCT.Aggregation=block;
                STRUCT.Function=funct;
                STRUCT.dailyList=unique(datesym(datDate,'yyyy'),'rows');
        end
        STRUCT.MissingPercent=NaN*zeros(1,Nest);
        ndata=size(STRUCT.dailyList,1);
        STRUCT.Length=ndata;
        data=NaN*zeros(ndata,Nest);
        final=0;contador=1;
        while final==0
            [I,A,B]=intersect(time.dailyList(:,1:ncorte),dailyList(:,1:ncorte),'rows');
            ndata=length(A);
            if ndata>0
                if isequal(I(end,:),dailyList(end,:)) || contador>=Nfiles,final=1;end
                posicion=0;
                for i=1:length(coord)
                    if nDim==3
                        aux=variable.read([A(1)-1 coord(i).Range(1) coord(i).Column],[ndata coord(i).Range(2)-coord(i).Range(1)+1 1]);
                    elseif nDim==4
                        aux=variable.read([A(1)-1 0 coord(i).Range(1) coord(i).Column],[ndata 1 coord(i).Range(2)-coord(i).Range(1)+1 1]);
                    end
                    aux=double(squeeze(copyToNDJavaArray(aux)));
                    if size(aux,2)>1
                        aux=aux(:,coord(i).Rows-coord(i).Range(1)+1);
                    elseif size(aux,1)~=ndata
                        aux=aux(coord(i).Rows-coord(i).Range(1)+1)';
                    end
                    aux(find(aux==-9999))=NaN;
                    if aggregation
                        switch block
                            case 'M',[uq,iq,jq]=unique(I(:,1:6),'rows');
                            case 'Y',[uq,iq,jq]=unique(I(:,1:4),'rows');
                        end
                        id=jq;
                        lstuq=1:length(uq);
                        newDates=uq;
                        luq=length(uq);
                        nq=histc(jq,1:luq);
                        sd=size(aux);
                        auxM=zeros([luq,sd(2:end)])+NaN;
                        for iuq=lstuq
                            d=aux(find(id==iuq),:);
                            if(~isempty(d))
                                auxM(iuq,:)=mifeval(funct,d);
                                auxM(iuq,sum(isnan(d),1)>(nq(iuq)*missing))=NaN;
                            else
                                auxM(iuq,:)=NaN;
                            end
                        end
                        [I1,A1,B1]=intersect(STRUCT.dailyList,newDates,'rows');
                        STRUCT.MissingPercent(coord(i).Index)=nanmean([STRUCT.MissingPercent(coord(i).Index);nanmean(double(isnan(auxM)))]);
                        data(A1,coord(i).Index)=auxM;
                    else
                        STRUCT.MissingPercent(coord(i).Index)=nanmean([STRUCT.MissingPercent(coord(i).Index);nanmean(double(isnan(aux)))]);
                        if changeCalendar
                            [I1,A1,B1]=intersect(B,ind2,'rows');
                            data(ind1(B1),coord(i).Index)=aux(A1,:);
                        else
                            data(B,coord(i).Index)=aux;
                        end
                    end
                    posicion=posicion+length(coord(i).Rows);
                    disp([num2str(posicion) ' stations of ' num2str(Nest) ' from file: ' deblank(files(contador,:))])
                end,
            end
            contador=contador+1;
            if final==0 & contador<=Nfiles
                [variable,time]=getGridfromNetCDF(files(contador,:),gridName);
            else
                final=1;
            end
        end
        ind=find(STRUCT.MissingPercent<1);
		disp(['  Found data for ' num2str(length(ind)) ' stations in the given period']);
        data=data(:,ind);
        STRUCT.Info.Id=STRUCT.Info.Id(ind);
        STRUCT.Info.Name=STRUCT.Info.Name(ind,:);
        STRUCT.Info.Location=STRUCT.Info.Location(ind,:);
        STRUCT.Info.Height=STRUCT.Info.Height(ind,:);
        STRUCT.MissingPercent=STRUCT.MissingPercent(ind)';
	otherwise
		switch VALUE
			case {1;'yes';'true'}
				fid=fopen([datCam '/' STRUCT.Variable{:} '.txt'],'rb','ieee-be');
				headerLine=fgetl(fid);fclose(fid);sd=findstr(',',headerLine);IDs=cell(length(sd)+1,1);
				[IDs(1),aux]=strread(headerLine,'%s%[^\n]',length(sd),'delimiter',',');ID1=IDs{1};ID1(findstr('"',ID1))='';IDs{1}=ID1;
				for i=2:length(sd)
					[IDs(i),aux]=strread(aux{:},'%s%[^\n]',length(sd),'delimiter',',');ID1=IDs{i};ID1(findstr('"',ID1))='';IDs{i}=ID1;
				end,
                IDs(length(sd)+1)=aux;ID1=IDs{length(sd)+1};ID1(findstr('"',ID1))='';IDs{length(sd)+1}=ID1;
				[IDs,I1,indCol]=intersect(deblank(ID),deblank(IDs));Nest=length(ID);STRUCT.Info.Id=IDs(I1);
				readingFormat=[repmat('%*f',1,max(indCol)) '%*[^\n]'];readingFormat((indCol-1)*3+2)='';
% 				readingFormat=[repmat('%*s',1,max(indCol)) '%*[^\n]'];readingFormat((indCol-1)*3+2)='';
				fechas=textread([datCam '/' STRUCT.Variable{:} '.txt'],'%s%*[^\n]','delimiter',',','headerlines',1);indRow=[1:length(fechas)]';
				if ~isempty(Dates),
					datesAux=datesym([datenum(Dates{1}):datenum(Dates{2})]','yyyymmdd');
					[fechas,I1,indRow]=intersect(deblank(datesAux),strvcat(deblank(fechas)),'rows');
				end
				ndata=length(fechas);
				AA=[repmat('data(:,',Nest,1) num2str([1:Nest]') repmat('),',Nest,1)];AA=reshape(AA',1,numel(AA));AA=['[' AA(1:end-1) ']'];
				eval(sprintf('%s=textread(''%s'',''%s'',''delimiter'','','',''headerlines'',1);',AA,[datCam '/' STRUCT.Variable{:} '.txt'],readingFormat));
				data=data(indRow,:);data=data(:,indCol-1);
% 				data=data(indRow,:);data=reshape(str2num(strvcat(data')),Nest,ndata)';data=data(:,indCol-1);
				STRUCT.dailyList=strvcat(fechas);STRUCT.StepDate='24:00';STRUCT.Calendar={'standard'};
				STRUCT.StartDate=datestr(datenum([str2num(STRUCT.dailyList(1,1:4)) str2num(STRUCT.dailyList(1,5:6)) str2num(STRUCT.dailyList(1,7:8)) 0 0 0]));
				STRUCT.EndDate=datestr(datenum([str2num(STRUCT.dailyList(end,1:4)) str2num(STRUCT.dailyList(end,5:6)) str2num(STRUCT.dailyList(end,7:8)) 0 0 0]));
				STRUCT.MissingPercent=100*nanmean(double(isnan(data)));STRUCT.Length=ndata;
				if ~isempty(dir([datCam '/Variables.txt']))
					nameVariablesFile=[datCam '/Variables.txt'];
				elseif ~isempty(dir([datCam '/variables.txt']))
					nameVariablesFile=[datCam '/variables.txt'];
				end
				fid=fopen(nameVariablesFile,'rb','ieee-be');headerLine=fgetl(fid);sd=findstr(',',headerLine);headers=cell(length(sd)+1,1);
				[headers(1),aux]=strread(headerLine,'%s%[^\n]',length(sd),'delimiter',',');
				for i=2:length(sd)
					[headers(i),aux]=strread(aux{:},'%s%[^\n]',length(sd),'delimiter',',');
				end,headers(length(sd)+1)=aux;
				eval(sprintf('%s=textread(''%s'',''%s'',''delimiter'','','',''headerlines'',1);',['[' headerLine ']'],nameVariablesFile,[repmat('%s',1,length(headers)) '%*[^\n]']));
				[tf,i1]=ismember('variable_id',lower(headers));[varName]=textread(nameVariablesFile,[repmat('%*s',1,i1-1) '%s%*[^\n]'],'delimiter',',','headerlines',1);
				[tf,i2]=ismember(STRUCT.Variable,varName);indFields=setdiff(1:length(headers),i1);for i=indFields,STRUCT=setfield(STRUCT,headers{i},eval(sprintf('%s(i1)',headers{i})));end
				fid=fopen([datCam '/stations.txt'],'rb','ieee-be');headerLine=fgetl(fid);sd=findstr(',',headerLine);headers=cell(length(sd)+1,1);
				[headers(1),aux]=strread(headerLine,'%s%[^\n]',length(sd),'delimiter',',');
				for i=2:length(sd)
					[headers(i),aux]=strread(aux{:},'%s%[^\n]',length(sd),'delimiter',',');
				end,headers(length(sd)+1)=aux;
				eval(sprintf('%s=textread(''%s'',''%s'',''delimiter'','','',''headerlines'',1);',['[' headerLine ']'],[datCam '/stations.txt'],[repmat('%s',1,length(headers)) '%*[^\r\n]']));
				[tf,i1]=ismember('station_id',lower(headers));id=textread([datCam '/stations.txt'],[repmat('%*s',1,i1-1) '%s%*[^\r\n]'],'delimiter',',','headerlines',1);
				[id,I1,I2]=intersect(deblank(id),deblank(STRUCT.Info.Id));
				indFields=setdiff(1:length(headers),i1);
				for i=indFields,
					eval(sprintf('auxField=%s;',headers{i}));if ~isempty(str2num(strvcat(auxField))),auxField=str2num(strvcat(auxField));end
					if isempty(findstr('.',lower(headers{i})))
						STRUCT.Info=setfield(STRUCT.Info,lower(headers{i}),auxField(I1));eval(sprintf('STRUCT.Info.%s(I2)=auxField(I1);',lower(headers{i})));
					else
						fieldName=lower(headers{i});fieldName(findstr('.',lower(headers{i})))='_';
						STRUCT.Info=setfield(STRUCT.Info,fieldName,auxField(I1));eval(sprintf('STRUCT.Info.%s(I2)=auxField(I1);',fieldName));
					end
				end
				if isfield(STRUCT.Info,'longitude') & isfield(STRUCT.Info,'latitude'),STRUCT.Info.Location=[STRUCT.Info.longitude(:) STRUCT.Info.latitude(:)];end		
		otherwise
			[zvar zunit zstep zname]=textread([datCam '/Variables.txt'],'%s%s%s%s','delimiter',',','whitespace','\b\n\r');
			zind=find(strcmp(STRUCT.Variable,zvar));
			if(isempty(zind))
				error(['Variable ' STRUCT.Variable{1} ' cannot be found in file ' datCam '/Variables.txt']);
			end
			STRUCT.Unit=zunit{zind};
			STRUCT.StepDate=zstep{zind};
			if (~isempty(block)) % Aggregation is only for daily data
				aggregation=1;
			else
				funct='';
				aggregation=0;
			end
			% Data formats (.txt, .bin, zipped or not), and .NETCDF
			if(~isempty(dir([datCam '/data/' STRUCT.Variable{1} '.zip'])))
				ZIPFILE=1;
			elseif (isempty(dir([datCam '/data/' STRUCT.Variable{1}])))
				error(['Variable ' STRUCT.Variable{1} ' cannot be found in ' [datCam '/data/'] ' (check the name)']);
			end
			ID=strvcat(ID);
			[id,nam,lon,lat,alt,meta]=textread([datCam '/Master.txt'],'%s%s%f%f%f%[^\n]','delimiter','\t,','whitespace','\b\n\r');
			loc=[lon,lat];nam=strvcat(nam);NStn=size(ID,1);
			disp(sprintf('Loading %s for %d specified stations...',STRUCT.Variable{1},NStn));
			if(ZIPFILE),optZ='yes';surZ='.zip';else,optZ='no';surZ='';end
			llenas=zeros(NStn,1);
			n=1;contador=1;
			while n<=NStn   % Checking the number of stations with data
				PATHget=[datCam '/data/' STRUCT.Variable{1} surZ];
				FILEget=[deblank(ID(n,:)) '.bin'];
				aux=getStation(PATHget,FILEget,'ZIPFILE',optZ,'FILEFORMAT','BINFILE','CHECKEXISTENCE','yes');
				if isempty(aux.startDate)
					FILEget=[deblank(ID(n,:)) '.txt'];
					aux=getStation(PATHget,FILEget,'ZIPFILE',optZ,'FILEFORMAT','ASCFILE','CHECKEXISTENCE','yes');
				end
				if ~isempty(aux.startDate)
					Info.StartDate{contador}=aux.startDate;
					Info.EndDate{contador}=aux.endDate;
					contador=contador+1;
					llenas(n)=1;
				end
				n=n+1;
			end
			llenas=find(llenas==1);
			if length(llenas)==0,
				disp(['  Found 0 stations (check the stations IDs)']); data=[];
			else
				disp(['  Found ' num2str(length(llenas)) ' stations, with reference hour ' datestr(Info.StartDate{1},15)]);
				if isempty(Dates)
					Fechaini=min(datenum(strvcat(Info.StartDate)));
					Fechafin=max(datenum(strvcat(Info.EndDate)));
					disp(['  Setting data period to ' datestr(Fechaini,1) ' - ' datestr(Fechafin,1)]);
				else
					Fechaini=datenum(Dates{1});
					Fechafin=datenum(Dates{2});
				end
				STRUCT.StartDate=datestr(Fechaini,0);
				STRUCT.EndDate=datestr(Fechafin,0);
				switch STRUCT.StepDate
					case 'Y'
						format='yyyy';
						STRUCT.dailyList=unique(datesym(Fechaini:Fechafin,format),'rows');
					case 'S'
						format='YYYYSS';
						STRUCT.dailyList=unique(datesym(Fechaini:Fechafin,format),'rows');
					case 'M'
						format='yyyymm';
						STRUCT.dailyList=unique(datesym(Fechaini:Fechafin,format),'rows');
					case {'D','24:00'}
						format='yyyymmdd';
						STRUCT.dailyList=datesym(Fechaini:Fechafin,'yyyymmdd');
					case {'12h','12H','12:00'}
						format='yyyymmdd12';
						paso=datenum(stepvec(STRUCT.StepDate));
						STRUCT.dailyList=unique(datesym(Fechaini:paso:Fechafin,format),'rows');
					case {'6h','6H','06:00'}
						format='yyyymmdd66';
						paso=datenum(stepvec(STRUCT.StepDate));
						STRUCT.dailyList=unique(datesym(Fechaini:paso:Fechafin,format),'rows');
					case {'3h','3H','03:00'}
						format='yyyymmdd33';
						paso=datenum(stepvec(STRUCT.StepDate));
						STRUCT.dailyList=unique(datesym(Fechaini:paso:Fechafin,format),'rows');
					case {'1h','1H','H','01:00'}
						format='yyyymmddhh';
						paso=datenum(stepvec(STRUCT.StepDate));
						STRUCT.dailyList=unique(datesym(Fechaini:paso:Fechafin,format),'rows');
					otherwise
						format='yyyymmddhh';
						paso=datenum(stepvec(STRUCT.StepDate));
						STRUCT.dailyList=unique(datesym(Fechaini:paso:Fechafin,format),'rows');
				end
				if (aggregation)
					STRUCT.Aggregation=block;
					STRUCT.Function=funct;
					STRUCT.dailyList=datesym2datesym(STRUCT.dailyList,STRUCT.StepDate,block);
				end
				STRUCT.Length=size(STRUCT.dailyList,1);
				data=NaN*zeros(STRUCT.Length,length(llenas));
				STRUCT.MissingPercent=[];
				STRUCT.Info=[];
				cont=1;
				for i=1:length(llenas)
					iStn=llenas(i);
					iN=strmatch(deblank(ID(iStn,:)),id,'exact');
					nostruct=0;
					if(~isempty(iN))
						PATHget=[datCam '/data/' STRUCT.Variable{1} surZ];
						FILEget=[deblank(ID(iStn,:)) '.bin'];
						DATA=getStation(PATHget,FILEget,'ZIPFILE',optZ,'FILEFORMAT','BINFILE');
						if isempty(DATA.startDate)
							FILEget=[deblank(ID(iStn,:)) '.txt'];
							DATA=getStation(PATHget,FILEget,'ZIPFILE',optZ,'FILEFORMAT','ASCFILE');
						end,
						if(aggregation),
							[dataA,dateList]=aggregateData(DATA.data,{DATA.startDate,DATA.endDate},block,'aggDate',...
								{STRUCT.StartDate,STRUCT.EndDate},'missing',missing,'aggfun',funct,'step',DATA.step);
							if isnan(nansum(dataA)),dateList=[];end
						else
							switch STRUCT.StepDate
								case {'Y','S','M','D','24:00'}
									periodT=datenum(STRUCT.StartDate):datenum(STRUCT.EndDate);
								otherwise
									periodT=datenum(STRUCT.StartDate):datenum(stepvec(STRUCT.StepDate)):datenum(STRUCT.EndDate);
							end
							periodT1=unique(datesym(periodT,format),'rows');
							switch DATA.step
								case {'Y','S','M','1M','D','24:00'}
									period=datenum(DATA.startDate):datenum(DATA.endDate);
								otherwise
									period=datenum(DATA.startDate):datenum(stepvec(DATA.step)):datenum(DATA.endDate);
							end
							period1=unique(datesym(period,format),'rows');
							[dateList,ind1,dateA]=intersect(period1,periodT1,'rows');
						end
						if(~isempty(dateList))
							if(aggregation)
								data(:,cont)=dataA;
							else
								data(dateA,cont)=DATA.data(ind1);
							end
							STRUCT.Info.Id(cont,:)=id(iN,:);
							STRUCT.Info.Name(cont,:)=nam(iN,:);
							STRUCT.Info.Height(cont,:)=alt(iN,:);
							STRUCT.Info.Location(cont,:)=loc(iN,:);
							STRUCT.Info.StartDate(cont,:)=deblank(DATA.startDate);
							STRUCT.Info.EndDate(cont,:)=deblank(DATA.endDate);
							STRUCT.MissingPercent(cont,:)=(100*sum(isnan(data(:,cont)))/size(data,1));
							cont=cont+1;
						end
					end
					if(i>2& ~mod(i-1,100))
						disp(['    ' num2str(i,'%5d') ' stations loaded (still loading)...']);
					end
				end
				if cont>1
					data=data(:,1:cont-1);
					disp(['  Found data for ' num2str(cont-1) ' stations in the given period']);
				else
					data=[];
					disp('  No data found for the given stations in the given period');
				end
			end
	end
end

function [STRUCT,coord,files,gridName,Dates]=getCoordSystemfromNetCDF(datCam,Ids,Variable,Dates)

if isfield(Variable,'Variable')
	STRUCT=Variable;
	Variable=STRUCT.Variable;
end
[id,nam,lon,lat,alt,meta]=textread([datCam '/Master.txt'],'%s%s%f%f%f%[^\n]','delimiter','\t,','whitespace','\b\n\r');
[Ids,I1,I2]=intersect(deblank(id),deblank(Ids));
STRUCT.Info.Id=Ids;
STRUCT.Info.Name=strvcat(nam(I1));
STRUCT.Info.Location=[lon(I1) lat(I1)];
STRUCT.Info.Height=alt(I1);
% Obtenemos los puntos del grid a leer a partir de los Ids:
Ids=strvcat(Ids);corte=0.5*size(Ids,2);
rows=str2num(Ids(:,1:corte));cols=str2num(Ids(:,corte+1:end));
I1=unique(rows);I2=unique(cols);
nrows=length(I1);ncols=length(I2);
for i=1:ncols
	coord(i).Column=I2(i)-1;
	coord(i).Index=find(cols==I2(i));
	coord(i).Rows=rows(coord(i).Index)-1;
	coord(i).Range=[min(coord(i).Rows) max(coord(i).Rows)];
end
[zvar zunit zstep zname]=textread([datCam '/Variables.txt'],'%s%s%s%s%*[^\n]','delimiter',',');
zind=find(strcmp(deblank(Variable),deblank(zvar)));
if(isempty(zind))
    error(['Variable ' Variable{1} ' cannot be found in file ' datCam '/Variables.txt']);
end
STRUCT.Unit=zunit{zind};
STRUCT.StepDate=zstep{zind};
sd=findstr(' gridName=',zname{zind});
if isempty(sd)
    STRUCT.Name=zname{zind};
    gridName=deblank(zvar{zind});
else
    zname=zname{zind};
    STRUCT.Name=deblank(zname(1:sd-1));
    gridName=deblank(zname(sd+10:end));
end
if(~isempty(dir([datCam '/data/' Variable{1} '/url.txt'])))
    files=textread([datCam '/data/' Variable{1} '/url.txt'],'%s','delimiter','\n');
    files=strvcat(files);
else
    d=dir([datCam '/data/' Variable{1}]);
    if ~isempty(d)
        files=strvcat(d.name);
        files=files(3:end,:);indFiles=repmat(NaN,size(files,1),1);
        for i=1:size(files,1)
            [pathFile,nameFile,extFile]=fileparts(deblank(files(i,:)));
            if strmatch('.nc',extFile);indFiles(i)=1;end
        end
        files=files(find(~isnan(indFiles)),:);
        files=strcat([datCam '/data/' Variable{1} '/'],files);
    else
        error(['Variable ' Variable{1} ' cannot be found in ' [datCam '/data/'] ' (check the name)']);
    end
end
if isempty(Dates)
	endDate=-inf;startDate=inf;
	for i=1:size(files,1)
		[aux1,time]=getGridfromNetCDF(deblank(files(i,:)),gridName);
        endDate=max(endDate,time.EndDate);startDate=min(startDate,time.StartDate);clear aux1 time
    end
    Dates={datestr(startDate);datestr(endDate)};
end

function [variable,time,coordSystem]=getGridfromNetCDF(file,gridName)

import ucar.nc2.dt.grid.*
import ucar.nc2.dt.grid.GridDataset.*

file=deblank(file);
if strcmp(file(1:2),'//')
    file=['file://' file];
end

dataset=GridDataset.open(deblank(file));
nc=getNetcdfDataset(dataset);
grids=getGrids(dataset);
grids=toString(grids);
grids=toCharArray(grids)';grids=grids(2:end-1);
if isempty(grids)
    grid=nc.findVariable(gridName);
else
    grids=strread(grids,'%s','delimiter',',');
    if isempty(strmatch(gridName,grids))
        try
            grid=nc.findVariable(gridName);
        catch
            error(['There is not grids called: ' gridName ' in file: ' deblank(file) ' (check the name)']);
        end
    else
        grid=dataset.findGridByName(gridName);
    end
end

met=methods(grid);
if ismember('VariableDS',met)
    variable=grid;
elseif ismember('GeoGrid',met)
    variable=getVariable(grid);
end

if nargout>1
	tim=nc.findVariable('time');
	aux=toString(tim);aux=toCharArray(aux)';
	aux=strread(aux,'%s','delimiter','\n');
	sd=strmatch(':units',aux);
	fechaRef=aux{sd};
	sd=findstr('since',fechaRef);fechaRef1=fechaRef(sd+6:min(union(findstr(';',fechaRef),max(findstr('"',fechaRef))))-1);
    if strmatch('0000',fechaRef1),
        time.fechaRef=datenum(fechaRef1)-datenum([2001 1 1 0 0 0])+1;
    elseif ismember(lower(fechaRef),{':units = "hours since 1-1-1 00:00:0.0";';':units = "hours since 1-01-01 00:00:00";'})
        time.fechaRef=datenum([1 1 1 0 0 0])-2;
    elseif strmatch(fechaRef1(end-1:end),' 0')
        fechaRef1=fechaRef1(1:end-2);time.fechaRef=datenum(fechaRef1);
    else
        try,time.fechaRef=datenum(fechaRef1);catch,time.fechaRef=datenum([fechaRef1(1:10) ' ' fechaRef1(12:end-1)]);end
    end
	factor=1;if ~isempty(findstr('hour',lower(fechaRef))),factor=24;elseif ~isempty(findstr('second',lower(fechaRef))),factor=24*3600;end
	sd=strmatch(':calendar',aux);
	time.Calendar={'Standard'};
	calendar=0;
	if ~isempty(sd)
		calendar=aux{sd};
		sd=union(union(findstr('360_day',calendar),findstr('360day',calendar)),findstr('360 day',calendar));
		sd1=union(union(findstr('no_leap',calendar),findstr('noleap',calendar)),union(findstr('365_day',calendar),findstr('365day',calendar)));
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
	times=getCoordValues(tim);times=times/factor;
    time.StartDate=times(1)+time.fechaRef;
    time.EndDate=times(end)+time.fechaRef;
	Ndays=length(time.StartDate:time.EndDate);
	time.dailyList=datesym(times+time.fechaRef,'yyyymmddhh');
	if length(times)>Ndays,time.dailyList=datesym(times+time.fechaRef,'yyyymmddhh');end
	switch calendar
		case 1
		    time.StartDate=datenum(datevec(time.fechaRef)+sign(times(1))*[div(abs(times(1)),360) div(rem(abs(times(1)),360),30) rem(rem(abs(times(1)),360),30) (times(1)-floor(times(1)))*24 0 0]);
		    time.EndDate=datenum(datevec(time.fechaRef)+sign(times(end))*[div(abs(times(end)),360) div(rem(abs(times(end)),360),30) rem(rem(abs(times(end)),360),30) (times(end)-floor(times(end)))*24 0 0]);
            fechaRef=datevec(time.fechaRef);
			fechaRef=360*fechaRef(1)+30*(fechaRef(2)-1)+fechaRef(3)+fechaRef(4)/24;
			times=times+fechaRef;
			aux=[floor(div(times,360)) floor(div(floor(rem(times,360)),30)) floor(rem(rem(times,360),30)) floor((times-floor(times))*24) zeros(length(times),2)];
			ind1=find(sum(aux(:,2:3),2)==0);
			aux(ind1,1:2)=[aux(ind1,1)-1 aux(ind1,2)+12];
			ind1=find(aux(:,3)==0);
			aux(ind1,3)=30;
			ind1=setdiff([1:size(aux,1)],ind1);aux(ind1,2)=aux(ind1,2)+1;
			time.dailyList=datesym(aux,'yyyymmddhh');
		case 2
			noleapYear=datevec(datenum('01-Jan-1993'):datenum('31-Dec-1993'));noleapYear(:,1)=0;
			fechaRef=datevec(time.fechaRef);
			[a1,a2,a3]=intersect([0 fechaRef(2:end)],noleapYear,'rows');
			fechaRef=365*fechaRef(1)+a3-1;
			[years,I1,I2]=unique(floor((fechaRef+times)/365));
			time.StartDate=datenum([years(1) 0 0 0 0 0]+noleapYear(floor(fechaRef+times(1)-floor(floor(fechaRef+times(1))/365)*365)+1,:));
			time.EndDate=datenum([years(end) 0 0 0 0 0]+noleapYear(floor(fechaRef+times(end)-floor(floor(fechaRef+times(end))/365)*365)+1,:));
			time.dailyList=repmat(NaN,length(times),6);
			for k=1:length(years)
				daysYear=find(I2==k);
				time.dailyList(daysYear,:)=repmat([years(k) 0 0 0 0 0],length(daysYear),1)+noleapYear(floor(fechaRef+times(daysYear)-floor(floor(fechaRef+times(daysYear))/365)*365)+1,:);
                time.dailyList(daysYear,4)=24*(fechaRef+times(daysYear)-floor(fechaRef+times(daysYear)));
			end
			time.dailyList=datesym(datenum(time.dailyList),'yyyymmddhh');
	end
	if nargout>2
		dimensiones=grid.getShape();
		dimensiones=double(dimensiones);
		coordSystem.Dimensions=dimensiones;
		nDim=length(coordSystem.Dimensions);
		if nDim==3
		    ndataNew=coordSystem.Dimensions(1);nlat=coordSystem.Dimensions(2);nlon=coordSystem.Dimensions(3);
		elseif nDim==4
		    ndataNew=coordSystem.Dimensions(1);nlat=coordSystem.Dimensions(3);nlon=coordSystem.Dimensions(4);
		end
		if isempty(nc.findVariable('lon')) & isempty(nc.findVariable('longitude'))
			if ~isempty(nc.findVariable('rlon'))
				disp(['The coordinate system of your netCDF file has rotated the longitude and latitude']);
				longitud=nc.findVariable('rlon');
				latitud=nc.findVariable('rlat');
			elseif ~isempty(nc.findVariable('X'))
				disp(['The coordinate system of your netCDF file has projected the longitude and latitude']);
				longitud=nc.findVariable('X');
				latitud=nc.findVariable('Y');
			else
				error(['There is any problem with the coordinate system of your netCDF file']);
			end
		elseif isempty(nc.findVariable('lon'))
		    longitud=nc.findVariable('longitude');
		    latitud=nc.findVariable('latitude');
		else
		    longitud=nc.findVariable('lon');
		    latitud=nc.findVariable('lat');
		end
		lon=longitud.read;
		coordSystem.lon=double(squeeze(copyToNDJavaArray(lon)));
		lat=latitud.read;
		coordSystem.lat=double(squeeze(copyToNDJavaArray(lat)));
		if length(coordSystem.lon(:))==nlon
		    [coordSystem.lon,coordSystem.lat]=meshgrid(coordSystem.lon,coordSystem.lat);
		end
        if nDim==4
            if ~isempty(nc.findVariable('lev'))
                pressName='lev';
            elseif ~isempty(nc.findVariable('plev'))
                pressName='plev';
            elseif ~isempty(nc.findVariable('level'))
                pressName='level';
            elseif ~isempty(nc.findVariable('height_2m'))
                pressName='height_2m';
            elseif ~isempty(nc.findVariable('height'))
                pressName='height';
            elseif ~isempty(nc.findVariable('heightv'))
                pressName='heightv';
            else
                error(['There is any problem with the pressure coordinate of your netCDF file']);
            end
            plev=nc.findVariable(pressName);
            p=plev.read;
            coordSystem.pressure=squeeze(copyToNDJavaArray(p));
			if strcmp(plev.getUnitsString,'Pa'),coordSystem.pressure=coordSystem.pressure/100;end
        end
	end
end

function y=mifeval(fun,x,dim)

if any(strcmp(fun,{'min','max'}))
    y=feval(fun,x,[],1);
else
    y=feval(fun,x);
end

function d = div(a,b)
% DIV Integer division
% d = div(a,b)

d = floor(a / b);        
