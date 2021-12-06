function [p,alpha,zeta]=testUniform(data,varargin)

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
%   [p,alpha]=testUniform(data,'fraction',3)

[ndata,Nest]=size(data);
fraccion=3;
index=[1:ndata]';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'fraction', fraccion=varargin{i+1};
        case 'index', index=varargin{i+1};
    end
end

n=length(index);
p1=1/fraccion;
percentil=zeros(fraccion,Nest);

for k=1:fraccion-1
    percentil(k,:)=prctile(data,100*k/fraccion);
end
percentil(fraccion,:)=nanmax(data,1);

p=zeros(fraccion,Nest);

for j=1:Nest
    aux=zeros(fraccion,1);
    for k=1:fraccion-1
        aux(k)=length(find(data(index,j)<=percentil(k,j)));
        if k==1
            p(k,j)=aux(k)/n;
        else
            p(k,j)=(aux(k)-aux(k-1))/n;
        end
    end
end

p(fraccion,:)=1-sum(p(1:fraccion-1,:));
zeta=(p-p1)/sqrt(p1*(1-p1)/n);
alpha=abs(100*(2*normcdf(zeta)-1));
