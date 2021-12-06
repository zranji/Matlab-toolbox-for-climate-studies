function [VC,dmn,fcDate]=getFRCfromGRIB(ctl,dmn,anDate,anHour,ds,varargin)
% This function load the patterns of Reanalysis (ERA40, NCEP, etc).
% Input:
	% - ctl: Struct with the next fields
		% - cam: path of the data.
		% - fil: This argument can be the name of the grb-file or a ctl-file with the name of the grb-file.
	% - dmn: Struct with the domain information. This struct must have the next fields:
		% - lon= 1*nlon matrix with the longitudes.
		% - lat= 1*nlat matrix with the latitudes.
		% - tim= times
		% - startDate= startDate
		% - endDate= endDate
		% - par=Z,1000;Z,925;Z,850;Z,700;Z,500;Z,300;
		% - par=T,1000;T,925;T,850;T,700;T,500;T,300;
		% - format: this is the data set format {grib or netcdf}.
		% - anDate: This argument define the dates loaded in datevec format.
		% - ds: 
		% - anHour: analysis hour.
		% - tableFileName: 
		% - ignoremissing:
% Output:
	% - VC: Ndays x (Nvar*Nest) Matrix.
	% - dmn: Struct with the domain information. This struct must have the next fields:
	% - fcDate: Forecast dates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples:
% Reanalysis Patterns:
% METEOLAB=getMETEOLAB;
% dmn=readDomain([METEOLAB.home '/../PatternsData/IberiaPatterns/IberiaPrecip/domain.cfg']);
% ctl.fil='IberiaPrecip.ctl';
% ctl.cam=[METEOLAB.home '/../NWPData/ERA40/IberiaPrecip_10/'];
% date=datevec(datenum('01-Jan-1999'):datenum('31-Dec-1999'));
% [patterns,dmn1,fcDate]=getFRCfromGRIB(ctl,dmn,date,00,00);
% [patterns1,dmn,fcDate1]=loadGCM(ctl,dmn,'dates',date,'anHour',00,'ds',00);
% figure,
% subplot(1,3,1), pcolor(patterns-patterns1),shading flat,colorbar
% subplot(1,3,2), plot(nansum(patterns-patterns1))
% subplot(1,3,3), plot(nansum(patterns-patterns1,2))

persistent IDXFILE;

tableFileName='';
ignoremissing=0;
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'tablefilename', tableFileName= varargin{i+1};
        case 'ignoremissing', ignoremissing= varargin{i+1};
        otherwise
            warning(sprintf('Option ''%s'' not defined',varargin{i}))
    end
end

if(~isstruct(ctl))
    if(ischar(ctl))
        ctl=cellstr(ctl);
    end
    if(~iscell(ctl))
        error('ctl must be a struct or cell with the relation of files to be processed');
    end
    ctlfil=tempname;
    fid=fopen(ctlfil,'wb');
    for i=1:length(ctl)
        fprintf(fid,'%s\n',ctl{i});
    end
    fclose(fid);
    clear ctl;
    ctl.cam='';
    ctl.fil=ctlfil;
end

ctlname=[ctl.cam ctl.fil];
fid=fopen(ctlname,'r');
k=1;
while ~feof(fid)
    linea=fgetl(fid);
    if linea(1)=='%'
        IdxFormat=linea;
        linea=fgetl(fid);
    else
        IdxFormat='%04d%02d%02d%02d%04d_%03d%03d%04d_%04d%010d';
    end
    name{k}=[ctl.cam linea];
    k=k+1;
end
fclose(fid);
iIdxFormat=find(IdxFormat=='_');
if length(iIdxFormat)<2
    error(sprintf('IdxFormat error: %s',IdxFormat));
end
IdxFormatTime=IdxFormat(1:(iIdxFormat(1)-1));
IdxFormatField=IdxFormat((iIdxFormat(1)+1):(iIdxFormat(2)-1));

idxname=[ctlname '.idx'];

idxS=dir(idxname);
ctlS=dir(ctlname);
if (isempty(idxS) | idxS.datenum<ctlS.datenum)
    buildIndex('make,sort,write',ctl.cam,ctl.fil,[ctl.fil '.idx']);   
else
    if ~strcmp(IDXFILE,idxname)
        %disp(idxname);
        buildIndex('read',ctl.cam,ctl.fil,[ctl.fil '.idx']);
        IDXFILE=idxname;
    end
end

if(isempty(tableFileName))
    tableFileName=[ctl.cam 'Table.txt'];
