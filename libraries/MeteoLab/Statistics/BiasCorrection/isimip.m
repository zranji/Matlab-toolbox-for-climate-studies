function F=isimip(O,P,F,varargin);
% Example
[ndata,Nest]=size(O);Tg=[];Ws=[];
variable='';threshold=0;datesObs=[1:ndata]';datesFor=[1:size(F,1)]';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'threshold', threshold=varargin{i+1};
        case 'variable', variable=varargin{i+1};
        case 'datesobs', datesObs=varargin{i+1};
        case 'datesfor', datesFor=varargin{i+1};
        case {'tg','tas','mean temperature'}, Tg=varargin{i+1};
        case {'wss','wind speed','windspeed'}, Ws=varargin{i+1};
        case {'pr','tp','precipitation','precipitacion'}, Pr=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end
[monthlyO,dateAggObs]=aggregateData(O,datesObs,'M','aggFun','nanmean','missing',1);
[monthlyP,dateAggObs]=aggregateData(P,datesObs,'M','aggFun','nanmean','missing',1);
[months,I,J]=unique(dateAggObs(:,5:6),'rows');months=str2num(months);
datesVecFor=datevec(datesFor(:));datesVecObs=datevec(datesObs(:));
[aux,I1,month2dayObs]=unique(datesVecObs(:,1:2),'rows');[aux,I1,month2dayFor]=unique(datesVecFor(:,1:2),'rows');clear aux I1
if size(threshold(:),1)==1,threshold=[1 1 1]*threshold;end
switch lower(variable)
    case {'precipitation';'precipitacion'},
        % First Step: Monthly Correction
        monthlyCorrection=repmat(NaN,length(months),Nest+1);monthlyCorrection(:,1)=months;
        for i=1:length(months)
            indMonth=find(str2num(dateAggObs(:,5:6))==monthlyCorrection(i,1));
            monthlyCorrection(i,2:end)=nansum(monthlyO(indMonth,:))./nansum(monthlyP(indMonth,:));
        end
        % Correccion de la frecuencia de d�as secos y redistribucion de la precipitacion entre el resto de dias:
        % nP=nansum(double(monthlyO<=threshold(1) & ~isnan(monthlyO)).*double(monthlyP<=0 & ~isnan(monthlyP)));% Interpretamos la formula como interseccion
        nP=nansum(double(monthlyO<=threshold(1) & ~isnan(monthlyO)));
        nP1=nansum(double(monthlyP<=0 & ~isnan(monthlyP)));% Interpretamos la formula como interseccion
        Ndry=repmat(NaN,1,Nest);epsM=repmat(NaN,1,Nest);
        epsM(find(sum([nP;-nP1])<0 & ~isnan(sum([nP;-nP1]))))=0;
        for i=1:Nest
            if nP(i)>=nP1(i)
                auxP=sort(monthlyP(:,i));epsM(i)=auxP(min(nP(i)+1,size(monthlyP,1)));clear auxP
                indMonth=find(monthlyO(:,i)>threshold(1));
                if ~isempty(indMonth)
                    indWetMonth=find(ismember(month2dayObs,indMonth) & ~isnan(P(:,i)));
                    Ndry(i)=length(find(O(indWetMonth,i)<threshold(3)));
                end
           end
        end
        epsD=repmat(NaN,1,Nest);
        for i=1:Nest
            indMonth=find(monthlyP(:,i)>epsM(i));
            if ~isempty(indMonth)
                indWetMonth=find(ismember(month2dayObs,indMonth) & ~isnan(P(:,i)));
				aux=sort(P(indWetMonth,i));
                if isnan(Ndry(i)) || Ndry(i)>=length(indWetMonth)
                    Ndry(i)=length(indWetMonth);
                    epsD(i)=max(P(indWetMonth(P(indWetMonth,i)<=aux(Ndry(i))),i));
                else
                    try
                        epsD(i)=0.5*max(P(indWetMonth(P(indWetMonth,i)<=aux(Ndry(i))),i))+0.5*min(P(indWetMonth(P(indWetMonth,i)>aux(Ndry(i))),i));
                    catch
                        disp(i),keyboard
                    end
                end
                for j=1:length(indMonth)
					% indWetMonth=find(ismember(month2dayObs,indMonth)); % No es equivalente a lo de abajo? COMPROBAR
                    indWetMonth=find((datesVecObs(:,1)-str2double(dateAggObs(indMonth(j),1:4))).^2+(datesVecObs(:,2)-str2double(dateAggObs(indMonth(j),5:6))).^2==0);
                    indDryMonth=indWetMonth(P(indWetMonth,i)<=epsD(i));
                    mi=nansum(P(indDryMonth,i))/(length(indWetMonth)-length(indDryMonth));
                    P(indWetMonth(P(indWetMonth,i)>epsD(i)),i)=P(indWetMonth(P(indWetMonth,i)>epsD(i)),i)+mi;P(indDryMonth,i)=0;
                end
            end
        end
        [monthlyF,dateAggFor]=aggregateData(F,datesFor,'M','aggFun','nanmean','missing',1);
        for i=1:Nest
            indMonth=find(monthlyF(:,i)>epsM(i));
            if ~isempty(indMonth)
                for j=1:length(indMonth)
                    indWetMonth=find((datesVecFor(:,1)-str2double(dateAggFor(indMonth(j),1:4))).^2+(datesVecFor(:,2)-str2double(dateAggFor(indMonth(j),5:6))).^2==0);
                    indDryMonth=indWetMonth(F(indWetMonth,i)<=epsD(i));
                    if ~isempty(indDryMonth)
                        mi=nansum(F(indDryMonth,i))/(length(indWetMonth)-length(indDryMonth));
                        F(indWetMonth(F(indWetMonth,i)>epsD(i)),i)=F(indWetMonth(F(indWetMonth,i)>epsD(i)),i)+mi;F(indDryMonth,i)=0;
                    end
                end
            end
        end
        wetDaysObs=double(P>repmat(epsD,size(P,1),1) & ~isnan(P)).*double(monthlyP(month2dayObs,:)>repmat(epsM,size(P,1),1)).*double(O>threshold(3) & ~isnan(O)).*double(monthlyO(month2dayObs,:)>threshold(1));
        wetDaysFor=double(F>repmat(epsD,size(F,1),1) & ~isnan(F)).*double(monthlyF(month2dayFor,:)>repmat(epsM,size(F,1),1));
        for i=1:Nest
            auxMonthly=monthlyF(month2dayFor,i);indAuxMonthly=find(auxMonthly>epsM(i));
            F(indAuxMonthly,i)=F(indAuxMonthly,i)./auxMonthly(indAuxMonthly);clear indAuxMonthly auxMonthly
            indAuxMonthly=find(wetDaysObs(:,i)==1);P(indAuxMonthly,i)=P(indAuxMonthly,i)./monthlyP(month2dayObs(indAuxMonthly),i);
            indAuxMonthly=find(wetDaysObs(:,i)==1);O(indAuxMonthly,i)=O(indAuxMonthly,i)./monthlyO(month2dayObs(indAuxMonthly),i);
        end
        for i=1:Nest,
            for j=1:length(months)
                indMonth=find(datesVecObs(:,2)==j & wetDaysObs(:,i)==1);
                try
                    if length(indMonth)>80 && min(nanmean(P(indMonth,i)),nanmean(O(indMonth,i)))>0.01
                        optAdjust=statset('Robust','on');
                        [paramEstsOBS1,rAdjust1,jAdjust1,covbAdjust1,mseAdjust1]=nlinfit(sort(P(indMonth,i)),sort(O(indMonth,i)),@myfun,[rand(1,2) rand(1,1)*(max(P(indMonth,i))-min(P(indMonth,i)))],optAdjust);% [Shape parameter  Scale parameter]
                        [paramEstsOBS2,rAdjust2,jAdjust2,covbAdjust2,mseAdjust2]=nlinfit(sort(P(indMonth,i)),sort(O(indMonth,i)),@myfun,[rand(1,2) rand(1,1)*(max(P(indMonth,i))-min(P(indMonth,i)))],optAdjust);% [Shape parameter  Scale parameter]
                        if min(mseAdjust1,mseAdjust2)<=1e-8
                            [mseAdjust,I1]=min([mseAdjust1;mseAdjust2]);
                            switch I1,
                                case 1,paramEstsOBS=paramEstsOBS1;jAdjust=jAdjust1;
                                case 2,paramEstsOBS=paramEstsOBS2;jAdjust=jAdjust2;
                            end
                            clear paramEstsOBS1 rAdjust1 jAdjust1 covbAdjust1 mseAdjust1 paramEstsOBS2 rAdjust2 jAdjust2 covbAdjust2 mseAdjust2
                            [qAdjust,adjustR]=qr(jAdjust,0);
                            if condest(adjustR)<=1/(eps(class(paramEstsOBS)))^(1/2) && numel(sort(P(indMonth,i)))>numel(paramEstsOBS)
                                F(datesVecFor(:,2)==j & wetDaysFor(:,i)==1,i)=abs(myfun(paramEstsOBS,F(datesVecFor(:,2)==j & wetDaysFor(:,i)==1,i)));
                            end
                        else
                            paramEstsOBS=regress(sort(P(indMonth,i)),[ones(length(indMonth),1) sort(O(indMonth,i))]);% [Shape parameter  Scale parameter]
                            F(datesVecFor(:,2)==j & wetDaysFor(:,i)==1,i)=abs(paramEstsOBS(1)+paramEstsOBS(2)*F(datesVecFor(:,2)==j & wetDaysFor(:,i)==1,i));
                        end
                    end
                end
            end
        end
        for i=1:length(months)
            indMonth=find(datesVecFor(:,2)==monthlyCorrection(i,1));
            for j=1:Nest,
                indMonth1=intersect(indMonth,find(monthlyF(month2dayFor,j)>epsM(j)));
                if ~isempty(indMonth1)
                    F(indMonth1,j)=(F(indMonth1,j).*monthlyF(month2dayFor(indMonth1),j))*monthlyCorrection(i,j+1);
                end
            end
        end
    case {'radiation';'pressure';'radiacion';'presion';'wind';'windspeed';'viento';'humidity';'rss';'rsds';'rls';'rlds';'ps';'wss';'huss';'hus'},
        % First Step: Monthly Correction
        monthlyCorrection=repmat(NaN,length(months),Nest+1);monthlyCorrection(:,1)=months;
        for i=1:length(months)
            indMonth=find(str2num(dateAggObs(:,5:6))==monthlyCorrection(i,1));
            monthlyCorrection(i,2:end)=nansum(monthlyO(indMonth,:))./nansum(monthlyP(indMonth,:));
        end
        nP=nansum(double(monthlyO<=threshold(1) & ~isnan(monthlyO)));
        nP1=nansum(double(monthlyP<=0 & ~isnan(monthlyP)));% Interpretamos la formula como interseccion
        Ndry=repmat(NaN,1,Nest);epsM=repmat(NaN,1,Nest);
        epsM(find(sum([nP;-nP1])<0 & ~isnan(sum([nP;-nP1]))))=0;
        for i=1:Nest
            if nP(i)>=nP1(i)
                auxP=sort(monthlyP(:,i));epsM(i)=auxP(min(nP(i)+1,size(monthlyP,1)));clear auxP
                indMonth=find(monthlyO(:,i)>threshold(1));
                if ~isempty(indMonth)
                    indWetMonth=find(ismember(month2dayObs,indMonth) & ~isnan(P(:,i)));
                    Ndry(i)=length(find(O(indWetMonth,i)<threshold(3)));
                end
           end
        end
        epsD=zeros(1,Nest);
        for i=1:Nest
            indMonth=find(monthlyP(:,i)>epsM(i));
            if ~isempty(indMonth)
                for j=1:length(indMonth)
                    indWetMonth=find((datesVecObs(:,1)-str2double(dateAggObs(indMonth(j),1:4))).^2+(datesVecObs(:,2)-str2double(dateAggObs(indMonth(j),5:6))).^2==0);
                    indDryMonth=indWetMonth(P(indWetMonth,i)<=epsD(i));
                    if ~isempty(indDryMonth)
                        mi=nansum(P(indDryMonth,i))/(length(indWetMonth)-length(indDryMonth));
                        P(indWetMonth(P(indWetMonth,i)>epsD(i)),i)=P(indWetMonth(P(indWetMonth,i)>epsD(i)),i)+mi;P(indDryMonth,i)=0;
                    end
                end
            end
        end
        [monthlyF,dateAggFor]=aggregateData(F,datesFor,'M','aggFun','nanmean','missing',1);
        for i=1:Nest
            indMonth=find(monthlyF(:,i)>epsM(i));
            if ~isempty(indMonth)
                for j=1:length(indMonth)
                    indWetMonth=find((datesVecFor(:,1)-str2double(dateAggFor(indMonth(j),1:4))).^2+(datesVecFor(:,2)-str2double(dateAggFor(indMonth(j),5:6))).^2==0);
                    indDryMonth=indWetMonth(F(indWetMonth,i)<=epsD(i));
                    if ~isempty(indDryMonth)
                        mi=nansum(F(indDryMonth,i))/(length(indWetMonth)-length(indDryMonth));
                        F(indWetMonth(F(indWetMonth,i)>epsD(i)),i)=F(indWetMonth(F(indWetMonth,i)>epsD(i)),i)+mi;F(indDryMonth,i)=0;
                    end
                end
            end
        end
        wetDaysObs=double(P>repmat(epsD,size(P,1),1) & ~isnan(P)).*double(monthlyP(month2dayObs,:)>repmat(epsM,size(P,1),1)).*double(O>threshold(3) & ~isnan(O)).*double(monthlyO(month2dayObs,:)>threshold(1));
        wetDaysFor=double(F>repmat(epsD,size(F,1),1) & ~isnan(F)).*double(monthlyF(month2dayFor,:)>repmat(epsM,size(F,1),1));
        for i=1:Nest
            auxMonthly=monthlyF(month2dayFor,i);indAuxMonthly=find(auxMonthly>epsM(i));
            F(indAuxMonthly,i)=F(indAuxMonthly,i)./auxMonthly(indAuxMonthly);clear indAuxMonthly auxMonthly
            indAuxMonthly=find(wetDaysObs(:,i)==1);P(indAuxMonthly,i)=P(indAuxMonthly,i)./monthlyP(month2dayObs(indAuxMonthly),i);
            indAuxMonthly=find(wetDaysObs(:,i)==1);O(indAuxMonthly,i)=O(indAuxMonthly,i)./monthlyO(month2dayObs(indAuxMonthly),i);
        end
        for i=1:Nest,
            for j=1:length(months)
                indMonth=find(datesVecObs(:,2)==j & wetDaysObs(:,i)==1);
                try
                    if length(indMonth)>80 && min(nanmean(P(indMonth,i)),nanmean(O(indMonth,i)))>0.01
                        optAdjust=statset('Robust','on');
                        [paramEstsOBS1,rAdjust1,jAdjust1,covbAdjust1,mseAdjust1]=nlinfit(sort(P(indMonth,i)),sort(O(indMonth,i)),@myfun,[rand(1,2) rand(1,1)*(max(P(indMonth,i))-min(P(indMonth,i)))],optAdjust);% [Shape parameter  Scale parameter]
                        [paramEstsOBS2,rAdjust2,jAdjust2,covbAdjust2,mseAdjust2]=nlinfit(sort(P(indMonth,i)),sort(O(indMonth,i)),@myfun,[rand(1,2) rand(1,1)*(max(P(indMonth,i))-min(P(indMonth,i)))],optAdjust);% [Shape parameter  Scale parameter]
                        if min(mseAdjust1,mseAdjust2)<=1e-8
                            [mseAdjust,I1]=min([mseAdjust1;mseAdjust2]);
                            switch I1,
                                case 1,paramEstsOBS=paramEstsOBS1;jAdjust=jAdjust1;
                                case 2,paramEstsOBS=paramEstsOBS2;jAdjust=jAdjust2;
                            end
                            clear paramEstsOBS1 rAdjust1 jAdjust1 covbAdjust1 mseAdjust1 paramEstsOBS2 rAdjust2 jAdjust2 covbAdjust2 mseAdjust2
                            [qAdjust,adjustR]=qr(jAdjust,0);
                            if condest(adjustR)<=1/(eps(class(paramEstsOBS)))^(1/2) && numel(sort(P(indMonth,i)))>numel(paramEstsOBS)
                                F(datesVecFor(:,2)==j & wetDaysFor(:,i)==1,i)=abs(myfun(paramEstsOBS,F(datesVecFor(:,2)==j & wetDaysFor(:,i)==1,i)));
                            end
                        else
                            paramEstsOBS=regress(sort(P(indMonth,i)),[ones(length(indMonth),1) sort(O(indMonth,i))]);% [Shape parameter  Scale parameter]
                            F(datesVecFor(:,2)==j & wetDaysFor(:,i)==1,i)=abs(paramEstsOBS(1)+paramEstsOBS(2)*F(datesVecFor(:,2)==j & wetDaysFor(:,i)==1,i));
                        end
                    end
                end
            end
        end
        for i=1:length(months)
            indMonth=find(datesVecFor(:,2)==monthlyCorrection(i,1));
            for j=1:Nest,
                indMonth1=intersect(indMonth,find(monthlyF(month2dayFor,j)>epsM(j)));
                if ~isempty(indMonth1)
                    F(indMonth1,j)=(F(indMonth1,j).*monthlyF(month2dayFor(indMonth1),j))*monthlyCorrection(i,j+1);
                end
            end
        end
    case {'temperature';'temperatura';'tas'},
        monthlyCorrection=repmat(NaN,length(months),Nest+1);monthlyCorrection(:,1)=months;
        for i=1:length(months),
            indMonth=find(str2num(dateAggObs(:,5:6))==monthlyCorrection(i,1));
            monthlyCorrection(i,2:end)=nanmean(monthlyO(indMonth,:))-nanmean(monthlyP(indMonth,:));
        end
        [monthlyF,dateAggFor]=aggregateData(F,datesFor,'M','aggFun','nanmean','missing',1);
        P=P-monthlyP(month2dayObs,:);O=O-monthlyO(month2dayObs,:);F=F-monthlyF(month2dayFor,:);
        for i=1:Nest
            for j=1:length(months)
                indMonth=find(datesVecObs(:,2)==j);indMonthFor=find(datesVecFor(:,2)==j);
                if ~isnan(nanmean(P(indMonth,i).*(O(indMonth,i))))
                    [b,bInt]=regress(sort(P(indMonth,i)),sort(O(indMonth,i)));F(indMonthFor,i)=b*F(indMonthFor,i);%slopeRegress(i)=b;
                end
            end
        end
        F=F+monthlyF(month2dayFor,:);
        for i=1:length(months),
            indMonth=find(datesVecFor(:,2)==monthlyCorrection(i,1));
            if ~isempty(indMonth)
                F(indMonth,:)=F(indMonth,:)+repmat(monthlyCorrection(i,2:end),length(indMonth),1);
            end
        end
    case {'maximum temperature';'temperatura maxima';'tasmax';'minimum temperature';'temperatura minima';'tasmin'},
		if isempty(Tg),error('Mean temperature is necessary for the correction of the maximum and minimum temperature');end
		tgC=isimip(Tg.O,Tg.P,Tg.F,'variable','tas','datesobs',datesObs,'datesfor',datesFor);
		[daysObs,Idays,Jdays]=unique(datesVecObs(:,2:3),'rows');ndaysObs=size(daysObs,1);
		% k=repmat(NaN,ndaysObs,Nest);
		for nd=1:ndaysObs
			indDaysObs=find(Jdays==nd);
			if ~isempty(indDaysObs)
				% k=nansum(P(indDaysObs,:)-Tg.P(indDaysObs,:))./nansum(O(indDaysObs,:)-Tg.O(indDaysObs,:));
				indDaysFor=find(abs(datesVecFor(:,2)-daysObs(nd,1))+abs(datesVecFor(:,3)-daysObs(nd,2))==0);
				if ~isempty(indDaysFor)
					k=nansum(O(indDaysObs,:)-Tg.O(indDaysObs,:))./nansum(P(indDaysObs,:)-Tg.P(indDaysObs,:));
					F(indDaysFor,:)=repmat(k,size(indDaysFor,1),1).*(F(indDaysFor,:)-Tg.F(indDaysFor,:))+tgC(indDaysFor,:);
					% k(nd,:)=nansum(P(indDaysObs,:)-Tg.P(indDaysObs,:))./nansum(O(indDaysObs,:)-Tg.O(indDaysObs,:));
				end
			end
		end
    case {'uas';'vas';'ua';'va';'eastward wind component';'northward wind component'},
		if isempty(Ws),error('Wind speed is necessary for the correction of the eastward and northward wind component');end
		wsC=isimip(Ws.O,Ws.P,Ws.F,'variable','windspeed','datesobs',datesObs,'datesfor',datesFor);
		indC=find(~isnan(Ws.F) & Ws.F>0);F(indC)=(F(indC).*wsC(indC))./Ws.F(indC);
    case {'prsn';'snowfall';'nieve'},
		if isempty(Pr),error('Precipitation is necessary for the correction of the snowfall');end
		prC=isimip(Pr.O,Pr.P,Pr.F,'variable','precipitation','datesobs',datesObs,'datesfor',datesFor,'threshold', threshold);
		indC=find(~isnan(Pr.F) & Pr.F>0);F(indC)=(F(indC).*prC(indC))./Pr.F(indC);
end

function Y=myfun(p,X)
Y=(p(1)+p(2)*(X-min(X))).*(1-exp(-(X-min(X))/p(3)));
