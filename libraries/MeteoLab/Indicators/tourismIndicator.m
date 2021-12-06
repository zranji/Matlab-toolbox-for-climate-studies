function indicator=tourismIndicator(varargin);

% This function estimates several tourism index. 
% The input are:
% 	- period: vector of dates (datenums)
% 	- varagin: optional inputs.
% 		- variables: {'Tx';'Tg';'Pr';'Ss';'W';'Rn';'Rg';'T';'Cc'}, ndata x Nest dimensions matrix whit the daily data. Each row represent an observed day and
%		each column an station or grid point. The data units must be: ºC for temperature (Tx,Tn,Tg,T), mm for precipitation (Pr), hours for sunshine (Ss), 
% 		(%) for humidity (Rg and Rn), (m/s) for wind (W) and (%) for cloud cover (Cc).
% 		- names: cell with the index names. The namelist is: {'tci';'cid';'cia';'windchill';'hi';'hci'}
% Example:
% indicator=tourismIndicator('Tx',Tx,'Tg',Tg,'Pr',Pr,'Ss',Ss,'W',W,'Rn',Rg,'Rg',Rg,'names',{'tci';'cid';'cia';'windchill'});
nombres=[];Tx=[];Tg=[];Pr=[];Ss=[];Rn=[];Rg=[];T=[];R=[];W=[];Cc=[];
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'names', nombres=varargin{i+1};
        case 'tx', Tx=varargin{i+1};
        case 't', T=varargin{i+1};
        case 'tg', Tg=varargin{i+1};
        case 'pr', Pr=varargin{i+1};
        case 'ss', Ss=varargin{i+1};
        case 'rn', Rn=varargin{i+1};
        case 'rg', Rg=varargin{i+1};
        case 'r', R=varargin{i+1};
        case 'w', W=varargin{i+1};
        case 'cc', Cc=varargin{i+1};
        otherwise, warning(sprintf('Unknown option: %s (ignored)',varargin{i}));
    end
end

Nindex=length(nombres);
if Nindex<1
	error('At least an indicator name is necessary')
