function indicator=fireIndicator(period,varargin);

% Fire weather indices were developed to help fire prevention and fire fighting; they
% combine meteorological information in order to provide an estimator of fire intensity 
% once a fire has broken out. One of the most widely applied indices is the Canadian Fire
% Weather Index (FWI), based on the the Canadian Forest Fire Danger Rating System established 
% in Canada since 1971 (van Wagner and Pickett, 1987; Stocks et al., 1989). 

% FWI is constructed using four weather inputs: precipitation accumulated over 24 h (pr), 
% and instantaneous temperature (tas), relative humidity (hurs) and wind speed (wss), generally
% taken at noon local standard time (Lawson and Armitage, 2008). 
% Based on these four variables, six standard components are computed. Three of them are known 
% as fuel moisture codes and model daily changes in the moisture content of forest fuels with 
% – The Fine Fuel Moisture Code (FFMC), for litter and other fine fuels.
% – The Duff Moisture Code (DMC), for loosely compacted organic layers and medium-sized woody materials.
% – The Drought Code (DC), an indicator of seasonal drought effects.
% The next two components are related with fire behavior and spread:
% – The Initial Spread Index (ISI), a numeric rating of the expected rate of fire spread.
% – The Buildup Index (BUI), which rates the total amount of fuel available.
% Finally, the FWI is obtained as a combination of the previous parameters, representing the intensity 
% of a spreading fire as energy output rate per unit length of fire front, which is used as a general, 
% daily-based indicator of fire danger. Daily FWI values can then be converted to daily severity rating (DSR), 
% which allows the aggregation of FWI over larger periods of time.
%
%Ref:

% The fireIndicator function estimates the FWI components using the above mentioned variables. 
% The input are:
% 	- period: vector of dates (datenums)
% 	- varagin: optional inputs.
% 		- variables: {'temp';'pr';'wind';'hur'}, ndata x Nest dimensions matrix whit the daily data. 
			% Each row represent an observed day and each column an station or grid point. The data units must be: 
			% ºC for temperature (temp), mm for precipitation (pr), km/h for the windspeed (wind) and 
%			% for the relative humidity.
% 		- names: cell with the index names. The namelist is, following the definition introduced above:
			% {'ffmc';'dmc';'dc';'isi';'bui';'fwi';'dsr'};
% The function returns a string of structures with two field:
		% - Name: string with the name of the index
		% - Index: ndata x Nest dimensions matrix whit the daily data of the index.

nombres=[];
Tg=[];Pr=[];W=[];R=[];Tx=[];tdps=[];
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'names', nombres=varargin{i+1};
		case 'tmean', Tg=varargin{i+1};% ºC
		case 'tmax', Tx=varargin{i+1};% ºC
		case 'tdps', tdps=varargin{i+1};% ºC
		case 'pr', Pr=varargin{i+1};Pr(find(Pr<0))=0;% mm
		case 'wind', W=varargin{i+1};W(find(W<0))=0;% km/h
		case 'hur', R=varargin{i+1};R(find(R<=0))=eps;R(find(R>100))=100;% %
		otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
	end
end
Nindex=length(nombres);
if Nindex<1,
	error('At least an indicator name is necessary');