end
dmn=parseDomain(dmn,tableFileName,1);

xi=[];yi=[];

nPAR=size(dmn.par,1);
nn=size(dmn.nod,2);

DATETIMEAN=0;
if(isempty(anHour) || (ischar(anHour) && strcmpi(anHour,'analysis')))
    DATETIMEAN=1;   
end

% if(~DATETIMEAN)
%     if(isempty(anHour) & size(anDate,2)<=3)
%         warning('Assuming 00 UTC analysis time');
%         anDate(:,4:6)=0;
%     else
%         anDate(:,4:6)=0;
%         anDate(:,4)=anHour;
%     end
% end

na=length(ds);
nd=size(anDate,1);
NoMasDias=0;

alcDate=zeros(1,size(anDate,2),length(ds));
alcDate(1,3,:)=ds;
fcDate=repmat(anDate,[1,1,size(alcDate,3)])+repmat(alcDate,[size(anDate,1),1,1]);
fcDate=permute(fcDate,[2 1 3]);
fcDate=reshape(fcDate,[size(anDate,2) size(anDate,1)*size(alcDate,3)]);
fcDate=permute(fcDate,[2 1]);
if(DATETIMEAN)
    fcDate=datevec(datenum(fcDate(:,1),fcDate(:,2),fcDate(:,3),fcDate(:,4),fcDate(:,5),fcDate(:,6)));
else
    fcDate=datevec(datenum(fcDate(:,1),fcDate(:,2),fcDate(:,3),fcDate(:,4),fcDate(:,5),fcDate(:,6)));
    fcDate=fcDate(:,1:size(anDate,2),:);
end
fcDate=ipermute(fcDate,[2,1]);
fcDate=reshape(fcDate,[size(anDate,2) size(anDate,1) size(alcDate,3)]);
fcDate=ipermute(fcDate,[2 1 3]);

FF=zeros([nd*na*nPAR,2])+NaN;
FI=zeros([nd*na*nPAR,3])+NaN;

NN=1;

for iPAR=(1:nPAR);
    %messpl=sprintf('%03d%03d%04d',dmn.par{iPAR,1},0,dmn.par{iPAR,2});
    messpl=sprintf(IdxFormatField,dmn.par{iPAR,1},0,dmn.par{iPAR,2});
    for id=(1:nd)
        for ia=(1:na)
            if(DATETIMEAN)
                ANDATE=anDate(id,:)+[0 0 0 dmn.par{iPAR,3} 0 0];
                ANDATE=datevec(datenum(ANDATE(1,1),ANDATE(1,2),ANDATE(1,3),ANDATE(1,4),ANDATE(1,5),ANDATE(1,6)));
                T=ANDATE(1,4);
                P1=ds*24+dmn.par{iPAR,4};
            else
                T=anDate(id,4);
                P1=dmn.par{iPAR,3}+ds(ia)*24+dmn.par{iPAR,4};
                ANDATE=anDate(id,:);
            end
            
            %mess=sprintf(['%04d%02d%02d%02d%04d_%s'],ANDATE(1,1),ANDATE(1,2),ANDATE(1,3),T,P1,messpl);
            mess=sprintf([IdxFormatTime '_%s'],ANDATE(1,1),ANDATE(1,2),ANDATE(1,3),T,P1,messpl);
            F=buildIndex('find',mess,'1','');
            if F(1)
                FF(NN,1:2)=F;
                FI(NN,:)=[iPAR,id,ia];
                NN=NN+1;
            else
                error(sprintf('No se ha encontrado un campo: %s',mess));
                NoMasDias=1;
                break
            end
        end
        if NoMasDias,break,end
    end
    if NoMasDias,break,end
end

VC=zeros([nd,nPAR*nn,na])+NaN;

DATA=[];

[FF,i]=sortrows(FF);
FI=FI(i,:);
NODATA=0;
ff=[-1,-1];
NNN=0;

