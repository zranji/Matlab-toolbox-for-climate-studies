
function [data,dmn,fcDate]=loadGCM(dmn,ctl,varargin)
% This function load the patterns or data of Climatic Models (GCMs)  or Reanalysis (ERA40, NCEP, etc).
% This function uses two auxiliar functions, getFRCfromGRIB and getFRCformNetCDF.
% Input:
	% - ctl: path of the file with the urls.
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
		% The next arguments are only used in the case of reanalysis:
		% - ds: 
		% - anHour: analysis hour.
		% - tableFileName: 
		% - ignoremissing:
		% - interpolator: {'linear'} for a bilinear interpolation (regular grids) or 'triangular' for a Delaunay interpolation (irregular grids).
% Output:
	% - data: Ndays x (Nvar*Nest) Matrix.
	% - dmn: Struct with the domain information. This struct must have the next fields:
	% fcDate: Forecast dates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples:
% Iberia:
% METEOLAB=getMETEOLAB;
% dmn=readDomain([METEOLAB.home '/../GCMData/ERA40/Iberia_10/domain.cfg']);
% ctl=[METEOLAB.home '/../GCMData/ERA40/Iberia_10/era40.ctl'];
% date=datevec(datenum('01-Jan-1999'):datenum('31-Dec-1999'));
% [patterns,dmn,fcDate]=loadGCM(dmn,ctl,'dates',date,'anHour','Analysis','ds',0);
% figure,
% for i=1:15,
	% subplot(5,3,i),
	% drawStations(dmn.nod','color',nanmean(patterns(:,(i-1)*size(dmn.nod,2)+1:i*size(dmn.nod,2)))','size',0.5,'resolution','low','israster','true')
	% colorbar
