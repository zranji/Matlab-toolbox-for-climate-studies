function [fieldSignificance,Y,dof]=testFieldSignificance(data,significance,pValue)
% Esta función calcula la significancia espacial de los resultados obtenidos 
% por un test estadístico en base a la correlación espacial de los datos.
% Los datos de entrada son:
% 	- data: matriz de datos observados en los que cada fila es una observacion
% 		y cada columna una estacion.
% 	- significance: es el vector con la significancia obtenida en el test.
% 	- pValue: es el pValor para el cual queremos obtener la significacion espacial.
% Los datos de salida son:
% 	- fieldSignificance: es un vector de ceros y unos según el campo tenga o no fignificacion
% 		espacial.
% 	- Y: es la diferencia entre el valor obtenido con los datos y el valor teórico que nos daria la
% 		significacion espacial.
% 	- dof: es el numero de grados de libertad espacial efectivos de la matriz de datos de entrada.
% 		En caso de ser independientes, el valor de dof seria igual al numero de columnas de la matriz data.

Nest=length(significance);
spatialSig=nanpstd(data);
spatialSig=nansum(spatialSig.^2,2);
dof=2/nanstd(spatialSig/Nest)^2;
ndata=max(Nest,ceil(dof));
binomial=zeros(1,ndata);
for i=1:ndata,
	aux=binopdf([1:i],i,pValue);
	aux1=find(aux>=pValue);
	if ~isempty(aux1),
		binomial(i)=min(aux1)/i;
	else,
		aux1=find(aux<=pValue);
		binomial(i)=max(aux1)/i;
	end
end
Y1=interp1([1:ndata],binomial,dof);
Y=(length(find(significance>=100*(1-pValue)))/Nest)-Y1;
if Y>=0
	fieldSignificance=1;
else
	fieldSignificance=0;
end
