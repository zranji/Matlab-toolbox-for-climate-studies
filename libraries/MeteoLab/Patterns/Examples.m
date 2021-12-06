%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading fields from EOF (compressed data).
dmn=readDomain('Nao'); 		   %'Nao' is defined in MeteoLab\Patterns\Zones.txt
drawAreaPattern(dmn);
[dmn.startDate; dmn.endDate]   %Period of the stored data
dates={'01-Aug-1992','09-Aug-1992'};
[field,info]=getFieldfromEOF(dmn,'npc',1,'dates',dates); %Reconstructing data using the first EOF
drawGrid(field(1:end,:),dmn)
[field,info]=getFieldfromEOF(dmn,'npc',50,'dates',dates);
drawGrid(field(1:end,:),dmn)

% Generating two random fields from two random PC vectors
[field,info]=getFieldfromEOF(dmn,'pcVector',10*randn([2 10]));

dmn=readDomain('Iberia');  		%Obtaining a particular parameter
dates={'01-Jan-2000','31-Dec-2000'};
[field,info]=getFieldfromEOF(dmn,'var','Z','time',12,'level',1000,'dates',dates);
figure; plot(field(:,1));title('daily Z in a grid point for 2000')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special MeteoLab functions to read GRIB files
% Reading reanalisys fields in GRIB format: getFieldfromGRIB

dmn=readDomain('Iberia');
ctl.fil='era40.ctl';
ctl.cam=dmn.src;
dates={'01-Dec-1999','31-Dec-1999'};
[patterns]=getFieldfromGRIB(ctl,dmn,'dates',dates);
% Drawing temperature (130) at 12 UTC (12) at 1000 mb
data=patterns(:,findVarPosition('T',12,1000,dmn));
drawGrid(data(1,:),dmn)
%Choosing colourbar limits and titles
drawGrid(data(1:4,:),dmn,'clim',[283 288],'titles',{'01-Dec-1999' '02-Dec-1999' '03-Dec-1999' '04-Dec-1999'})


dmn=readDomain('NorthernBasin');
ctl.fil='era40.ctl';
ctl.cam=dmn.src;
dates={'01-Dec-1999','31-Dec-1999'};
[patterns]=getFieldfromGRIB(ctl,dmn,'dates',dates);
drawGrid(patterns(1,findVarPosition('T',12,1000,dmn)),dmn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading forecasts in GRIB format: getFRCfromGRIB

% Reading forecasts fields in GRIB format. getFRCfromGRIB
% units: mm (x1000 to convert from original units)
dmn=readDomain('IberiaPrecip');
ctl.fil='IberiaPrecip.ctl';
ctl.cam=dmn.src;
%date=datevec(datenum(dmn.startDate):datenum(dmn.endDate));
date=datevec(datenum('01-Jan-1999'):datenum('31-Dec-1999'));
[patterns,fcDate]=getFRCfromGRIB(ctl,dmn,date,00,00);

%Adding large scale and convective precip and drawing the fields
precip=1000*(patterns(:,findVarPosition(LSP,30,0,dmn))+patterns(:,findVarPosition(CP,30,0,dmn)));
precip=sum(precip,1); %Accumulated precipitation
drawGrid(precip,dmn);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reading fields from general GRIB files with readmessage and read_GRIB
dmn=readDomain('IberiaPrecip');
fichero='era40Water30_06_1999.grb';
[A,info]=readmessage([dmn.src 'grb/' fichero],0);
info.GDS.LatLon

grib_struct1=read_grib([dmn.src 'grb/' fichero],-1);
grib_struct1






