function indicator=extremesIndicator(period,varargin);

% This function estimates the extremes index defined by the ETCCDMI. 
% The input are:
% 	- period: vector of dates (datenums)
% 	- varagin: optional inputs.
% 		- variables: {'Tx';'Tn';'Tg';'Pr';'Ps';'Nv';'Ws';'Wd'}, ndata x Nest dimensions matrix whit the daily data. Each row represent an observed day and
%		each column an station or grid point. The data units must be: �C for temperature (Tx,Tn,Tg), mm for precipitation (Pr), hPa for pressure (Ps), cm for snowdepth(Nv), m/s for windspeed (Ws) and degrees between (0�-360�) for wind direction (Wd).
% 		- aggregation: is the agrupation criteria, for annual write Y, for monthly M and for seasonally
%		S (S1,S2,S3,S4 correspond to DJF,MAM,JJA and SON).
% 		- missing: maximun percentage of missing data (i.e. NaN) per group.
%		- threshold: structure with the same order than the namelist with the threshold of the indicator.
%			When the threshold is not necessary it must be empty ([]). Default: threshold=struct('gd4',[],'gsl',[],...)
% 		- names: cell with the index names. The namelist is:
%%%%%%%%%%% Indicators defined in: http://eca.knmi.nl/indicesextremes/indicesdictionary.php %%%%%%%%%%%
% Note: The symbol * indicates "calculated for a 5 day window centred on each calendar day in the 1961-1990 period".
% gd4: Growing degree days (�C) - Sum of Tg>4�C.
% gsl: Growing season length (days) - Number of days between the first occurrence of at least
%						   six consecutive days with T>5�C and the first occurrence
%						   after 1st July (NH) or 1st January (SH) of at least six 
%						   consecutive days with T<5�C.
% cfd: Maximum number of consecutive frost days (Tn<0�C) (days).
% fd: Number of frost days (Tn<0�C) (days).
% hd17: Heating degree days (�C) - Sum of 17�C-Tg.
% id: Number of ice days (Tx<0�C) (days).
% csdi: Cold-spell days (days) - Number of days per period where, in intervals of at least 6 
% 								 consecutive days Tn<10th percentile* of min temp.
% tg10p: Cool days (days) - Days with Tg<10th percentile* of daily mean temp.
% tn10p: Cool nights (days) - Days with Tn<10th percentile* of daily min temp.
% tx10p: Cool day-times (days) - Days with Tx<10th percentile* of daily max temp.
% txn: Minimun value of daily maximum temperature (�C).
% tnn: Minimun value of daily minimum temperature (�C).
% cdd: Consecutive dry days (days) - Largest number of consecutive days with Pr<1mm.
% su: Summer days (days) - Number of days with Tx>25�C.
% tr: Tropical nights (days) - Number of days with Tn>20�C.
% wsdi: Warm-spell days (days) - Number of days per period where, in intervals of at least 6 
% 								 consecutive days Tx>90th percentile* of max temp.
% tg90p: Warm days (days) - Days with Tg>90th percentile* of daily mean temp.
% tn90p: Warm nights (days) - Days with Tn>90th percentile* of daily min temp.
% tx90p: Warm day-times (days) - Days with Tx>90th percentile* of daily max temp.
% txx: Maximun value of daily maximum temperature (�C).
% tnx: Maximun value of daily minimum temperature (�C).
% pp: Mean of daily surface air pressure (hPa).
% rr: Precipitation sum (mm).
% rr1: Wet days (days) - Number of days with Pr>=1mm.
% sdii: Simple daily intensity index (mm/wet day).
% cwd: Consecutive wet days (days) - Largest number of consecutive days with Pr>=1mm.
% r10: Number of heavy precipitation days (days) - Number of days with Pr>=10mm.
% r20: Number of very heavy precipitation Days (days) - Number of days with Pr>=20mm.
% rx1day: Max 1-day precipitation amount (mm) - Maximun daily value.
% rx5day: Max 5-day precipitation amount (mm) - Maximun 5-days value.
% r75p: Moderate wet days (days) - Days with Pr>75th percentile of precipitation at wet days in the 1961-1990 period.
% r75ptot: Precipitation fraction due to moderate wet days (%).
% r95p: Very wet days (days) - Days with Pr>95th percentile of precipitation at wet days in the 1961-1990 period.
% r95ptot: Precipitation fraction due to very wet days (%).
% r99p: Extremely wet days (days) - Days with Pr>99th percentile of precipitation at wet days in the 1961-1990 period.
% r99ptot: Precipitation fraction due to extremely wet days (%).
% sd: Mean of daily snow depth (cm).
% sd1: Snow days (days) - Number of days with Nv>=1cm.
% sd5: Snow days (days) - Number of days with Nv>=5cm.
% sd50: Snow days (days) - Number of days with Nv>=50cm.
% tg: Mean of daily mean temperature (�C).
% tn: Mean of daily minimum temperature (�C).
% tx: Mean of daily maximum temperature (�C).
% dtr: Mean of diurnal temperature range (�C).
% etr: Intra-period extreme temperature range (�C).
% vdtr: Mean absolute day-to-day difference in dtr (�C).
%%%%%%%%%%% Other Indicators %%%%%%%%%%%
% rx3day: Max 3-day precipitation amount (mm) - Maximun 3-days value.
% hw: Hot waves (days) - Number of Days with Tx>35�C.
% Example:
% indicator=extremesIndicator(period,'Tx',data1,'Tn',data2,'aggregation','Y','names',{'cfd';'fd';'etr'});

