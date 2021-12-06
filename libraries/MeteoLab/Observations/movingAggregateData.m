function [newData,fechas1]=aggregateData(data,struct,block,step,varargin)
%[newData,fechas1]=aggregateData(data,STRUCT,block,step,varargin);
%
% Temporal aggretation of observations related to STRUCT.
%
% Input : 
%   data        : matrix dataset.
%	STRUCT      : is a structure given by the loadStations function (StartDate, EndDate, Block, StepDate).
%   block       : block used to aggregate the data. As 0-format of 'datestr' or as
%                 'xL', where x is a number and L is 's','m','h','D','M','Y' ('Y' or '12M' for yearly).
%                  By default '1D' (daily data).
%   step        : step to get the aggregated data (number in L block units).
%
%	varargin    : optional parameters
%       'missing'   -   Maximum ratio of missing data within each
%                       aggregation block (0.1 by default). Otherwise NaN.
%       'funct'     -   aggregation function ({'nanmean'}, 'mean', 'max', ...).
%       'funct2'    -   intra-block function (only for advanced users).
% Example: 
% net=struct('StartDate','01-Jan-1950','EndDate','31-Dec-2003','Block','1D','StepDate',1);
% [newData,fechas1]=aggregateData(data,net,'1M',1,'missing',1,'funct','nanmean');


periodo=block;

funct='nanmean';
funct2=[];
missing=0.1;
dates = [];

for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'funct', funct = varargin{i+1};
        case 'funct2', funct2 = varargin{i+1};
        case 'missing', missing = varargin{i+1};
    end
end

if isempty(funct2)
    funct2=funct;
end

Ini=datenum(struct.StartDate);
Fin=datenum(struct.EndDate);
try
    paso=datenum(struct.Block);
%     fechas=datevec(dates(struct));
    fechas=datevec([Ini:paso:Fin]);
    %     fechas=fechas(:,1:4);
    if paso==1
        columna=3;
    else
        columna=4;
    end
catch
    paso=struct.StepDate;
    bloque=struct.Block;
    escala=bloque(end);
%     bloque=str2num(bloque(1:end-1));
    bloque=str2double(bloque(1:end-1));
    switch(escala)
        case('s')
            paso=datenum(['00:00:' num2str(bloque)]);
            fechas=datevec(Ini:paso:Fin);
            columna=6;
        case('m')
            paso=datenum(['00:' num2str(bloque)]);
            fechas=datevec(Ini:paso:Fin);
            %             fechas=fechas(:,1:5);
            columna=5;
        case('h')
            paso=datenum([num2str(bloque) ':00']);
            fechas=datevec(Ini:paso:Fin);
            %             fechas=fechas(:,1:4);
            columna=4;
        case('D')
            fechas=datevec(Ini:bloque:Fin);
            %             fechas=fechas(:,1:3);
            columna=3;
        case('M')
			[yini,mini,dini,hini,minini,sini]=datevec(Ini);
			[yfin,mfin,dfin,hfin,minfin,sfin]=datevec(Fin);
            % mini=month(Ini);mfin=month(Fin);dini=day(Ini);dfin=day(Fin);
            % yini=year(Ini);yfin=year(Fin);
            %             fechas=zeros(round(13-mini+12*(yfin-yini-1)+mfin)/bloque,2);
            fechas=zeros(round(13-mini+12*(yfin-yini-1)+mfin)/bloque,6);
            i=1;
            while i<=size(fechas,1)
                fechas(i,:)=[yini mini dini 1 0 0];
                mini=mini+bloque;
                if mini>12
                    yini=yini+1;mini=mini-12;
                end
                i=i+1;
            end
            columna=2;
        case('Y');
			[yini,mini,dini,hini,minini,sini]=datevec(Ini);
			[yfin,mfin,dfin,hfin,minfin,sfin]=datevec(Fin);
            % yini=year(Ini);yfin=year(Fin);
            %             fechas=[yini:bloque:yfin]';
            aux=[yini:bloque:yfin]';
            fechas=zeros(size(aux,1),6);
            fechas(:,1)=aux;
            columna=1;
    end
