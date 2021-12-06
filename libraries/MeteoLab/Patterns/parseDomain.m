function dmn1=parseDomain(dmn,fileTable,CONVERTTOGRIB)

if nargin<2
    varTable=[];
else
	texto=textread(fileTable,'%[^\n]',1);
	if isempty(strmatch('#!',texto))
		version=1;
		[varTable.Id,varTable.Label,varTable.Unit,varTable.Code]=textread(	fileTable,'%q%q%q%q%*[^\n]','delimiter',',','commentstyle','shell');
		if all(strcmp('',varTable.Code))
			varTable.Code=varTable.Unit;
			varTable.Unit(:)={''};
		end 
		varTable.Offset=repmat({'0'},size(varTable.Id));
		varTable.Scale=repmat({'1'},size(varTable.Id));		
		varTable.Minimum=repmat({''},size(varTable.Id));
		varTable.Maximum=repmat({''},size(varTable.Id));		
	else
		version=2;
		% [varTable.Id,varTable.Code,varTable.Offset,varTable.Scale]=textread(fileTable,'%q%q%q%q%*[^\n]','delimiter',',','commentstyle','shell');
		[varTable.Id,varTable.Code,varTable.Offset,varTable.Scale,varTable.Minimum,varTable.Maximum]=textread(fileTable,'%q%q%q%q%q%q%*[^\n]','delimiter',',','commentstyle','shell');
		METEOLAB=getMETEOLAB;
        try
            [metTable.Code,metTable.Label,metTable.Unit,metTable.aggregation,metTable.metadata]=textread([METEOLAB.home '/../ModelData/Table.txt'],'%q%q%q%q%[^\n]','delimiter',',','commentstyle','shell');
        catch
            [metTable.Code,metTable.Label,metTable.Unit,metTable.aggregation,metTable.metadata]=textread([METEOLAB.home '/../GCMData/Table.txt'],'%q%q%q%q%[^\n]','delimiter',',','commentstyle','shell');
        end
        [A,I1,I2]=intersect(deblank(metTable.Code),deblank(varTable.Code));
		varTable.Id=varTable.Id(I2);
		varTable.Label=metTable.Label(I1);
		varTable.Code=metTable.Code(I1);
		varTable.Unit=metTable.Unit(I1);
		varTable.Offset=varTable.Offset(I2);
		varTable.Scale=varTable.Scale(I2);
		varTable.Minimum=varTable.Minimum(I2);
		varTable.Maximum=varTable.Maximum(I2);
	end
end

if nargin<3
    CONVERTTOGRIB=0;
end
np=size(dmn.par,2);
if ~isfield(dmn,'tim') 
    dmn.tim=[];
end
if ~isfield(dmn,'lvl') 
    dmn.lvl=[];
end

% nt=size(dmn.tim,2);
nt=size(dmn.tim,1);
nl=size(dmn.lvl,2);
PAR={};
iP=1;
if (~isempty(dmn.tim) && ~isempty(dmn.lvl))
    dmn.par=dmn.par';
end
dmn.par1=dmn.par;
for i=1:size(dmn.par,1)
    %error('If dmn.par has 3 columns dmn.tim and dmn.lvl must be empty');
    %
    switch length(dmn.par(i,:))
        case 1
            p=convertToId(dmn.par(i,1),varTable,CONVERTTOGRIB);
            for il=1:nl
                l=convertToId(dmn.lvl(il),varTable);
                for it=1:nt
                    t=convertToId(dmn.tim(it),varTable);
                    %PAR(iP,:)={p,l,t}; 
                    PAR(iP,:)={p,l,t}; %Modificado por Dani
                    iP=iP+1;
                end
            end
        case 2
            p=convertToId(dmn.par(i,1),varTable,CONVERTTOGRIB);
            l=convertToId(dmn.par(i,2),varTable);
            for it=1:nt
                t=convertToId(dmn.tim(it),varTable);
                %PAR(iP,:)={p,l,t};
                PAR(iP,:)={p,l,t,0}; %Modificado por Dani
                iP=iP+1;
            end
        case 3
            p=convertToId(dmn.par(i,1),varTable,CONVERTTOGRIB);
            l=convertToId(dmn.par(i,2),varTable);
            t=convertToId(dmn.par(i,3),varTable);
            %PAR(iP,:)={p,l,t};
            PAR(iP,:)={p,l,t,0};  %Modificado por Dani
            iP=iP+1;
        case 4%%%Modificado por Dani para leer forecast
            p=convertToId(dmn.par(i,1),varTable,CONVERTTOGRIB);
            l=convertToId(dmn.par(i,2),varTable);
            t=convertToId(dmn.par(i,3),varTable);
            f=convertToId(dmn.par(i,4),varTable);            
            PAR(iP,:)={p,l,t,f}; 
            iP=iP+1;  
        otherwise
            error('Bad domain format');    
    end
end

