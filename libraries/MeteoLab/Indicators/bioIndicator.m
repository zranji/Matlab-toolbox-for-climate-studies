function indicator=bioIndicator(period,varargin);

% This function estimates the extremes index defined by the ETCCDMI. 
% The input are:
% 	- period: vector of dates (datenums)
% 	- varagin: optional inputs.
% 		- variables: {'Tx';'Tn';'Tn';'Pr'}, ndata x Nest dimensions matrix whit the daily data. Each row represent an observed day and
%		each column an station or grid point. The data units must be: ºC for temperature (Tx,Tn,Tg) and mm for precipitation (Pr).
% 		- missing: maximun percentage of missing data (i.e. NaN) per group.
% 		- names: cell with the index names. The namelist is:
%%%%%%%%%%% Indicators defined in: http://www.worldclim.org/bioclim %%%%%%%%%%%
% BIO01. Annual mean temperature
% BIO02. Mean diurnal range (mean monthly maximum - mean monthly minimum)
% BIO03. Isothermality (mean diurnal range/temperature annual range)
% BIO04. Temperature seasonality (Standard deviation * 100)
% BIO05. Maximum temperature of warmest month
% BIO06. Minimum temperature of coldest month
% BIO07. Temperature annual range (maximum temperature of warmest month - minimum temperature of coldest month)
% BIO08. Mean temperature of wettest quarter
% BIO09. Mean temperature of driest quarter
% BIO10. Mean temperature of warmest quarter
% BIO11. Mean temperature of coldest quarter
% BIO12. Annual precipitation
% BIO13. Precipitation of wettest month
% BIO14. Precipitation of driest month
% BIO15. Precipitation seasonality (Coefficient of Variation)
% BIO16. Precipitation of wettest quarter
% BIO17. Precipitation of driest quarter
% BIO18. Precipitation of warmest quarter
% BIO19. Precipitation of coldest quarter
nombres=[];
missing=1;
treshold=[];
Tx=[];Tn=[];Tg=[];Pr=[];Ps=[];Nv=[];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'names', nombres=varargin{i+1};
        case 'missing', missing=varargin{i+1};
        case 'tx', Tx=varargin{i+1};
        case 'tn', Tn=varargin{i+1};
        case 'tg', Tg=varargin{i+1};
        case 'pr', Pr=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end

Nindex=length(nombres);
if Nindex<1
	error('At least an indicator name is necessary')
end

if ~isempty(Tx)
	[monthlyTx,monthlyDates]=aggregateData(Tx,period,'M','aggfun','nanmean','missing',missing);
end
if ~isempty(Tn)
	[monthlyTn,monthlyDates]=aggregateData(Tn,period,'M','aggfun','nanmean','missing',missing);
end
if ~isempty(Tg)
	[monthlyTg,monthlyDates]=aggregateData(Tg,period,'M','aggfun','nanmean','missing',missing);
end
if ~isempty(Pr)
	[monthlyPr,monthlyDates]=aggregateData(Pr,period,'M','aggfun','nansum','missing',missing);