end
% Transformamos las variables a las unidades correctas: W m/s -> km/h
W=W*10/36;
hiCoeficients=[-42.379;2.04901523;10.14333127;-0.22475541;-6.83783*10^(-3);-5.481717*10^(-2);1.22874*10^(-3);8.5282*10^(-4);-1.99*10^(-6)];
for i=1:Nindex
	indicator(i).Name=nombres{i};
	switch lower(nombres{i})
		case 'hi'
			[ndata,Nest]=size(T);
			indicator(i).Index=hiCoeficients(1)+hiCoeficients(2)*(T*9/5+32)+hiCoeficients(3)*R+...
				+hiCoeficients(4)*((T*9/5+32).*R)+hiCoeficients(5)*(T*9/5+32).^2+hiCoeficients(6)*(R.^2)+...
				+hiCoeficients(7)*(((T*9/5+32).^2).*R)+hiCoeficients(8)*((T*9/5+32).*(R.^2))+hiCoeficients(9)*((T*9/5+32).^2).*(R.^2);
			indicator(i).Index=(indicator(i).Index-32)*5/9;% Pasamos los datos a Celsius
		case 'cid'
			[ndata,Nest]=size(Tx);
			indicator(i).Index=hiCoeficients(1)+hiCoeficients(2)*(Tx*9/5+32)+hiCoeficients(3)*Rn+...
				+hiCoeficients(4)*((Tx*9/5+32).*Rn)+hiCoeficients(5)*(Tx*9/5+32).^2+hiCoeficients(6)*(Rn.^2)+...
				+hiCoeficients(7)*(((Tx*9/5+32).^2).*Rn)+hiCoeficients(8)*((Tx*9/5+32).*(Rn.^2))+hiCoeficients(9)*((Tx*9/5+32).^2).*(Rn.^2);
			indicator(i).Index=(indicator(i).Index-32)*5/9;% Pasamos los datos a Celsius
		case 'cia'
			[ndata,Nest]=size(Tg);
			indicator(i).Index=hiCoeficients(1)+hiCoeficients(2)*(Tg*9/5+32)+hiCoeficients(3)*Rg+...
				+hiCoeficients(4)*((Tg*9/5+32).*Rg)+hiCoeficients(5)*(Tg*9/5+32).^2+hiCoeficients(6)*(Rg.^2)+...
				+hiCoeficients(7)*(((Tg*9/5+32).^2).*Rg)+hiCoeficients(8)*((Tg*9/5+32).*(Rg.^2))+hiCoeficients(9)*((Tg*9/5+32).^2).*(Rg.^2);
			indicator(i).Index=(indicator(i).Index-32)*5/9;% Pasamos los datos a Celsius
		case 'windchill'
			[ndata,Nest]=size(Tg);
			indicator(i).Index=13.12+0.6215*Tg-11.37*W.^(0.16)+0.3965*Tg.*(W.^(0.16));% Tg en celsius y W en km/h
		case 'tci'
			[ndata,Nest]=size(Tg);
			cid=hiCoeficients(1)+hiCoeficients(2)*(Tx*9/5+32)+hiCoeficients(3)*Rn+...
				+hiCoeficients(4)*((Tx*9/5+32).*Rn)+hiCoeficients(5)*(Tx*9/5+32).^2+hiCoeficients(6)*(Rn.^2)+...
				+hiCoeficients(7)*(((Tx*9/5+32).^2).*Rn)+hiCoeficients(8)*((Tx*9/5+32).*(Rn.^2))+hiCoeficients(9)*((Tx*9/5+32).^2).*(Rn.^2);
			cid=(cid-32)*5/9;% Pasamos los datos a Celsius
			% Discretizamos en las clases del TCI
			assignedInd=find(cid>=20 & cid<=27);cid(assignedInd)=5;
			ind=setdiff(union(find(cid>=19 & cid<20),find(cid>27 & cid<=28)),assignedInd);if ~isempty(ind),cid(ind)=4.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=18 & cid<19),find(cid>28 & cid<=29)),assignedInd);if ~isempty(ind),cid(ind)=4.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=17 & cid<18),find(cid>29 & cid<=30)),assignedInd);if ~isempty(ind),cid(ind)=3.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=15 & cid<17),find(cid>30 & cid<=31)),assignedInd);if ~isempty(ind),cid(ind)=3.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=10 & cid<15),find(cid>31 & cid<=32)),assignedInd);if ~isempty(ind),cid(ind)=2.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=5 & cid<10),find(cid>32 & cid<=33)),assignedInd);if ~isempty(ind),cid(ind)=2.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=0 & cid<5),find(cid>33 & cid<=34)),assignedInd);if ~isempty(ind),cid(ind)=1.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=-5 & cid<0),find(cid>34 & cid<=35)),assignedInd);if ~isempty(ind),cid(ind)=1.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid>35 & cid<=36),assignedInd);if ~isempty(ind),cid(ind)=0.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid>=-10 & cid<-5),assignedInd);if ~isempty(ind),cid(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid>=-15 & cid<-10),assignedInd);if ~isempty(ind),cid(ind)=-1.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid>=-20 & cid<-15),assignedInd);if ~isempty(ind),cid(ind)=-2.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid<-20),assignedInd);if ~isempty(ind),cid(ind)=-3.0;assignedInd=union(assignedInd,ind);clear ind,end
            cid(setdiff([1:size(cid,1)*size(cid,2)],assignedInd))=0;
			cia=hiCoeficients(1)+hiCoeficients(2)*(Tg*9/5+32)+hiCoeficients(3)*Rg+...
				+hiCoeficients(4)*((Tg*9/5+32).*Rg)+hiCoeficients(5)*(Tg*9/5+32).^2+hiCoeficients(6)*(Rg.^2)+...
				+hiCoeficients(7)*(((Tg*9/5+32).^2).*Rg)+hiCoeficients(8)*((Tg*9/5+32).*(Rg.^2))+hiCoeficients(9)*((Tg*9/5+32).^2).*(Rg.^2);
			cia=(cia-32)*5/9;% Pasamos los datos a Celsius
			% Discretizamos en las clases del TCI
			assignedInd=find(cia>=20 & cia<=27);cia(assignedInd)=5;
			ind=setdiff(union(find(cia>=19 & cia<20),find(cia>27 & cia<=28)),assignedInd);if ~isempty(ind),cia(ind)=4.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cia>=18 & cia<19),find(cia>28 & cia<=29)),assignedInd);if ~isempty(ind),cia(ind)=4.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cia>=17 & cia<18),find(cia>29 & cia<=30)),assignedInd);if ~isempty(ind),cia(ind)=3.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cia>=15 & cia<17),find(cia>30 & cia<=31)),assignedInd);if ~isempty(ind),cia(ind)=3.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cia>=10 & cia<15),find(cia>31 & cia<=32)),assignedInd);if ~isempty(ind),cia(ind)=2.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cia>=5 & cia<10),find(cia>32 & cia<=33)),assignedInd);if ~isempty(ind),cia(ind)=2.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cia>=0 & cia<5),find(cia>33 & cia<=34)),assignedInd);if ~isempty(ind),cia(ind)=1.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cia>=-5 & cia<0),find(cia>34 & cia<=35)),assignedInd);if ~isempty(ind),cia(ind)=1.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cia>35 & cia<=36),assignedInd);if ~isempty(ind),cia(ind)=0.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cia>=-10 & cia<-5),assignedInd);if ~isempty(ind),cia(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cia>=-15 & cia<-10),assignedInd);if ~isempty(ind),cia(ind)=-1.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cia>=-20 & cia<-15),assignedInd);if ~isempty(ind),cia(ind)=-2.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cia<-20),assignedInd);if ~isempty(ind),cia(ind)=-3.0;assignedInd=union(assignedInd,ind);clear ind,end
            cia(setdiff([1:size(cia,1)*size(cia,2)],assignedInd))=0;
			% Discretizamos la precipitacion en las clases del TCI
			assignedInd=find(Pr>=0 & Pr<=14.9);Pr(assignedInd)=5;
			ind=setdiff(find(Pr>=15 & Pr<30),assignedInd);if ~isempty(ind),Pr(ind)=4.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>=30 & Pr<45),assignedInd);if ~isempty(ind),Pr(ind)=4.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>=45 & Pr<60),assignedInd);if ~isempty(ind),Pr(ind)=3.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>=60 & Pr<75),assignedInd);if ~isempty(ind),Pr(ind)=3.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>=75 & Pr<90),assignedInd);if ~isempty(ind),Pr(ind)=2.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>=90 & Pr<105),assignedInd);if ~isempty(ind),Pr(ind)=2.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>=105 & Pr<120),assignedInd);if ~isempty(ind),Pr(ind)=1.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>=120 & Pr<135),assignedInd);if ~isempty(ind),Pr(ind)=1.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>135 & Pr<=150),assignedInd);if ~isempty(ind),Pr(ind)=0.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>150),assignedInd);if ~isempty(ind),Pr(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end
			% Discretizamos las horas de sol en las clases del TCI
			assignedInd=find(Ss>10);Ss(assignedInd)=5;
			ind=setdiff(find(Ss>9 & Ss<=10),assignedInd);if ~isempty(ind),Ss(ind)=4.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss>8 & Ss<=9),assignedInd);if ~isempty(ind),Ss(ind)=4.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss>7 & Ss<=8),assignedInd);if ~isempty(ind),Ss(ind)=3.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss>6 & Ss<=7),assignedInd);if ~isempty(ind),Ss(ind)=3.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss>5 & Ss<=6),assignedInd);if ~isempty(ind),Ss(ind)=2.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss>4 & Ss<=5),assignedInd);if ~isempty(ind),Ss(ind)=2.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss>3 & Ss<=4),assignedInd);if ~isempty(ind),Ss(ind)=1.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss>2 & Ss<=3),assignedInd);if ~isempty(ind),Ss(ind)=1.0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss>=1 & Ss<=2),assignedInd);if ~isempty(ind),Ss(ind)=0.5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Ss<1),assignedInd);if ~isempty(ind),Ss(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end
			% Discretizamos el viento:
			assignedInd=[];indWC=find(Tx<15 & W>8);
			if ~isempty(indWC)
				% Discretizamos el viento en las clases del TCI: Wind Chill (Tx<15 & W>8km/h)
				Twc=13.12+0.6215*Tg-11.37*W.^(0.16)+0.3965*Tg.*(W.^(0.16));% Tg en celsius y W en km/h
				ind=intersect(find(Twc<500),indWC);if ~isempty(ind),W(ind)=4;assignedInd=union(assignedInd,ind);clear ind,end,
				ind=setdiff(intersect(find(Twc>=500 & Twc<625),indWC),assignedInd);if ~isempty(ind),W(ind)=3;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(Twc>=625 & Twc<750),indWC),assignedInd);if ~isempty(ind),W(ind)=2;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(Twc>=750 & Twc<875),indWC),assignedInd);if ~isempty(ind),W(ind)=1.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(Twc>=875 & Twc<1000),indWC),assignedInd);if ~isempty(ind),W(ind)=1.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(Twc>=1000 & Twc<1125),indWC),assignedInd);if ~isempty(ind),W(ind)=0.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(Twc>=1125 & Twc<=1250),indWC),assignedInd);if ~isempty(ind),W(ind)=0.25;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(Twc>1250),indWC),assignedInd);if ~isempty(ind),W(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end
			end
			indWC=union(find(Tx>=15 & Tx<=24),find(Tx<5 & W<=8));
			if ~isempty(indWC)
				% Discretizamos el viento en las clases del TCI: Normal (Tx>=15 & Tx<=24) & (Tx<15 & W<=8km/h)
				ind=intersect(find(W<2.88),indWC);if ~isempty(ind),W(ind)=5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=2.88 & W<5.75),indWC),assignedInd);if ~isempty(ind),W(ind)=4.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=5.75 & W<9.03),indWC),assignedInd);if ~isempty(ind),W(ind)=4.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=9.03 & W<12.23),indWC),assignedInd);if ~isempty(ind),W(ind)=3.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=12.23 & W<19.79),indWC),assignedInd);if ~isempty(ind),W(ind)=3.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=19.79 & W<24.29),indWC),assignedInd);if ~isempty(ind),W(ind)=2.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=24.29 & W<28.79),indWC),assignedInd);if ~isempty(ind),W(ind)=2.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=28.79 & W<=38.52),indWC),assignedInd);if ~isempty(ind),W(ind)=1.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>38.52),indWC),assignedInd);if ~isempty(ind),W(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end
			end
			indWC=find(Tx>24 & Tx<=33);
			if ~isempty(indWC)
				% Discretizamos el viento en las clases del TCI: Trade wind (Tx>24 & Tx<=33)
				ind=intersect(find(W>=12.24 & W<=19.79),indWC);if ~isempty(ind),W(ind)=5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(union(find(W>19.79 & W<=24.29),find(W>=9.04 & W<12.14)),indWC),assignedInd);if ~isempty(ind),W(ind)=4.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(union(find(W>24.29 & W<=28.79),find(W>=5.76 & W<9.04)),indWC),assignedInd);if ~isempty(ind),W(ind)=3.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=2.88 & W<5.76),indWC),assignedInd);if ~isempty(ind),W(ind)=2.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(union(find(W>28.79 & W<=38.52),find(W<2.88)),indWC),assignedInd);if ~isempty(ind),W(ind)=2.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>38.52),indWC),assignedInd);if ~isempty(ind),W(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end
			end
			indWC=find(Tx>33);
			if ~isempty(indWC)
				% Discretizamos el viento en las clases del TCI: Hot climate (Tx>33)
				ind=intersect(find(W<2.88),indWC);if ~isempty(ind),W(ind)=2;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>=2.88 & W<=5.75),indWC),assignedInd);if ~isempty(ind),W(ind)=1.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>5.75 & W<=9.03),indWC),assignedInd);if ~isempty(ind),W(ind)=1.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>9.03 & W<=12.23),indWC),assignedInd);if ~isempty(ind),W(ind)=0.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(intersect(find(W>12.23),indWC),assignedInd);if ~isempty(ind),W(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end
			end
			indicator(i).Index=8*cid+2*cia+4*Pr+4*Ss+2*W;
		case 'hci'
			[ndata,Nest]=size(Tx);
			cid=hiCoeficients(1)+hiCoeficients(2)*(Tx*9/5+32)+hiCoeficients(3)*Rn+...
				+hiCoeficients(4)*((Tx*9/5+32).*Rn)+hiCoeficients(5)*(Tx*9/5+32).^2+hiCoeficients(6)*(Rn.^2)+...
				+hiCoeficients(7)*(((Tx*9/5+32).^2).*Rn)+hiCoeficients(8)*((Tx*9/5+32).*(Rn.^2))+hiCoeficients(9)*((Tx*9/5+32).^2).*(Rn.^2);
			cid=(cid-32)*5/9;% Pasamos los datos a Celsius
			% Discretizamos en las clases del HCI
			ind=setdiff(find(cid>=22 & cid<=26),assignedInd);if ~isempty(ind),cid(ind)=10;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=19 & cid<22),find(cid>26 & cid<=27)),assignedInd);if ~isempty(ind),cid(ind)=9;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid>27 & cid<=29),assignedInd);if ~isempty(ind),cid(ind)=8;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=17 & cid<19),find(cid>29 & cid<=31)),assignedInd);if ~isempty(ind),cid(ind)=7;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=14 & cid<17),find(cid>31 & cid<=33)),assignedInd);if ~isempty(ind),cid(ind)=6;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=10 & cid<14),find(cid>33 & cid<=35)),assignedInd);if ~isempty(ind),cid(ind)=5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=6 & cid<10),find(cid>35 & cid<=37)),assignedInd);if ~isempty(ind),cid(ind)=4;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid>=-1 & cid<6),assignedInd);if ~isempty(ind),cid(ind)=3;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(cid>=-5 & cid<-1),find(cid>37 & cid<=39)),assignedInd);if ~isempty(ind),cid(ind)=2;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid<-5),assignedInd);if ~isempty(ind),cid(ind)=1;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(cid>39),assignedInd);if ~isempty(ind),cid(ind)=0;assignedInd=union(assignedInd,ind);clear ind,end
            cid(setdiff([1:size(cid,1)*size(cid,2)],assignedInd))=0;
			% Discretizamos la precipitacion en las clases del HCI
			assignedInd=find(Pr<=0);Pr(assignedInd)=10;
			ind=setdiff(find(Pr>0 & Pr<3),assignedInd);if ~isempty(ind),Pr(ind)=9;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>=3 & Pr<=6),assignedInd);if ~isempty(ind),Pr(ind)=8;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>6 & Pr<=8),assignedInd);if ~isempty(ind),Pr(ind)=5;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>8 & Pr<=12),assignedInd);if ~isempty(ind),Pr(ind)=2;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>12 & Pr<=25),assignedInd);if ~isempty(ind),Pr(ind)=0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(Pr>25),assignedInd);if ~isempty(ind),Pr(ind)=-1;assignedInd=union(assignedInd,ind);clear ind,end
			% Discretizamos la nubosidad en las clases del HCI
			if ~isempty(Cc)
				assignedInd=find(Cc>10 & Cc<=20);Cc(assignedInd)=10;
				ind=setdiff(union(find(Cc>1 & Cc<=10),find(Cc>20 & Cc<=30))assignedInd);if ~isempty(ind),Cc(ind)=9;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(union(find(Cc>=0 & Cc<=1),find(Cc>30 & Cc<=40))assignedInd);if ~isempty(ind),Cc(ind)=8;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>40 & Cc<=50),assignedInd);if ~isempty(ind),Cc(ind)=7;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>50 & Cc<=60),assignedInd);if ~isempty(ind),Cc(ind)=6;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>60 & Cc<=70),assignedInd);if ~isempty(ind),Cc(ind)=5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>70 & Cc<=80),assignedInd);if ~isempty(ind),Cc(ind)=4;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>80 & Cc<=90),assignedInd);if ~isempty(ind),Cc(ind)=3;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>90),assignedInd);if ~isempty(ind),Cc(ind)=2;assignedInd=union(assignedInd,ind);clear ind,end
			elseif ~isempty(Ss);
				Cc=Ss;clear Ss;
				assignedInd=find(Cc>10);Cc(assignedInd)=5;
				ind=setdiff(find(Cc>9 & Cc<=10),assignedInd);if ~isempty(ind),Cc(ind)=4.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>8 & Cc<=9),assignedInd);if ~isempty(ind),Cc(ind)=4.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>7 & Cc<=8),assignedInd);if ~isempty(ind),Cc(ind)=3.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>6 & Cc<=7),assignedInd);if ~isempty(ind),Cc(ind)=3.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>5 & Cc<=6),assignedInd);if ~isempty(ind),Cc(ind)=2.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>4 & Cc<=5),assignedInd);if ~isempty(ind),Cc(ind)=2.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>3 & Cc<=4),assignedInd);if ~isempty(ind),Cc(ind)=1.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>2 & Cc<=3),assignedInd);if ~isempty(ind),Cc(ind)=1.0;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc>=1 & Cc<=2),assignedInd);if ~isempty(ind),Cc(ind)=0.5;assignedInd=union(assignedInd,ind);clear ind,end
				ind=setdiff(find(Cc<1),assignedInd);if ~isempty(ind),Cc(ind)=0.0;assignedInd=union(assignedInd,ind);clear ind,end;Cc=2*Cc;
			end
			% Discretizamos el viento:
			assignedInd=find(W>=1 & W<=10);W(assignedInd)=10;
			ind=setdiff(find(W>10 & W<=20),assignedInd);if ~isempty(ind),W(ind)=9;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(union(find(W>20 & W<=30),find(W>=0 & W<1))assignedInd);if ~isempty(ind),W(ind)=8;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(W>30 & W<=40),assignedInd);if ~isempty(ind),W(ind)=6;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(W>40 & W<=50),assignedInd);if ~isempty(ind),W(ind)=3;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(W>50 & W<=70),assignedInd);if ~isempty(ind),W(ind)=0;assignedInd=union(assignedInd,ind);clear ind,end
			ind=setdiff(find(W>70),assignedInd);if ~isempty(ind),W(ind)=-10;assignedInd=union(assignedInd,ind);clear ind,end
			indicator(i).Index=4*cid+2*Cc+(3*Pr+W);
	end
	disp(indicator(i).Name)
end
