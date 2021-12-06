function ind=findVarPosition(varargin)
%ind=findVarPosition(var,time,level,dmn)
%
%Funcion que entresaca una variable a un tiempo y un nivel especifico de la 
%matriz completa de datos (patron)
%
%En la entrada:
%	var	:	variable, por ejemplo 'T' (temperatura) 
%	time	:	hora de analisis de la variable
%	level	:	nivel de presion (en mb)
%	dmn	:	domain en el que debe estar definido todo lo anterior	
%	
%En la salida:
%	ind	:	vector con los indices de las columnas del patron que contienen
%	los datos de interes
%

error(nargchk(4,5,nargin));

if(nargin==4)
	var = varargin{1};
	time = varargin{2};
	level = varargin{3};
	dmn = varargin{4};
    frcst = 0;
else
	var = varargin{1};
	time = varargin{2};
	level = varargin{3};
	frcst = varargin{4};
	dmn = varargin{5};
end

dmn=parseDomain(dmn);
nPAR=size(dmn.par,1);
nn=size(dmn.nod,2);

if(size(dmn.par,2)==3)
    if isnumeric(var)
    %    var=num2str(var);
        ind=find(var==cat(1,dmn.par{:,1}) &...
        level==cat(1,dmn.par{:,2}) &...
        time==cat(1,dmn.par{:,3}) );
    else
        ind=find(strcmp(var,dmn.par(:,1)) &...
        level==cat(1,dmn.par{:,2}) &...
        time==cat(1,dmn.par{:,3}) );
    end
else % con forecast
    if isnumeric(var)
    %    var=num2str(var);
        ind=find(var==cat(1,dmn.par{:,1}) &...
        level==cat(1,dmn.par{:,2}) &...
        time==cat(1,dmn.par{:,3}) &...
        frcst==cat(1,dmn.par{:,4}) );
    else
        ind=find(strcmp(var,dmn.par(:,1)) &...
        level==cat(1,dmn.par{:,2}) &...
        time==cat(1,dmn.par{:,3}) &...
        frcst==cat(1,dmn.par{:,4}) );
    end
end    
% ind=find(strcmp(var,dmn.par(:,1)) &...
%     strcmp(level,dmn.par(:,2)) &...
%     strcmp(time,dmn.par(:,3)) );

if isempty(ind)
    return
end
ind=(1:nn)+nn*(ind-1);

%ind=cumprod([nD nN nH])*[N-1 H-1 P-1]';
%ind=(ind+1):(ind+nD);