aggregation='Y';
nombres=[];
missing=1;
threshold=[];filter='no';
Tx=[];Tn=[];Tg=[];Pr=[];Ps=[];Nv=[];Ws=[];Wd=[];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'names', nombres=varargin{i+1};
        case 'aggregation', aggregation=varargin{i+1};
        case 'missing', missing=varargin{i+1};
        case 'threshold', threshold=varargin{i+1};
        case 'filter', filter=varargin{i+1};
        case 'tx', Tx=varargin{i+1};
        case 'tn', Tn=varargin{i+1};
        case 'tg', Tg=varargin{i+1};
        case 'pr', Pr=varargin{i+1};
        case 'ps', Ps=varargin{i+1};
        case 'nv', Nv=varargin{i+1};
        case 'ws', Ws=varargin{i+1};
        case 'wd', Wd=varargin{i+1};
        case 'rh', Rh=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end

Nindex=length(nombres);
if Nindex<1
	error('At least an indicator name is necessary')
end
% [Nagg,datesAgg1]=aggregateData(period(:),period,aggregation);Nagg=length(Nagg);
datesAgg=datevec(period(:));
switch aggregation
	case 'Y'
		[a1,a2,a3]=unique(datesAgg(:,1),'rows');
		datesAgg=a3;Nagg=length(a1);clear a1 a2 a3
	case 'S'
		estaciones=[12 1 2;3 4 5;6 7 8;9 10 11];
        aux=find(datesAgg(:,2)<=2);datesAgg(aux,1)=datesAgg(aux,1)-1;datesAgg(aux,2)=1;
        aux=find(datesAgg(:,2)==12);datesAgg(aux,2)=1;
		for i=2:4,datesAgg(find(ismember(datesAgg(:,2),estaciones(i,:))),2)=i;end
		[a1,a2,a3]=unique(datesAgg(:,1:2),'rows');
		datesAgg=a3;Nagg=length(a1);clear a1 a2 a3
	case 'M'
		[a1,a2,a3]=unique(datesAgg(:,1:2),'rows');
		datesAgg=a3;Nagg=length(a1);clear a1 a2 a3