end
for i=1:Nindex
	indicator(i).Name=nombres{i};
	switch lower(nombres{i})
		case 'bio01'% BIO01. Annual mean temperature
			indicator(i).Index=aggregateData(Tg,period,'Y','aggfun','nanmean','missing',missing);
		case 'bio02'% BIO02. Mean diurnal range (mean monthly maximum - mean monthly minimum)
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');Nyears=size(years,1);Nest=size(monthlyTx,2);
			indicator(i).Index=NaN*zeros(Nyears,Nest);
			for j=1:Nyears
				ind=find(I2==j);
				indicator(i).Index(j,:)=nanmean(monthlyTx(ind,:)-monthlyTn(ind,:));
			end
		case 'bio03'% BIO03. Isothermality (mean diurnal range/temperature annual range)
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');Nyears=size(years,1);Nest=size(monthlyTx,2);
			indicator(i).Index=NaN*zeros(Nyears,Nest);
			for j=1:Nyears
				ind=find(I2==j);
				indicator(i).Index(j,:)=nanmean(monthlyTx(ind,:)-monthlyTn(ind,:))./(max(monthlyTx(ind,:))-min(monthlyTn(ind,:)));
			end
		case 'bio04'% BIO04. Temperature seasonality (Coefficient of Variation)
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');
			Nyears=size(years,1);Nest=size(monthlyTg,2);
			indicator(i).Index=NaN*zeros(Nyears,Nest);
			for j=1:Nyears
				ind=find(I2==j);
				indicator(i).Index(j,:)=sqrt(nanvar(monthlyTg(ind,:)))*100;
			end
		case 'bio05'% BIO05. Maximum temperature of warmest month
			[ndata,Nest]=size(Tx);
			dailyDates=datevec(period);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				[wmTx,wm]=max(monthlyTx(find(I2==j),:),[],1);
				indicator(i).Index(j,:)=wmTx;
			end
		case 'bio06'% BIO06. Minimum temperature of coldest month
			[ndata,Nest]=size(Tn);
			dailyDates=datevec(period);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				[cmTn,cm]=min(monthlyTn(find(I2==j),:),[],1);
				indicator(i).Index(j,:)=cmTn;
			end
		case 'bio07'% BIO07. Temperature annual range (maximum temperature of warmest month - minimum temperature of coldest month)
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');Nyears=size(years,1);Nest=size(monthlyTx,2);
			indicator(i).Index=NaN*zeros(Nyears,Nest);
			for j=1:Nyears
				ind=find(I2==j);
				indicator(i).Index(j,:)=(max(monthlyTx(ind,:))-min(monthlyTn(ind,:)));
			end
		case 'bio08'% BIO08. Mean temperature of wettest quarter
			[ndata,Nest]=size(Tg);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				indices=find(I2==j);
				aux=NaN*zeros(length(indices)-2,Nest);
				for k=1:length(indices)-2
					aux(k,:)=nansum(monthlyPr(indices(k:k+2,:),:));
				end
				[wqPr,wq]=max(aux,[],1);
				for k=1:Nest
					indicator(i).Index(j,k)=nanmean(monthlyTg(indices(wq(k)):indices(wq(k))+2,k));
				end
			end
		case 'bio09'% BIO09. Mean temperature of driest quarter
			[ndata,Nest]=size(Tg);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				indices=find(I2==j);
				aux=NaN*zeros(length(indices)-2,Nest);
				for k=1:length(indices)-2
					aux(k,:)=nansum(monthlyPr(indices(k:k+2,:),:));
				end
				[dqPr,dq]=min(aux,[],1);
				for k=1:Nest
					indicator(i).Index(j,k)=nanmean(monthlyTg(indices(dq(k)):indices(dq(k))+2,k));
				end
			end
		case 'bio10'% BIO10. Mean temperature of warmest quarter
			[ndata,Nest]=size(Tg);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				indices=find(I2==j);
				aux=NaN*zeros(length(indices)-2,Nest);
				for k=1:length(indices)-2
					aux(k,:)=nanmean(monthlyTx(indices(k:k+2,:),:));
				end
				[wqTx,wq]=max(aux,[],1);
				for k=1:Nest
					indicator(i).Index(j,k)=nanmean(monthlyTg(indices(wq(k)):indices(wq(k))+2,k));
				end
			end
		case 'bio11'% BIO11. Mean temperature of coldest quarter
			[ndata,Nest]=size(Tg);
			dailyDates=datevec(period);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				indices=find(I2==j);
				aux=NaN*zeros(length(indices)-2,Nest);
				for k=1:length(indices)-2
					aux(k,:)=nanmean(monthlyTn(indices(k:k+2,:),:));
				end
				[cqTn,cq]=min(aux,[],1);
				for k=1:Nest
					indicator(i).Index(j,k)=nanmean(monthlyTg(indices(cq(k)):indices(cq(k))+2,k));
				end
			end
		case 'bio12'% BIO12. Annual precipitation
			indicator(i).Index=aggregateData(Pr,period,'Y','aggfun','nansum','missing',missing);
		case 'bio13'% BIO13. Precipitation of wettest month
			[ndata,Nest]=size(Pr);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				[wmPr,wm]=max(monthlyPr(find(I2==j),:),[],1);
				indicator(i).Index(j,:)=wmPr;
			end
		case 'bio14'% BIO14. Precipitation of driest month
			[ndata,Nest]=size(Pr);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				[dmPr,dm]=min(monthlyPr(find(I2==j),:),[],1);
				indicator(i).Index(j,:)=dmPr;
			end
		case 'bio15'% BIO15. Precipitation seasonality (Coefficient of Variation)
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');
			Nyears=size(years,1);Nest=size(monthlyPr,2);
			indicator(i).Index=NaN*zeros(Nyears,Nest);
			for j=1:Nyears
				ind=find(I2==j);
				indicator(i).Index(j,:)=sqrt(nanvar(monthlyPr(ind,:)))./nanmean(monthlyPr(ind,:));
			end
		case 'bio16'% BIO16. Precipitation of wettest quarter
			[ndata,Nest]=size(Pr);
			dailyDates=datevec(period);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				indices=find(I2==j);
				aux=NaN*zeros(length(indices)-2,Nest);
				for k=1:length(indices)-2
					aux(k,:)=nansum(monthlyPr(indices(k:k+2,:),:));
				end
				[wqPr,wq]=max(aux,[],1);
				indicator(i).Index(j,:)=wqPr;
			end
		case 'bio17'% BIO17. Precipitation of driest quarter
			[ndata,Nest]=size(Pr);
			dailyDates=datevec(period);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				indices=find(I2==j);
				aux=NaN*zeros(length(indices)-2,Nest);
				for k=1:length(indices)-2
					aux(k,:)=nansum(monthlyPr(indices(k:k+2,:),:));
				end
				[dqPr,dq]=min(aux,[],1);
				indicator(i).Index(j,:)=dqPr;
			end
		case 'bio18'% BIO18. Precipitation of warmest quarter
			[ndata,Nest]=size(Pr);
			dailyDates=datevec(period);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				indices=find(I2==j);
				aux=NaN*zeros(length(indices)-2,Nest);
				for k=1:length(indices)-2
					aux(k,:)=nanmean(monthlyTx(indices(k:k+2,:),:));
				end
				[wqTx,wq]=max(aux,[],1);
				for k=1:Nest
					indicator(i).Index(j,k)=nansum(monthlyPr(indices(wq):indices(wq)+2,k));
				end
			end
		case 'bio19'% BIO19. Precipitation of coldest quarter
			[ndata,Nest]=size(Pr);
			dailyDates=datevec(period);
			[years,I1,I2]=unique(monthlyDates(:,1:4),'rows');years=str2num(years);
			indicator(i).Index=NaN*zeros(length(years),Nest);
			for j=1:length(years)
				indices=find(I2==j);
				aux=NaN*zeros(length(indices)-2,Nest);
				for k=1:length(indices)-2
					aux(k,:)=nanmean(monthlyTn(indices(k:k+2,:),:));
				end
				[cqTn,cq]=max(aux,[],1);
				for k=1:Nest
					indicator(i).Index(j,k)=nansum(monthlyPr(indices(cq):indices(cq)+2,k));
				end
			end
	end
	disp(indicator(i).Name)
end