% end
% Global:
% METEOLAB=getMETEOLAB;
% dmn=readDomain([METEOLAB.home '/../GCMData/ERA40/Global_25/domain.cfg']);
% ctl=[METEOLAB.home '/../GCMData/ERA40/Global_25/era40.ctl'];
% date=datevec(datenum('01-Jan-1999'):datenum('31-Dec-1999'));
% [patterns,dmn,fcDate]=loadGCM(dmn,ctl,'dates',date,'anHour','Analysis','ds',0);
% figure,
% drawStations(dmn.nod','color',nanmean(patterns)','size',1.25,'resolution','low','israster','true')
% title('Mean Sea Level Pressure (Pa)')
% MPEH5 Snowfall :
% ctl='//oceano.macc.unican.es/gmeteo/DATA/CERA/MPEH5/20C3M_r3/url.txt';
% daysExample=datesym(datenum('01-Jan-1991'):datenum('31-Dec-1991')','yyyymmdd');
% [data,dmn]=loadGCM('//oceano.macc.unican.es/gmeteo/DATA/CERA/MPEH5/20C3M_r3/domain.cfg',ctl,'dates',daysExample);
% figure,
% drawStations(dmn.nod','color',nanmean(data)','size',0.5*1.875,'resolution','low','israster','true')
% colorbar
import ucar.nc2.dt.grid.*
import ucar.nc2.dt.grid.GridDataset.*
if ~isstruct(ctl)
    if(isdir(ctl))
        path=ctl;name='';ext='';
    else
        [path,name,ext]=fileparts(ctl);
    end
	
	if isempty(name) %if filename is not given
		file='url.txt'; %assume url.txt
        if isempty(dir([path '/' file])) % if it doesn't exist
            file='era40.ctl'; % assume old era40.ctl
        end
	else
		file=[name ext];
    end
    ctl=struct('cam',[path '/'],'fil',file);
end	

if isempty(dmn)
	dmn=readDomain([ctl.cam '/domain.cfg']);
elseif ischar(dmn)
	dmn=readDomain(dmn);
elseif ~isstruct(dmn)
	error('The domain must be empty, a structure or a string');
end
if ~isfield(dmn,'step'),dmn.step='24:00';end
switch dmn.step
	case 'Y'
		fechaIni=datevec(datenum(dmn.startDate));
		anios=datevec(datenum(dmn.startDate):datenum(dmn.endDate)');
		anios=unique(anios(:,1));
		anDate=[anios repmat(fechaIni(2:end),length(anios),1)];
	case 'M'
		fechaIni=datevec(datenum(dmn.startDate));
		anDate=datevec(datenum(dmn.startDate):datenum(dmn.endDate)');
		[anDate1,I1,I2]=unique(anDate(:,1:2),'rows');
		anDate=[anDate1 repmat(fechaIni(1,3:end),size(anDate1,1),1)];
	otherwise
		anDate=datevec(datenum(dmn.startDate):datenum(stepvec(dmn.step)):datenum(dmn.endDate)');
end

% anDate=datevec(datenum(dmn.startDate):datenum(stepvec(dmn.step)):datenum(dmn.endDate)');
landMask=0;rootPath=ctl.cam;threshold=[];boundingBox=[];
ds=00;
anHour=[];
tableFileName='';
ignoremissing=0;
format='grib';
interpolator='linear';
warnings='on';
% User Data Getway authentication:
user='';password='';
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'tablefilename', tableFileName=varargin{i+1};
		case 'ignoremissing', ignoremissing=varargin{i+1};
		case 'dates', anDate=varargin{i+1};
		case 'anhour', anHour=varargin{i+1};
		case 'ds', ds=varargin{i+1};
		case 'interpolator', interpolator=varargin{i+1};
		case 'warning', warnings=varargin{i+1};
		case 'landmask', landMask=varargin{i+1};
		case 'threshold', threshold=varargin{i+1};
		case 'boundingbox', boundingBox=varargin{i+1};
		case 'path', rootPath=varargin{i+1};
        case 'user',     user=varargin{i+1};
        case 'password', password=varargin{i+1};
		otherwise
			warning(sprintf('Option ''%s'' not defined',varargin{i}))
	end
end
if ~isempty(user) && ~isempty(password)
    ucar.nc2.util.net.HTTPSession.setGlobalCredentialsProvider(ucar.nc2.util.net.HTTPBasicProvider(user,password));
end

if(iscell(anDate))
	switch dmn.step
		case 'Y'
			fechaIni=datevec(datenum(anDate{1}));
			anios=datevec(datenum(anDate{1}):datenum(anDate{end})');
			anios=unique(anios(:,1));
			anDate=[anios repmat(fechaIni(2:end),length(anios),1)];
		case 'M'
			format='yyyymm';
			anDate=datevec(datenum(anDate{1}):datenum(anDate{end})');
			[anDate1,I1,I2]=unique(anDate(:,1:2),'rows');
			anDate=[anDate1 anDate(I1,3:end)];
		otherwise
			anDate=datevec(datenum(anDate{1}):datenum(stepvec(dmn.step)):datenum(anDate{end})');
    end
elseif(isnumeric(anDate) & size(anDate,2)~=6)
    anDate=datevec(anDate(:));
end
ctlname=[ctl.cam ctl.fil];
urls=textread(ctlname,'%s','delimiter','\n');
headerlines=strmatch('#!',urls);
if ~isempty(headerlines)
	urls=strvcat(urls{headerlines});urls=urls(:,3:end);
	format=strmatch('format',urls);
	if ~isempty(format)
		sd=findstr('=',urls(format,:));
		format=deblank(urls(format,sd(1)+1:end));
	end
end

switch lower(format)
    case 'netcdf',
        [data,dmn]=getFRCfromNetCDF(ctl,dmn,'dates',anDate,'anhour',anHour,'interpolator',interpolator,'warning',warnings,'landmask',landMask,'threshold',threshold,'path',rootPath,'boundingbox',boundingBox);
		if nargout>2,fcDate=datenum([str2num(dmn.dailyList(:,1:4)) str2num(dmn.dailyList(:,5:6)) str2num(dmn.dailyList(:,7:8)) zeros(size(data,1),3)]);end
    case 'grib',
        if isnumeric(anDate) & size(anDate,2)==1,anDate=datevec(anDate);end
        if isempty(anHour),anHour=00;end
        [data,dmn,fcDate]=getFRCfromGRIB(ctl,dmn,anDate,anHour,ds,'tableFileName',tableFileName,'ignoremissing',ignoremissing);
		if isfield(dmn,'varTable')
			for v=1:size(dmn.par,1),
				ind=findVarPosition(dmn.par{v,1},dmn.par{v,3},dmn.par{v,2},dmn);
				data(:,ind)=data(:,ind)*str2num(dmn.varTable.Scale{v})+str2num(dmn.varTable.Offset{v});
				minimo=str2num(dmn.varTable.Minimum{v});
				maximo=str2num(dmn.varTable.Maximum{v});
				if ~isempty(minimo)
					data2=data(:,ind);
					data2(find(data2<minimo))=minimo;
					data(:,ind)=data2;clear data2
				end
				if ~isempty(maximo)
					data2=data(:,ind);
					data2(find(data2>maximo))=maximo;
					data(:,ind)=data2;clear data2
				end
			end
		end
    otherwise
        error(sprintf('Data format ''%s'' not defined',format))
end
