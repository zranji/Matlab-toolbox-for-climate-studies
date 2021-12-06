function [dataOut,newData]=nandeTrend(data,pValue,varargin)
% dataOut=nandeTrend(data,pValue,varargin);
% 
% Funcion que elimina la tendencia de los datos de entrada. La tendencia es
% eliminada restando a los datos reales su recta de regresion lineal.
% 
% En la entrada : 
% 	data        : son las series de datos de las cuales queremos eliminar la
%                 tendencia.
%   pValue      : es el p-valor calculado mediante alguno de los tests de
%                 tendencia empleados (Spearman, MannKendall,...).
% 	varargin	: paramétros opcionales
% 		'period'  - toma valores naturales y define la agrupacion de los datos para la aplicacion de los tests. Por
%            		defecto se le asigna 1.
%       'treshold'- marca el umbral segun el cual consideramos la
%                   existencia de tendencia en la serie de datos. Por defecto se asigna
%                   el valor 0.05.
%       'missing' - parametro de missing data para la funcion 'movingAverage'
%       'trend'   - se corresponde con el segundo argumento de la funcion detrend de MatLab.
%					Define el tipo de tendencia que se quiere eliminar: 'constant', {'linear'}, etc.
%       'keepmean'- 0,'no' o 'false' para eliminar la media al quitar la tendencia (por defecto).
%       			1,'yes' o 'true' para mantener la media de la muestra.
% 	
% En la salida  :
% 	dataOut     : es el vector con los valores resultantes de eliminar la
%                 tendencia a la serie de entrada. En caso de que no exista
%                 tendencia se devuelven los valores de entrada.
%   newData     : en el caso de que la variable periodo no sea diaria
%                 tenemos la opcion de que nos devuelva la serie de datos sobre la cual
%                 se realiza el test.
% 
% Ejemplo de llamada:
% 
% 		[dataOut]=nandeTrend(data,pValue,'period','year','treshold',0.05,'missing',0.1);

missing=0; 
period=1;
treshold=0.05;
trend='linear';
keepMean=0;
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'period', period=varargin{i+1};
        case 'treshold', treshold=varargin{i+1};
        case 'missing', missing=varargin{i+1};
        case 'trend', trend=varargin{i+1};
        case 'keepmean', keepMean=varargin{i+1};
    end
end
[ndata,Nest]=size(data);
newData=movingAverage(data,period,'missing',missing);
dataOut=NaN*ones(size(newData));
aux=~isnan(newData);
N=sum(aux);
for i=1:Nest
    if N(i)>1
        if pValue(i)<=treshold
			% b=sum(([1:N(i)]'-mean([1:N(i)])).*(newData(aux(:,i),i)-mean(newData(aux(:,i),i),1)),1)/sum(([1:N(i)]-mean([1:N(i)])).^2);
            % a=mean(newData(aux(:,i),i))-b*mean([1:N(i)]);
            % dataOut(aux(:,i),i)=newData(aux(:,i),i)-(a+b*[1:N(i)]');
			switch keepMean
                case {1,'yes','true'}
                    dataOut(aux(:,i),i)=detrend(newData(aux(:,i),i),trend);
                    dataOut(aux(:,i),i)=dataOut(aux(:,i),i)+mean(newData(aux(:,i),i));
                otherwise
                    dataOut(aux(:,i),i)=detrend(newData(aux(:,i),i),trend);
			end
        else
            dataOut(:,i)=newData(:,i);
        end
    end
end