dmn.par=PAR;
dmn.tim=[];
dmn.lvl=[];

if ~(isfield(dmn,'nod')) || isempty(dmn.nod) || size(dmn.nod,1)==1
    if isfield(dmn,'lon') & isfield(dmn,'lat')
        [xi,yi]=meshgrid(dmn.lon,dmn.lat);
        xi=xi';yi=yi';if size(dmn.nod,1)==1,xi=xi(dmn.nod);yi=yi(dmn.nod);end
        dmn1.nod=[xi(:) yi(:)]';
    end
elseif (isfield(dmn,'nod'))
    dmn1.nod=dmn.nod;
end

dmn1.par=dmn.par;
if(isfield(dmn,'startDate'))
    dmn1.startDate=dmn.startDate;
end
if(isfield(dmn,'endDate'))
    dmn1.endDate=dmn.endDate;
end
if(isfield(dmn,'step'))
    dmn1.step=dmn.step;
end
if(isfield(dmn,'path'))
    dmn1.path=dmn.path;
end
if(isfield(dmn,'src'))
    dmn1.src=dmn.src;
end

if nargin>1
    if ~CONVERTTOGRIB
		for i=1:size(dmn.par1,1)
			IA=strmatch(dmn.par1(i,1),varTable.Code,'exact');
            if ~isempty(IA)
                dmn1.varTable.Id(i)=varTable.Id(IA);
                dmn1.varTable.Label(i)=varTable.Label(IA);
                dmn1.varTable.Code(i)=varTable.Code(IA);
                dmn1.varTable.Unit(i)=varTable.Unit(IA);
                dmn1.varTable.Offset(i)=varTable.Offset(IA);
                dmn1.varTable.Scale(i)=varTable.Scale(IA);
                dmn1.varTable.Minimum(i)=varTable.Minimum(IA);
                dmn1.varTable.Maximum(i)=varTable.Maximum(IA);
            else
                dmn1.varTable.Id(i)={''};
                dmn1.varTable.Label(i)={''};
                dmn1.varTable.Code(i)={''};
                dmn1.varTable.Unit(i)={''};
                dmn1.varTable.Offset(i)={''};
                dmn1.varTable.Scale(i)={''};
                dmn1.varTable.Minimum(i)={''};
                dmn1.varTable.Maximum(i)={''};
            end
		end
		% [C,IA,IB] = intersect(varTable.Code,dmn.par1(:,1));
%	dmn1.par(:,1)=varTable.Code(IB)';
%	dmn1.Vars=varTable.Code(IA,:)';
%	dmn1.GRIBCodes=varTable.Id(IA,:)';
%	dmn1.GRIBunits=varTable.Unit(IA,:)';
		% dmn1.varTable.Id=varTable.Id(IA);
		% dmn1.varTable.Label=varTable.Label(IA);
		% dmn1.varTable.Code=varTable.Code(IA);
		% dmn1.varTable.Unit=varTable.Unit(IA);
		% dmn1.varTable.Offset=varTable.Offset(IA);
		% dmn1.varTable.Scale=varTable.Scale(IA);
		% dmn1.varTable.Minimum=varTable.Minimum(IA);
		% dmn1.varTable.Maximum=varTable.Maximum(IA);
	elseif version==2
        %[C,IA,IB] = intersect(varTable.Code,dmn.par1(:,1));
		[T,LOC] = ismember(dmn.par1(:,1),varTable.Code);
        LOC=LOC(T);
		dmn1.varTable.Id=varTable.Id(LOC);
		dmn1.varTable.Label=varTable.Label(LOC);
		dmn1.varTable.Code=varTable.Code(LOC);
		dmn1.varTable.Unit=varTable.Unit(LOC);
		dmn1.varTable.Offset=varTable.Offset(LOC);
		dmn1.varTable.Scale=varTable.Scale(LOC);
		dmn1.varTable.Minimum=varTable.Minimum(LOC);
		dmn1.varTable.Maximum=varTable.Maximum(LOC);	
    end
elseif isfield(dmn,'Vars')
%    dmn1.Vars=dmn.Vars;
%    dmn1.GRIBCodes=dmn.GRIBCodes;
%    dmn1.GRIBunits=dmn.GRIBunits;
end

function p=convertToId(p,vTable,CONVERTTOGRIB)
if iscell(p)
    p=p{1};
end
if isempty(p)
    p=0;
    return
end
if nargin<3
    CONVERTTOGRIB=0;
end
% if isempty(vTable)
%     return
% end

if ~isnumeric(p)
    if isnan(str2double(p))
        if ~isempty(vTable) && CONVERTTOGRIB
            ind=strmatch(p,vTable.Code,'exact');
            if isempty(ind)
                error(sprintf('Definition not found: %s',p));
            end
            p=vTable.Id{ind(end)};
            if ~isnan(str2double(p))
                p=str2double(p);
            end
        end
    else
        p=str2double(p);
    end
end

