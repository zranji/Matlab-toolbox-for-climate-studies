function dmn=readDomain(fic,tableFile)
%dmn=readDomain(fic)
%
%Funcion que lee los ficheros .cfg definidos en areaPattern con los que se han generado las CPs
%
%En la entrada:
%	fic	:	nombre con ruta completa del fichero que se quiere leer
%
%En la salida:
%	dmn	:	estructura con los campos
%		lon	:	longitud (en grados) de cada uno de los nodos que definen el dominio
%		lat	:	latitud (en grados) de cada uno de los nodos que definen el dominio
%		lvl	: 	niveles de presion (en mb) utilizados
%		tim	:	horas de analisis	utilizadas
%		par	:	variables empleadas (en numeros, por ejemplo 129 es geopotencial
%		nod	:	nodos del dominio que se utilizan	
%		src	:	ruta del lugar donde se almacenan los datos originales (en .grb)
%		startDate	:	fecha de inicio de los datos
%		endDate		:	fecha de fin de los datos
%		step		:	step
%

%Preguntamas por la ruta a la red de datos definida
datCam=getZonePath(fic);
d=dir(datCam);
if(length(d)>1)
    [A,B]=textread([datCam '/domain.cfg'],'%s%s','delimiter','=','commentstyle','shell');
elseif(length(d)==1 && d(1).isdir==0)
    [A,B]=textread([datCam],'%s%s','delimiter','=','commentstyle','shell');
end    

dmn=struct('lon',[],'lat',[],'lvl',[],'tim',[],'par',[],'nod',[],'src',[],'startDate',[],'endDate',[],'step','24:00','path',[],'format','grib');

for i=1:length(A)
    fld=A{i};
    t=B{i};
    if(~isfield(dmn,fld))
        error([fld ' : isn''t a parameter']);
    end
    if strcmp('lop',fld)
        if(~isfield(dmn,fld))
            error([t ' : isn''t a parameter']);
        end
        dmn=setfield(dmn,fld,[getfield(dmn,fld);t]);
    elseif (strcmp('startDate',fld) | strcmp('endDate',fld) | strcmp('step',fld)) 
        dmn=setfield(dmn,fld,t);
    elseif(strcmp('src',fld))
        %METEOLAB=getappdata(0,'METEOLAB');
        METEOLAB=getMETEOLAB;
        path = strrep(t,'$METEOLAB_HOME',METEOLAB.home);
        if isfield(METEOLAB,'ENSEMBLES_HOME')
            path = strrep(t,'$ENSEMBLES_HOME',METEOLAB.ENSEMBLES_HOME);
        end
        path=strrep(path,'\','/');
        dmn=setfield(dmn,fld,path);
    elseif(strcmp('par',fld))
        C2={};
        C1=strread(t,'%q','delimiter',';','endofline',';','commentstyle','shell');
        for iC=1:length(C1)
            C2(iC,:)=strread(C1{iC},'%q','delimiter',','); 
        end
        if isempty(getfield(dmn,fld))
            dmn=setfield(dmn,fld,C2);
        else
            dmn=setfield(dmn,fld,[getfield(dmn,fld);C2]);
        end
    elseif(strcmp('tim',fld))
		if ~isempty(str2num(t))
			t=str2num(t);
        else
            sd=union(findstr(';',t),findstr(',',t));
            nt=length(sd)+1;sd=[0 sd length(t)+1];t1=cell(nt,1);
            for it=1:nt
                aux=t(sd(it)+1:sd(it+1)-1);
                if ~isempty(str2num(aux)),aux=str2num(aux);end
                t1{it}=aux;
            end
            t=t1;clear t1
		end
		if isempty(getfield(dmn,fld))
			dmn=setfield(dmn,fld,t(:));
		else
			dmn=setfield(dmn,fld,[getfield(dmn,fld);t(:)]);
		end
	else
        if isempty(getfield(dmn,fld))
            dmn=setfield(dmn,fld,str2num(t));
		else
            dmn=setfield(dmn,fld,[getfield(dmn,fld);str2num(t)]);
        end
    end
end
dmn.path=[datCam '/'];
if nargin<2
    tableFile=[dmn.src 'Table.txt'];
    d=dir(tableFile);
    if isempty(d)
        %warning(sprintf('Table file %s not found \n\tno translation is been made\n',tableFile));
        dmn=parseDomain(dmn);
    else
        dmn=parseDomain(dmn,tableFile);
    end
else
    d=dir(tableFile);
    if isempty(d)
        error(sprintf('Table file %s not found \n',tableFile));    
    else
        dmn=parseDomain(dmn,tableFile);
    end
end

