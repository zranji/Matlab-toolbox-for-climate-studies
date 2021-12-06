function [p,alpha]=testChisquare(table,varargin)

% Esta funcion compara la distribucion empirica de los datos con una
% distribucion teorica mediante el test de la Chi-cuadrado.
% Input:
%       - table: matriz NxMxNest con las frecuencias absolutas observadas en las
%       estaciones.
%       - varargin: datos de entrada opcionales. Puede tomar los valores:
%           - theoretic: matriz NxMx{1 o Nest} con las frecuencias
%           absolutas teoricas. Por defecto asigna una distribucion
%           equiprobable.
% Output:
%       - p: vector de dimension Nest con el valor del estadistico en cada
%       estacion.
%       - alpha: vector de dimension Nest con la confianza del test.
%
%   [p,alpha]=testChisquare(table,'theoretic',theoreticTable)

Nest=size(table,3);
ndata=nansum(nansum(table(:,:,1),1),2);
theoreticTable=ones(size(table))*ndata/(size(table,1)*size(table,2));

for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'theoretic', theoreticTable=varargin{i+1};
    end
end

if size(theoreticTable,3)==1
    theoreticTable=repmat(theoreticTable,[1,1,Nest]);
end

aux=((table-theoreticTable).^2)./theoreticTable;
X=squeeze(nansum(nansum(aux,2),1));

p=sqrt(X)/ndata;
alpha=100*chi2cdf(X,1);
