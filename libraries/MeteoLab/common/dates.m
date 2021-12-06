function y=dates(struct)

Ini=datenum(struct.StartDate);
Fin=datenum(struct.EndDate);
try
    paso=datenum(struct.Block);
    pasos={'24:00';'01:00';'00:01';'00:00:01'};
    escalas=[datenum('24:00') datenum('01:00') datenum('00:01') datenum('00:00:01')];
    aux=find(mod(paso,escalas)==0);
    [bloque,n]=min(paso./escalas(aux));
    n=aux(n);
    y1=datenum2(struct.StartDate,pasos{n});
    y2=datenum2(struct.EndDate,pasos{n});
    y=zeros(y2-y1+1,6);
    y(:,n+2)=[y1:y2]';
    if n+2<6
        yy=datevec(Ini);
        y(:,n+3:6)=repmat(yy(n+3:6),y2-y1+1,1);
    end
    y=datenum(y);
    y=y(1:struct.StepDate:end);
catch
    paso=struct.Block;
    escala=paso(end);
    step=struct.StepDate;
    bloque=str2num(paso(1:end-1));
    switch(escala)
        case('s')
            n=6;
            paso='00:00:01';
            y1=datenum2(struct.StartDate,paso);
            y2=datenum2(struct.EndDate,paso);
            y=zeros(y2-y1+1,6);
            y(:,n)=[y1:y2]';
            y=datenum(y);
            y=y(1:struct.StepDate:end);
        case('m')
            n=5;
            paso='00:01';
            y1=datenum2(struct.StartDate,paso);
            y2=datenum2(struct.EndDate,paso);
            y=zeros(y2-y1+1,6);
            y(:,n)=[y1:y2]';
            y=datenum(y);
            y=y(1:struct.StepDate:end);
        case('h')
            n=4;
            paso='01:00';
			[yini,mini,dini,hini,minini,sini]=datevec(Ini);
            % yini=year(Ini);mini=month(Ini);dini=day(Ini);
            % hini=hour(Ini);minini=minute(Ini);sini=second(Ini);
			[yfin,mfin,dfin,hfin,minfin,sfin]=datevec(Fin);
            % yfin=year(Fin);mfin=month(Fin);dfin=day(Fin);hfin=hour(Fin);
            y1=datenum2(struct.StartDate,paso);
            y2=datenum2(struct.EndDate,paso);
            y=zeros(y2-y1+1,6);
            y(:,1)=yini;y(:,2)=mini;y(:,3)=dini;y(:,5)=minini;y(:,6)=sini;
            y(:,4)=hini+[0:y2-y1]';
            y=datenum(y(1:struct.StepDate:end,:));
            y=y(1:max(find(y<=Fin)));
        case('D')
            n=3;
            paso='24:00';
			[yini,mini,dini,hini,minini,sini]=datevec(Ini);
            % yini=year(Ini);mini=month(Ini);dini=day(Ini);
            % hini=hour(Ini);minini=minute(Ini);sini=second(Ini);
			[yfin,mfin,dfin,hfin,minfin,sfin]=datevec(Fin);
            % yfin=year(Fin);mfin=month(Fin);dfin=day(Fin);hfin=hour(Fin);
            y1=datenum2(struct.StartDate,paso);
            y2=datenum2(struct.EndDate,paso);
            y=zeros(y2-y1+1,6);
            y(:,1)=yini;y(:,2)=mini;y(:,4)=hini;y(:,5)=minini;y(:,6)=sini;
            y(:,3)=dini+[0:y2-y1]';
            y=datenum(y(1:struct.StepDate:end,:));
            y=y(1:max(find(y<=Fin)));
        case('M')
			[yini,mini,dini,hini,minini,sini]=datevec(Ini);
            % yini=year(Ini);mini=month(Ini);dini=day(Ini);
            % hini=hour(Ini);minini=minute(Ini);sini=second(Ini);
			[yfin,mfin,dfin,hfin,minfin,sfin]=datevec(Fin);
            % yfin=year(Fin);mfin=month(Fin);dfin=day(Fin);hfin=hour(Fin);
            y=zeros(13-mini+12*(yfin-yini-1)+mfin,6);
            y(:,1)=yini;
            y(:,2)=mini+[0:12-mini+12*(yfin-yini-1)+mfin]';
            y(:,3)=dini;y(:,4)=hini;y(:,5)=minini;y(:,6)=sini;
            y=datenum(y(1:struct.StepDate:end,:));
            y=y(1:max(find(y<=Fin)));
        case('Y')
			[yini,mini,dini,hini,minini,sini]=datevec(Ini);
            % yini=year(Ini);mini=month(Ini);dini=day(Ini);
            % hini=hour(Ini);minini=minute(Ini);sini=second(Ini);
			[yfin,mfin,dfin,hfin,minfin,sfin]=datevec(Fin);
            % yfin=year(Fin);mfin=month(Fin);dfin=day(Fin);hfin=hour(Fin);
            y=zeros(yfin-yini+1,6);
            y(:,1)=[yini:yfin]';
            y(:,2)=mini;y(:,3)=dini;y(:,4)=hini;y(:,5)=minini;y(:,6)=sini;
            y=datenum(y(1:struct.StepDate:end,:));
            y=y(1:max(find(y<=Fin)));
    end
end
