function [p,alpha,zeta]=testChisquare(data,varargin)

% Esta funcion compara la distribucion empirica de los datos con una
% distribucion uniforme. 
% Input:
%       - data: matriz NxNest con las series de observaciones de las
%       estaciones.
%       - varargin: datos de entrada opcionales. Puede tomar los valores:
%           - fraction: numero natural >1 que define los percentiles a comparar
%           {terciles}, quintiles, etc...
%           - index: es un vector con el indice de las observaciones en las
%           que ocurrio el evento a estudiar.
% Output:
%       - p: matriz de dimensiones fraccion x Nest con las distribuciones de
%       probabilidades observadas en cada estacion.
%       - alpha: matriz de dimensiones fraccion x Nest con la confianza del test.
%       - zeta: matriz de dimensiones fraccion x Nest con el valor del
%       estadistico.
%
%   [p,alpha]=testChisquare(data,'fraction',3)

[ndata,Nest]=size(data);
fraccion=3;
index=[1:ndata]';
theoreticTable=ones(2,2,Nest)*ndata/4;

for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'fraction', fraccion=varargin{i+1};
        case 'index', index=varargin{i+1};
        case 'theoretic', theoreticTable=varargin{i+1};
    end
end
noindex=setdiff([1:ndata]',index);
n=length(index);
nnp=length(noindex);
if ~isempty(noindex)
	theoreticTable=[n/fraccion (fraccion-1)*n/fraccion;nnp/fraccion (fraccion-1)*nnp/fraccion];
end

if size(theoreticTable,3)==1
    theoreticTable=repmat(theoreticTable,[1,1,Nest]);
end

p1=1/fraccion;
percentil=zeros(fraccion,Nest);
for k=1:fraccion-1
    percentil(k,:)=prctile(data,100*k/fraccion);
end
percentil(fraccion,:)=nanmax(data,1);
p=zeros(fraccion,Nest);
np=zeros(fraccion,Nest);
for j=1:Nest
    aux=zeros(fraccion,1);
    for k=1:fraccion-1
        aux(k)=length(find(data(index,j)<=percentil(k,j)));
        if k==1
            p(k,j)=aux(k);
        else
            p(k,j)=(aux(k)-aux(k-1));
        end
    end
	if nnp>0
        aux=zeros(fraccion,1);
        for k=1:fraccion-1
            aux(k)=length(find(data(noindex,j)<=percentil(k,j)));
            if k==1
                np(k,j)=aux(k);
            else
                np(k,j)=(aux(k)-aux(k-1));
            end
        end
	end
end
p(fraccion,:)=n-sum(p(1:fraccion-1,:));
if nnp>0,np(fraccion,:)=nnp-sum(np(1:fraccion-1,:));end
alpha=NaN*zeros(fraccion,Nest);
zeta=NaN*zeros(fraccion,Nest);
for k=1:fraccion
	table=zeros(2,2,Nest);
	table(1,:,:)=[p(k,:);nansum(p(setdiff([1:fraccion],k),:),1)];
	table(2,:,:)=[np(k,:);nansum(np(setdiff([1:fraccion],k),:),1)];
	aux=((table-theoreticTable).^2)./theoreticTable;
	X=squeeze(nansum(nansum(aux,2),1))';
	zeta(k,:)=sqrt(X)/ndata;
	alpha(k,:)=100*chi2cdf(X,1);
end
p=p/n;