end
try
    tiempo=datenum(periodo);
    if mod(tiempo,datenum('24:00'))==0
        n=3;bloque=tiempo;
    elseif mod(tiempo,datenum('01:00'))==0
        n=4;bloque=tiempo/datenum('01:00');
    elseif mod(tiempo,datenum('00:01'))==0
        n=5;bloque=tiempo/datenum('00:01');
    elseif mod(tiempo,datenum('00:00:01'))==0
        n=6;bloque=tiempo/datenum('00:00:01');
    end
catch
%     bloque=str2num(periodo(1:end-1));
    bloque=str2double(periodo(1:end-1));
    switch(periodo(end))
        case('s')
            n=6;
        case('m')
            n=5;
        case('h')
            n=4;
        case('D')
            n=3;
        case('M')
            n=2;
        case('Y')
            n=1;
    end
end

if n>columna
    error('The block format is not possible with the available data.')
elseif n==columna
    if bloque>1 || step>1
        indice=0;i=0;
        while ((indice+bloque<=size(data,1)))
            i=i+1;
            validas=find(sum(isnan(data(indice+1:indice+bloque,:)),1)/bloque<=missing);
            newData(i,validas)=mifeval(funct2,data(indice+1:indice+bloque,validas));
            dates(i,:)=fechas(indice+1,:);
            indice=indice+step;
        end
        if indice<size(data,1)
            validas=find(sum(isnan(data(indice+1:end,:)),1)/length(data(indice+1:end,1))<=missing);
            newData(i+1,validas)=mifeval(funct2,data(indice+1:end,validas));
            dates(i+1,:)=fechas(indice+1,:);
        end
        newData=newData(1:i,:);
        dates=dates(1:i,:);
    else
        newData=data;
        dates=fechas;
    end
else
    ind=find(fechas(2:end,n)-fechas(1:end-1,n)~=0);
    if ~isempty(ind)
        newData=NaN+zeros(length(ind)+1,size(data,2));
        validas=find(sum(isnan(data(1:ind(1),:)),1)/ind(1)<=missing);
        newData(1,validas)=mifeval(funct,data(1:ind(1),validas));
        for i=1:length(ind)-1
            indice=[ind(i)+1:ind(i+1)];
            validas=find(sum(isnan(data(indice,:)),1)/length(indice)<=missing);
            newData(i+1,validas)=mifeval(funct,data(indice,validas));
        end
        validas=find(sum(isnan(data(ind(end)+1:end,:)),1)/length([ind(end)+1:size(data,1)])<=missing);
        newData(end,validas)=mifeval(funct,data(ind(end)+1:end,validas));
        fechas=[fechas(1,:);fechas(ind(1:end)+1,:)];
    elseif length(unique(fechas(:,n)))==1
        newData=NaN*zeros(1,size(data,2));
        validas=find(sum(isnan(data),1)/size(data,1)<=missing);
        newData(validas)=mifeval(funct,data(:,validas));
        fechas=fechas(1,:);
    else
        newData=[];
        fechas=[];
    end
    data=newData;
    if bloque>1 || step>1
        indice=0;i=0;
        while ((indice+bloque<=size(data,1)))
            i=i+1;
            validas=find(sum(isnan(data(indice+1:indice+bloque,:)),1)/bloque<=missing);
            newData(i,validas)=mifeval(funct2,data(indice+1:indice+bloque,validas));
            dates(i,:)=fechas(indice+1,:);
            indice=indice+step;
        end
        newData=newData(1:i,:);
        dates=dates(1:i,:);
    else
        newData=data;
        dates=fechas;
    end
end
fechas1=datenum([dates zeros(size(dates,1),6-size(dates,2))]);

function y=mifeval(fun,x)

if any(strcmp(fun,{'min','max'}))
    y=feval(fun,x,[],1);
else                
    y=feval(fun,x);
end