else
	[ndata,Nest]=size(Pr);
	Le=[6.5,7.5,9,12.8,13.9,13.9,12.4,10.9,9.4,8.0,7,6.0];% Effective length days for DMC
	dlf=[-1.6,-1.6,-1.6,0.9,3.8,5.8,6.4,5.0,2.4,0.4,-1.6,-1.6];% Day length factors for DC 
	for i=1:Nindex
		indicator(i).Name=nombres{i};
		indicator(i).Index=repmat(NaN,ndata,Nest);
	end
	fechas=datevec([datenum(period{1}):datenum(period{2})]');meses=fechas(:,2);clear fechas
	for k=1:Nest
		noVacias=find(nansum(double(isnan([Tg(:,k) Pr(:,k) W(:,k) R(:,k)])),2)==0);
		for j=1:length(noVacias)
			if j==1 | ~ismember(noVacias(j)-1,noVacias)
				% Condiciones iniciales:
				Fo=85;Po=6;Do=15;
			end
			mo=147.2*(101-Fo)/(59.5+Fo);
			ro=Pr(noVacias(j),k);
			if ro>0.5,
				rt=ro-0.5;
				if mo<=150,
					mr=mo+42.5*rt*exp(-100/(251-mo))*(1-exp(-6.93/rt));
				else
					mr=mo+42.5*rt*exp(-100/(251-mo))*(1-exp(-6.93/rt))+(0.0015*(mo-150)^2*sqrt(rt));
				end
				if mr>250,mr=250;end
				mo=mr;
			end
			Ed=0.942*R(noVacias(j),k)^(0.679)+11*exp((R(noVacias(j),k)-100)/10)+0.18*(21.1-Tg(noVacias(j),k))*(1-1/exp(0.115*R(noVacias(j),k)));
			Ew=0.618*R(noVacias(j),k)^(0.753)+10*exp((R(noVacias(j),k)-100)/10)+0.18*(21.1-Tg(noVacias(j),k))*(1-1/exp(0.115*R(noVacias(j),k)));
			if mo>Ed,
				ko=0.424*(1-(R(noVacias(j),k)/100)^1.7)+0.0694*sqrt(W(noVacias(j),k))*(1-(R(noVacias(j),k)/100)^8);
				kd=ko*(0.581*exp(0.0365*Tg(noVacias(j),k)));
				m=Ed+(mo-Ed)*10^(-kd);
			end
			if mo<Ed,
				if mo<Ew
					kl=0.424*(1-((100-R(noVacias(j),k))/100)^1.7)+0.0694*sqrt(W(noVacias(j),k))*(1-((100-R(noVacias(j),k))/100)^8);
					kw=kl*(0.581*exp(0.0365*Tg(noVacias(j),k)));
					m=Ew-(Ew-mo)*(10^(-kw));
				end
			end
			if Ed>=mo & mo>=Ew,m=mo;end
			m=max(m,0);
			Fo=59.5*(250-m)/(147.2+m);
			if ismember({'ffmc'},nombres),indicator(find(ismember(nombres,{'ffmc'}))).Index(noVacias(j),k)=Fo;end
			if Pr(noVacias(j),k)>1.5
				re=0.92*Pr(noVacias(j),k)-1.27;
				Mo=20+exp(5.6348-Po/43.43);
				if Po<=33
					b=100/(0.5+0.3*Po);
				elseif Po<=65
					b=14-1.3*log(Po);
				else
					b=6.2*log(Po)-17.2;
				end
				Mr=Mo+1000*re/(48.77+b*re);
				Po=max(244.72-43.43*log(Mr-20),0);
			end
			K=1.894*(max(Tg(noVacias(j),k),-1.1)+1.1)*((100-R(noVacias(j),k))*Le(meses(noVacias(j))))*10^(-6);
			Po=Po+100*K;
			if ismember({'dmc'},nombres),indicator(find(ismember(nombres,{'dmc'}))).Index(noVacias(j),k)=Po;end
			if Pr(noVacias(j),k)>2.8
				rd=0.83*Pr(noVacias(j),k)-1.27;
				Qo=800*exp(-Do/400);Qr=Qo+3.937*rd;
				Do=max(400*log(800*(Qr^(-1))),0);
			end
			V=max(0.36*(max(Tg(noVacias(j),k),-2.8)+2.8)+dlf(meses(noVacias(j))),0);
			Do=Do+0.5*V;
			if ismember({'dc'},nombres),indicator(find(ismember(nombres,{'dc'}))).Index(noVacias(j),k)=Do;end
			fF=91.9*exp(-0.1386*m)*(1+(m^5.31)/(4.93*10^7));ISI=0.208*exp(0.05039*W(noVacias(j),k))*fF;
			if ismember({'isi'},nombres),indicator(find(ismember(nombres,{'isi'}))).Index(noVacias(j),k)=ISI;end
			if Po<=0.4*Do
				BUI=0.8*(Po*Do)/(Po+0.4*Do);
			else
				BUI=Po-(1-0.8*Do/(Po+0.4*Do))*(0.92+(0.0114*Po)^(1.7));
			end
			if ismember({'bui'},nombres),indicator(find(ismember(nombres,{'bui'}))).Index(noVacias(j),k)=BUI;end
			if BUI<=80
				fD=0.626*BUI+2;
			else
				fD=1000/(25+108.64*exp(-0.023*BUI));
			end
			B=0.1*(ISI.*fD);
			if B>1,FWI=exp(2.72*(0.434*log(B))^0.647);else,FWI=B;end
			if ismember({'fwi'},nombres),indicator(find(ismember(nombres,{'fwi'}))).Index(noVacias(j),k)=FWI;end
			DSR=0.0272*FWI.^1.77;
			if ismember({'dsr'},nombres),indicator(find(ismember(nombres,{'dsr'}))).Index(noVacias(j),k)=0.0272*FWI.^1.77;end
		end
	end
end