for k=1:size(FF,1)
    if NODATA
        if(~all(ff==FF(k,:)))
            [A,info]=readmessage2(name{FF(k,1)},FF(k,2));
        end
    else    
        if isempty(DATA)
            if(~all(ff==FF(k,:)))
                [A,info]=readmessage2(name{FF(k,1)},FF(k,2));
            end   
            %We are interpolationg to coordinates specified in nod
            if(size(dmn.nod,1)==2)
                xi=dmn.nod(1,:);    
                yi=dmn.nod(2,:);    
            else
                [xi,yi]=meshgrid(dmn.lon,dmn.lat);
                xi=xi';yi=yi';
                xi=xi(dmn.nod);
                yi=yi(dmn.nod);
            end
            scanmode=sscanf(dec2bin(info.GDS.LatLon.ScanMode,8),'%1d');
            dx=(1-2*scanmode(1))*info.GDS.LatLon.Di;
            dy=(-1+2*scanmode(2))*info.GDS.LatLon.Dj;
            
            Lon1=info.GDS.LatLon.Lon1;
            Lon2=info.GDS.LatLon.Lon2;
            Lat1=info.GDS.LatLon.Lat1;
            Lat2=info.GDS.LatLon.Lat2;
            
            if (Lon1>Lon2 & dx>0)
                Lon2=Lon2+360000;
            end
            
            %x=Lon1:dx:Lon2;
            %y=Lat1:dy:Lat2;
            
            x=linspace(Lon1,Lon2,info.GDS.LatLon.Ni);
            y=linspace(Lat1,Lat2,info.GDS.LatLon.Nj);
            
            x=x/1000;y=y/1000;
            i=find(x>180);
            x(i)=x(i)-360;

            [X,Y]=meshgrid(x,y);   
            if bitget(scanmode,3)
                X=X';Y=Y';
            end
            DATA=1;
            [XX,ind]=sort(X,2);
            ind=ind(1,:);
            YY=Y(:,ind);
            AA=A(ind,:)';
            
            [INTP.nrows,INTP.ncols,INTP.s,INTP.t,INTP.ndx,INTP.sout,INTP.tout] = linearInterpInit(XX,YY,AA,xi,yi);
            zi=linearInterp(AA,INTP.nrows,INTP.ncols,INTP.s,INTP.t,INTP.ndx,INTP.sout,INTP.tout);

        else
            if(~all(ff==FF(k,:)))
                A=readmessage2(name{FF(k,1)},FF(k,2));
                if ~isempty(A),AA=A(ind,:)';zi=linearInterp(AA,INTP.nrows,INTP.ncols,INTP.s,INTP.t,INTP.ndx,INTP.sout,INTP.tout);end
            end
        end
        
        VC(FI(k,2),(1:nn)+nn*(FI(k,1)-1),FI(k,3))=zi;
    end %if NODATA
    ff=FF(k,:);
end %for k






function [nrows,ncols,s,t,ndx,sout,tout] = linearInterpInit(arg1,arg2,arg3,arg4,arg5)
[nrows,ncols] = size(arg1);
mx = prod(size(arg1)); my = prod(size(arg2));
if any([mx my] ~= [ncols nrows]) & ...
        ~isequal(size(arg1),size(arg2),size(arg3))
    error('The lengths of the X and Y vectors must match Z.');
end
if any([nrows ncols]<[2 2]), error('Z must be at least 2-by-2.'); end
s = 1 + (arg4-arg1(1))/(arg1(mx)-arg1(1))*(ncols-1);
t = 1 + (arg5-arg2(1))/(arg2(my)-arg2(1))*(nrows-1);

if ~isequal(size(s),size(t)),
    error('XI and YI must be the same size.');
end

% Check for out of range values of s and set to 1
sout = find((s<1)|(s>ncols));
if length(sout)>0, s(sout) = ones(size(sout)); end

% Check for out of range values of t and set to 1
tout = find((t<1)|(t>nrows));
if length(tout)>0, t(tout) = ones(size(tout)); end

% Matrix element indexing
ndx = floor(t)+floor(s-1)*nrows;

% Compute intepolation parameters, check for boundary value.
if isempty(s), d = s; else d = find(s==ncols); end
s(:) = (s - floor(s));
if length(d)>0, s(d) = s(d)+1; ndx(d) = ndx(d)-nrows; end

% Compute intepolation parameters, check for boundary value.
if isempty(t), d = t; else d = find(t==nrows); end
t(:) = (t - floor(t));
if length(d)>0, t(d) = t(d)+1; ndx(d) = ndx(d)-1; end
d = [];

function F=linearInterp(arg1,nrows,ncols,s,t,ndx,sout,tout)

% Now interpolate, reuse u and v to save memory.
F =  ( arg1(ndx).*(1-t) + arg1(ndx+1).*t ).*(1-s) + ...
    ( arg1(ndx+nrows).*(1-t) + arg1(ndx+(nrows+1)).*t ).*s;

% Now set out of range values to NaN.
if length(sout)>0, F(sout) = NaN; end
if length(tout)>0, F(tout) = NaN; end