end
for i=1:Nindex
	indicator(i).Name=nombres{i};
	switch lower(nombres{i})
		case 'gd4'
			[ndata,Nest]=size(Tg);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=Tg(:,k);
				aux(find(Tg(:,k)<=4))=NaN;aux=aux-4;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'gsl'
			[ndata,Nest]=size(Tg);
			fechas=datevec(period);
			[anios,I,J]=unique(fechas(:,1),'last');I=[0;I];
			indicator(i).StartDate=repmat(NaN,length(anios),Nest);
			indicator(i).EndDate=repmat(NaN,length(anios),Nest);
			indicator(i).Index=repmat(NaN,length(anios),Nest);
			for k=1:length(anios)
				a1=0;
				july1=datenum(['01-Jul-' num2str(anios(k))]);
				while I(k)+a1+6<=I(k+1) & isnan(sum(indicator(i).Index(k,:),2))
					aux1=nansum(double(Tg(I(k)+a1+1:I(k)+a1+6,:)>5));
					ind=find(aux1==6);
					if ~isempty(ind)
						indicator(i).StartDate(k,ind)=nanmin([indicator(i).StartDate(k,ind);ones(1,length(ind))*(datenum(period(1))+I(k)+a1+6)],1);
					end
					aux1=nansum(double(Tg(I(k)+a1+1:I(k)+a1+6,:)<5));
					ind=find(aux1==6);
					if ~isempty(ind) & july1<(datenum(period(1))+I(k)+a1)
						indicator(i).EndDate(k,ind)=nanmin([indicator(i).EndDate(k,ind);ones(1,length(ind))*(datenum(period(1))+I(k)+a1+6)],1);
					end
					indicator(i).Index(k,:)=indicator(i).EndDate(k,:)-indicator(i).StartDate(k,:);
					a1=a1+1;
				end
			end
		case 'cfd'
			[ndata,Nest]=size(Tn);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Tn(:,k)) & Tn(:,k)<0);
				aux(ind)=1;
				for j=1:Nagg
					ind=find(datesAgg==j)';
					indicator(i).Index(j,k)=0;
					maximo=0;
					for l=ind
						if aux(l)==1
							indicator(i).Index(j,k)=indicator(i).Index(j,k)+1;
						else
							if indicator(i).Index(j,k)>maximo
								maximo=indicator(i).Index(j,k);
							else
								indicator(i).Index(j,k)=0;
							end
						end
					end
					indicator(i).Index(j,k)=max(maximo,indicator(i).Index(j,k));
				end
			end
		case 'fd'
			[ndata,Nest]=size(Tn);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=NaN*zeros(ndata,1);
				ind=find(~isnan(Tn(:,k)) & Tn(:,k)<0);aux(ind)=1;
				ind=find(~isnan(Tn(:,k)) & Tn(:,k)>=0);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'hd17'
			indicator(i).Index=aggregateData(17-Tg,period,aggregation,'aggfun','nansum','missing',missing);
		case 'id'
			[ndata,Nest]=size(Tx);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=NaN*zeros(ndata,1);
				ind=find(~isnan(Tx(:,k)) & Tx(:,k)<0);aux(ind)=1;
				ind=find(~isnan(Tx(:,k)) & Tx(:,k)>=0);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'csdi'
			[ndata,Nest]=size(Tn);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,1);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tn(ind,k)) & Tn(ind,k)<threshold.csdi(j,k));
					aux(ind(ind1))=1;
				end
				for j=1:Nagg
					ind=find(datesAgg==j)';
					indicator(i).Index(j,k)=0;ndays=0;
					for l=ind
						if aux(l)==1
							ndays=ndays+1;
						else
							if ndays>5
								indicator(i).Index(j,k)=indicator(i).Index(j,k)+1;
							end
							ndays=0;
						end
					end
				end
			end
		case 'tg10p'
			[ndata,Nest]=size(Tg);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,1);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tg(ind,k)) & Tg(ind,k)<threshold.tg10p(j,k));
					aux(ind(ind1))=1;
				end
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'tn10p'
			[ndata,Nest]=size(Tn);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,1);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tn(ind,k)) & Tn(ind,k)<threshold.tn10p(j,k));
					aux(ind(ind1))=1;
				end
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'tx10p'
			[ndata,Nest]=size(Tx);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,1);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tx(ind,k)) & Tx(ind,k)<threshold.tx10p(j,k));
					aux(ind(ind1))=1;
				end
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'txn'
			indicator(i).Index=aggregateData(Tx,period,aggregation,'aggfun','nanmin','missing',missing);
		case 'tnn'
			indicator(i).Index=aggregateData(Tn,period,aggregation,'aggfun','nanmin','missing',missing);
		case 'cdd'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'cdd') || isempty(threshold.cdd)
				threshold.cdd=ones(Nest,1);
			end
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<threshold.cdd(k));
				aux(ind)=1;
				for j=1:Nagg
					ind=find(datesAgg==j)';
					indicator(i).Index(j,k)=0;
					maximo=0;
					for l=ind
						if aux(l)==1
							indicator(i).Index(j,k)=indicator(i).Index(j,k)+1;
						else
							if indicator(i).Index(j,k)>maximo
								maximo=indicator(i).Index(j,k);
							else
								indicator(i).Index(j,k)=0;
							end
						end
					end
					indicator(i).Index(j,k)=max(maximo,indicator(i).Index(j,k));
				end
			end
		case 'spi6'
		case 'spi3'
		case 'su'
			[ndata,Nest]=size(Tx);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=NaN*zeros(ndata,1);
				ind=find(~isnan(Tx(:,k)) & Tx(:,k)>25);aux(ind)=1;
				ind=find(~isnan(Tx(:,k)) & Tx(:,k)<=25);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'tr'
			[ndata,Nest]=size(Tn);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=NaN*zeros(ndata,1);
				ind=find(~isnan(Tn(:,k)) & Tn(:,k)>20);aux(ind)=1;
				ind=find(~isnan(Tn(:,k)) & Tn(:,k)<=20);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'wsdi'
			[ndata,Nest]=size(Tx);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,1);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tx(ind,k)) & Tx(ind,k)>threshold.wsdi(j,k));
					aux(ind(ind1))=1;
				end
				for j=1:Nagg
					ind=find(datesAgg==j)';
					indicator(i).Index(j,k)=0;ndays=0;
					for l=ind
						if aux(l)==1
							ndays=ndays+1;
						else
							if ndays>5
								indicator(i).Index(j,k)=indicator(i).Index(j,k)+1;
							end
							ndays=0;
						end
					end
				end
			end
		case 'tg90p'
			[ndata,Nest]=size(Tg);
			indicator(i).Index=zeros(Nagg,Nest)*NaN;
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,1);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tg(ind,k)) & Tg(ind,k)>threshold.tg90p(j,k));
					aux(ind(ind1))=1;
				end
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'tn90p'
			[ndata,Nest]=size(Tn);
			indicator(i).Index=zeros(Nagg,Nest)*NaN;
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,1);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tn(ind,k)) & Tn(ind,k)>threshold.tn90p(j,k));
					aux(ind(ind1))=1;
				end
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'tx90p'
			[ndata,Nest]=size(Tx);
			indicator(i).Index=zeros(Nagg,Nest)*NaN;
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,1);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tx(ind,k)) & Tx(ind,k)>threshold.tx90p(j,k));
					aux(ind(ind1))=1;
				end
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'txx'
			indicator(i).Index=aggregateData(Tx,period,aggregation,'aggfun','nanmax','missing',missing);
		case 'tnx'
			indicator(i).Index=aggregateData(Tn,period,aggregation,'aggfun','nanmax','missing',missing);
		case 'pp'
			indicator(i).Index=aggregateData(Ps,period,aggregation,'aggfun','nanmean','missing',missing);
		case {'rr','prcptot'}
			indicator(i).Index=aggregateData(Pr,period,aggregation,'aggfun','nansum','missing',missing);
		case 'rr1'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			indicator(i).Index=zeros(Nagg,Nest)*NaN;
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=threshold.rr1(k));aux(ind)=1;
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<threshold.rr1(k));aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'sdii'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'sdii') || isempty(threshold.sdii)
				threshold.sdii=ones(Nest,1);
			end
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=threshold.sdii(k));
				aux(ind)=Pr(ind,k);
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nanmean','missing',1);
			end
		case 'cwd'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'cwd') || isempty(threshold.cwd)
				threshold.cwd=ones(Nest,1);
			end
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=threshold.cwd(k));
				aux(ind)=1;
				for j=1:Nagg
					ind=find(datesAgg==j)';
					indicator(i).Index(j,k)=0;
					maximo=0;
					for l=ind
						if aux(l)==1
							indicator(i).Index(j,k)=indicator(i).Index(j,k)+1;
						else
							if indicator(i).Index(j,k)>maximo
								maximo=indicator(i).Index(j,k);
							else
								indicator(i).Index(j,k)=0;
							end
						end
					end
					indicator(i).Index(j,k)=max(maximo,indicator(i).Index(j,k));
				end
			end
		case 'r10'
			[ndata,Nest]=size(Pr);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=10);aux(ind)=1;
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<10);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'r20'
			[ndata,Nest]=size(Pr);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=20);aux(ind)=1;
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<20);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'rx1day'
			indicator(i).Index=aggregateData(Pr,period,aggregation,'aggfun','nanmax','missing',missing);
		case 'rx5day'
			[ndata,Nest]=size(Pr);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			for j=1:Nagg
				ind=find(datesAgg==j)';
				aux=repmat(NaN,length(ind)-4,Nest);
				for k=1:length(ind)-4
					aux(k,:)=nansum(Pr(ind(k):ind(k)+4,:));
				end
				indicator(i).Index(j,:)=nanmax(aux);
			end
		case 'r75p'
			[ndata,Nest]=size(Pr);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>threshold.r75p(k));
				aux(ind)=1;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'r75ptot'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			aux=Pr;aux(~isnan(aux) & Pr-repmat(threshold.rr1(:)',ndata,1)<=0)=0;
			RR=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);clear aux
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=Pr(:,k);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<=threshold.r75ptot(k));
				aux(ind)=0;
				aux=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
				ind=find(~isnan(RR(:,k)));
				indicator(i).Index(ind,k)=100*aux(ind)./RR(ind,k);
			end
		case 'r90p'
			[ndata,Nest]=size(Pr);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>threshold.r90p(k));
				aux(ind)=1;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'r90ptot'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			aux=Pr;aux(~isnan(aux) & Pr-repmat(threshold.rr1(:)',ndata,1)<=0)=0;
			RR=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);clear aux
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=Pr(:,k);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<=threshold.r90ptot(k));
				aux(ind)=0;
				aux=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
				ind=find(~isnan(RR(:,k)));
				indicator(i).Index(ind,k)=100*aux(ind)./RR(ind,k);
			end
		case 'r95p'
			[ndata,Nest]=size(Pr);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>threshold.r95p(k));
				aux(ind)=1;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'r95ptot'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			aux=Pr;aux(~isnan(aux) & Pr-repmat(threshold.rr1(:)',ndata,1)<=0)=0;
			RR=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);clear aux
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=Pr(:,k);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<=threshold.r95ptot(k));
				aux(ind)=0;
				aux=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
				ind=find(~isnan(RR(:,k)));
				indicator(i).Index(ind,k)=100*aux(ind)./RR(ind,k);
			end
		case 'r99p'
			[ndata,Nest]=size(Pr);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>threshold.r99p(k));
				aux(ind)=1;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'r99ptot'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			aux=Pr;aux(~isnan(aux) & Pr-repmat(threshold.rr1(:)',ndata,1)<=0)=0;
			RR=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);clear aux
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=Pr(:,k);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<=threshold.r99ptot(k));
				aux(ind)=0;
				aux=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
				ind=find(~isnan(RR(:,k)));
				indicator(i).Index(ind,k)=100*aux(ind)./RR(ind,k);
			end
		case 'raip'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			aux=Pr;aux(~isnan(aux) & Pr-repmat(threshold.rr1(:)',ndata,1)<=0)=NaN;
			RRMean=repmat(NaN,1,Nest);
			for k=1:Nest
				RRMean(k)=nanmean(aux(:,k));
			end
			RR=aggregateData(aux,period,aggregation,'aggfun','nanmean','missing',missing);clear aux
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=sort(Pr(find(~isnan(Pr(:,k))),k));
				a1=max(1,length(aux)-9);M10=nanmean(aux(a1:end));
				indicator(i).Index(:,k)=3*(RR(:,k)-RRMean(k))/(M10-RRMean(k));
			end
		case 'rain'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			aux=Pr;aux(~isnan(aux) & Pr-repmat(threshold.rr1(:)',ndata,1)<=0)=NaN;
			RRMean=repmat(NaN,1,Nest);
			for k=1:Nest
				RRMean(k)=nanmean(aux(:,k));
			end
			RR=aggregateData(aux,period,aggregation,'aggfun','nanmean','missing',missing);clear aux
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=sort(Pr(find(~isnan(Pr(:,k))),k));
				a1=min(10,length(aux));m10=nanmean(aux(1:a1));
				indicator(i).Index(:,k)=-3*(RR(:,k)-RRMean(k))/(m10-RRMean(k));
			end
		case 'sd'
			indicator(i).Index=aggregateData(Nv,period,aggregation,'aggfun','nanmean','missing',missing);
		case 'sd1'
			[ndata,Nest]=size(Nv);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Nv(:,k)) & Nv(:,k)>=1);aux(ind)=1;
				ind=find(~isnan(Nv(:,k)) & Nv(:,k)<1);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'sd5'
			[ndata,Nest]=size(Nv);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Nv(:,k)) & Nv(:,k)>=5);aux(ind)=1;
				ind=find(~isnan(Nv(:,k)) & Nv(:,k)<5);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'sd50'
			[ndata,Nest]=size(Nv);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=find(~isnan(Nv(:,k)) & Nv(:,k)>=50);aux(ind)=1;
				ind=find(~isnan(Nv(:,k)) & Nv(:,k)<50);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		case 'tg'
			indicator(i).Index=aggregateData(Tg,period,aggregation,'aggfun','nanmean','missing',missing);
		case 'tn'
			indicator(i).Index=aggregateData(Tn,period,aggregation,'aggfun','nanmean','missing',missing);
		case 'tx'
			indicator(i).Index=aggregateData(Tx,period,aggregation,'aggfun','nanmean','missing',missing);
		case 'dtr'
			indicator(i).Index=aggregateData(Tx-Tn,period,aggregation,'aggfun','nanmean','missing',missing);
		case 'etr'
			indicator(i).Index=aggregateData(Tx,period,aggregation,'aggfun','nanmax','missing',missing)-aggregateData(Tn,period,aggregation,'aggfun','nanmin','missing',missing);
		case 'vdtr'
			[ndata,Nest]=size(Tn);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			fechas=datesym(period,'yyyymmdd');
			for j=1:Nagg
				% ind=strmatch(datesAgg(j,:),fechas)';
				ind=find(datesAgg==j)';
				indicator(i).Index(j,:)=nanmean(abs(Tx(ind(2:end),:)-Tx(ind(1:end-1),:)-Tn(ind(2:end),:)+Tn(ind(1:end-1),:)));
			end
		case 'rx3day'
		[ndata,Nest]=size(Pr);
		indicator(i).Index=repmat(NaN,Nagg,Nest);
		fechas=datesym(period,'yyyymmdd');
		for j=1:Nagg
			ind=find(datesAgg==j)';
			aux=NaN*zeros(length(ind)-2,Nest);
			for k=1:length(ind)-2
				aux(k,:)=nansum(Pr(ind(k):ind(k)+2,:));
			end
			indicator(i).Index(j,:)=nanmax(aux);
		end
		case 'hw'
			[ndata,Nest]=size(Tx);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=NaN*zeros(ndata,1);
				ind=find(~isnan(Tx(:,k)) & Tx(:,k)>35);aux(ind)=1;
				ind=find(~isnan(Tx(:,k)) & Tx(:,k)<=35);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% Frost-thaw cycles (number of days): number of days with temperature zero-crossings, estimated by mean of the maximum and minimum temperature
		case 'ftd'
			[ndata,Nest]=size(Tx);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=NaN*zeros(ndata,1);
				ind=intersect(find(~isnan(Tx(:,k)) & Tx(:,k)>0),find(~isnan(Tn(:,k)) & Tn(:,k)<0));aux(ind)=1;
				ind=union(find(~isnan(Tx(:,k)) & Tx(:,k)<=0),find(~isnan(Tn(:,k)) & Tn(:,k)>=0));aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% Yearly maximum snowfall (mm): Yearly maximum value of daily snowfall
		case 'sdx1day'
			indicator(i).Index=aggregateData(Nv,period,aggregation,'aggfun','nanmax','missing',missing);
		% Number of days with snow depth 0-10 cm (number of days): frequency of day with thin thick snow depths
		case 'sd010'
			[ndata,Nest]=size(Nv);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=intersect(find(~isnan(Nv(:,k)) & Nv(:,k)>0),find(~isnan(Nv(:,k)) & Nv(:,k)<=10));aux(ind)=1;
				ind=union(find(~isnan(Nv(:,k)) & Nv(:,k)<=0),find(~isnan(Nv(:,k)) & Nv(:,k)>10));aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% Number of days with snow depth 10-20 cm (number of days): frequency of day with medium thick snow depths
		case 'sd1020'
			[ndata,Nest]=size(Nv);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,1);
				ind=intersect(find(~isnan(Nv(:,k)) & Nv(:,k)>10),find(~isnan(Nv(:,k)) & Nv(:,k)<=20));aux(ind)=1;
				ind=union(find(~isnan(Nv(:,k)) & Nv(:,k)<=10),find(~isnan(Nv(:,k)) & Nv(:,k)>20));aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% Wind indicators:
		% Average of daily mean wind speed (m/s)
		case 'fg'
			indicator(i).Index=aggregateData(Ws,period,aggregation,'aggfun','nanmean','missing',missing);
		% Maximum of daily mean wind speed (m/s)
		case 'fgx1day'
			indicator(i).Index=aggregateData(Ws,period,aggregation,'aggfun','nanmax','missing',missing);
		case 'fg6bft'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)>=10.8);aux(ind)=1;
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)<10.8);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'fgcalm'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)<=2);aux(ind)=1;
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)>2);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'ddnorth'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=union(find(~isnan(Wd(:,k)) & Wd(:,k)<=45),find(~isnan(Wd(:,k)) & Wd(:,k)>315));aux(ind)=1;
				ind=intersect(find(~isnan(Wd(:,k)) & Wd(:,k)>45),find(~isnan(Wd(:,k)) & Wd(:,k)<=315));aux(ind)=0;				
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'ddsouth'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=intersect(find(~isnan(Wd(:,k)) & Wd(:,k)<=225),find(~isnan(Wd(:,k)) & Wd(:,k)>135));aux(ind)=1;
				ind=union(find(~isnan(Wd(:,k)) & Wd(:,k)>225),find(~isnan(Wd(:,k)) & Wd(:,k)<=135));aux(ind)=0;				
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'ddwest'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=intersect(find(~isnan(Wd(:,k)) & Wd(:,k)<=315),find(~isnan(Wd(:,k)) & Wd(:,k)>225));aux(ind)=1;
				ind=union(find(~isnan(Wd(:,k)) & Wd(:,k)>315),find(~isnan(Wd(:,k)) & Wd(:,k)<=225));aux(ind)=0;				
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'ddeast'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=intersect(find(~isnan(Wd(:,k)) & Wd(:,k)<=135),find(~isnan(Wd(:,k)) & Wd(:,k)>45));aux(ind)=1;
				ind=union(find(~isnan(Wd(:,k)) & Wd(:,k)>135),find(~isnan(Wd(:,k)) & Wd(:,k)<=45));aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		% Number of days with wind speed >  5 (moderate), 10 (strong), 15 (very strong) or 25 (storm) m/s (number of days	frequency of moderate winds	eastward and northward wind component (or wind speed)	yes
		case 'fg05'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)>5);aux(ind)=1;
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)<=5);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'fg10'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)>10);aux(ind)=1;
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)<=10);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'fg15'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)>15);aux(ind)=1;
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)<=15);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		case 'fg25'
			[ndata,Nest]=size(Ws);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=repmat(NaN,ndata,1);
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)>25);aux(ind)=1;
				ind=find(~isnan(Ws(:,k)) & Ws(:,k)<=25);aux(ind)=0;
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',1);
			end
		% DW		Number of dry (RR<0.1 mm)-warm (TG>75th percentile) days  
		case 'dw'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			indicator(i).Index=zeros(Nagg,Nest)*NaN;
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,2);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tg(ind,k)) & Tg(ind,k)>threshold.tg75p(j,k));
					aux(ind(ind1),1)=1;
				end
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=threshold.rr1(k));aux(ind,2)=0;
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<threshold.rr1(k));aux(ind,2)=1;
				aux=aux(:,1).*aux(:,2);
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% DC		Number of dry (RR<0.1 mm)-cold (TG<25th percentile) days  
		case 'dc'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			indicator(i).Index=zeros(Nagg,Nest)*NaN;
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,2);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tg(ind,k)) & Tg(ind,k)<threshold.tg25p(j,k));
					aux(ind(ind1),1)=1;
				end
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=threshold.rr1(k));aux(ind,2)=0;
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<threshold.rr1(k));aux(ind,2)=1;
				aux=aux(:,1).*aux(:,2);
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% WW		Number of wet (RR<0.1 mm)-warm (TG>75th percentile) days  
		case 'ww'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			indicator(i).Index=zeros(Nagg,Nest)*NaN;
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,2);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tg(ind,k)) & Tg(ind,k)>threshold.tg75p(j,k));
					aux(ind(ind1),1)=1;
				end
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=threshold.rr1(k));aux(ind,2)=1;
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<threshold.rr1(k));aux(ind,2)=0;
				aux=aux(:,1).*aux(:,2);
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% WC		Number of wet (RR<0.1 mm)-cold (TG<25th percentile) days  
		case 'wc'
			[ndata,Nest]=size(Pr);
			if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
				threshold.rr1=ones(Nest,1);
			end
			indicator(i).Index=zeros(Nagg,Nest)*NaN;
			fechas=datesym(period,'yyyymmdd');
			diasRef=datesym(datenum('01-Jan-1961'):datenum('31-Dec-1990'),'yyyymmdd');
			diasRef=unique(diasRef(:,5:end),'rows');
			for k=1:Nest
				aux=zeros(ndata,2);
				for j=1:size(diasRef,1)
					ind=strmatch(diasRef(j,:),fechas(:,5:end));
					ind1=find(~isnan(Tg(ind,k)) & Tg(ind,k)<threshold.tg25p(j,k));
					aux(ind(ind1),1)=1;
				end
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=threshold.rr1(k));aux(ind,2)=1;
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<threshold.rr1(k));aux(ind,2)=0;
				aux=aux(:,1).*aux(:,2);
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% FRD		Number of freezing rain (TX<0�C y RR>0.5 mm)
		case 'frd'
			[ndata,Nest]=size(Pr);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,2);
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)>=threshold.rr5(k));aux(ind,1)=1;
				ind=find(~isnan(Pr(:,k)) & Pr(:,k)<threshold.rr5(k));aux(ind,1)=0;
				ind=find(~isnan(Tx(:,k)) & Tx(:,k)>=0);aux(ind,2)=0;
				ind=find(~isnan(Tx(:,k)) & Tx(:,k)<0);aux(ind,2)=1;
				aux=aux(:,1).*aux(:,2);
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		% SDratio	Average total annual / seasonal snowfall	
		case 'sdratio'
			[auxS,auxAggS]=aggregateData(Nv,period,'S','aggfun','nansum','missing',missing);
			[auxY,auxAggY]=aggregateData(Nv,period,'Y','aggfun','nansum','missing',missing);
			[auxYears,I1,I2]=unique(auxAggS(:,1:4),'rows');
			indicator(i).Index=auxS(find(ismember(auxAggY,auxAggS(:,1:4))),:)./auxY(I2(find(ismember(auxAggY,auxAggS(:,1:4)))),:);		
		% HU90	Number of days when the relative humidity (daily mean) is above 90% and mean temperature > 10 �C
		case 'hu90'
			[ndata,Nest]=size(Rh);
			indicator(i).Index=repmat(NaN,Nagg,Nest);
			for k=1:Nest
				aux=zeros(ndata,2);
				ind=find(~isnan(Rh(:,k)) & Rh(:,k)>=90);aux(ind,1)=1;
				ind=find(~isnan(Rh(:,k)) & Rh(:,k)<90);aux(ind,1)=0;
				ind=find(~isnan(Tg(:,k)) & Tg(:,k)>=10);aux(ind,2)=1;
				ind=find(~isnan(Tg(:,k)) & Tg(:,k)<10);aux(ind,2)=0;
				aux=aux(:,1).*aux(:,2);
				indicator(i).Index(:,k)=aggregateData(aux,period,aggregation,'aggfun','nansum','missing',missing);
			end
		otherwise
			if strmatch('prc',lower(nombres{i}))
				nombre=nombres{i};
                prcValue=str2num(nombre(6:end));nombre=nombre(1:5);
				switch lower(nombre(end-1:end))
					case 'pr'
						if ~isfield(threshold,'rr1') || isempty(threshold.rr1)
							threshold.rr1=ones(Nest,1);
						end
						[ndata,Nest]=size(Pr);
						indicator(i).Index=repmat(NaN,Nagg,Nest);
						for j=1:Nagg
							ind=find(datesAgg==j)';
							data=Pr(ind,:);data(find(~isnan(Pr(ind,:)) & Pr(ind,:)<repmat(threshold.rr1(:)',length(ind),1)))=NaN;
							indicator(i).Index(j,:)=prctile(data,prcValue);
						end
					otherwise
						data=eval([upper(nombre(end-1)) nombre(end)]);
						[ndata,Nest]=size(data);
						indicator(i).Index=repmat(NaN,Nagg,Nest);
						for j=1:Nagg
							ind=find(datesAgg==j)';
							indicator(i).Index(j,:)=prctile(data(ind,:),prcValue);
						end
						
				end
			end
				
	end
	disp(indicator(i).Name)
end
