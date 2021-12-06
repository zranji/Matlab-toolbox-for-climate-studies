function [indAng,distAng]=MLknn(V,U,k,DistClass)
%[indAng,distAng]=knn(V,U,k,DistClass)
%KNN	busca los k-vecinos mas proximos a V, dentro de U,
% segun la norma DistClass (esta opcion se encuentra fijada a 'Norm-2')
% Cada fila de U y V definen un vector. El numero de filas de indAng e 
% distAng es igual a las filas de U, y el numero de columnas es k.
% En cada fila de indAng tendremos el cjto de vectores de U que son
% vecinos de U . distAng corresponde a la distancia de cada uno de ellos.
% Inputs:
%	- V Nest*Ndim vector with the coordinates of the referencial points.
%	- U N*Ndim vector with the coordinates of the points.
%	- k Number of neighbours.
%	- DistClass: Vectorial norm used to estimate the distance. 
%		This argument can take the next values:
%			- Euclidean norm: {'Norm-2';'norm-2';2}.
%			- Infinite norm: {inf;'inf'};
%			- Minus infinite norm: {-inf;'-inf'};
%			- P-norm: for each integer p a norm can be defined. The case 2 is equivalent to the Euclidean norm.
%		For more details type help norm in the command window.
% Outputs:
%	- indAng Nest*k matrix with the indexes of the k nearest points to V in U.
%	- indAng Nest*k matrix with the distance of the k nearest points to V in U.

[Nest,ndim]=size(V);
[Nestu,ndimu]=size(U);
indAng=repmat(NaN,Nest,k);
distAng=repmat(NaN,Nest,k);
for i=1:Nest,
	switch lower(DistClass)
		case {'norm-2',2}
			aux=sqrt(sum((repmat(V(i,:),Nestu,1)-U).^2,2));
		case {inf,'inf'}
			aux=max(abs(repmat(V(i,:),Nestu,1)-U),[],2);
		case {-inf,'-inf'}
			aux=min(abs(repmat(V(i,:),Nestu,1)-U),[],2);
		otherwise
			if isnumeric(DistClass)
				aux=sum(abs(repmat(V(i,:),Nestu,1)-U).^DistClass,2).^(1/DistClass);
			else
				error('Unknown norm: check the name')
			end
	end
	[aux,aux1]=sort(aux);aux=aux(1:k)';aux1=aux1(1:k)';
	distAng(i,:)=aux;ind=find(~isnan(aux));
	if ~isempty(ind)
		indAng(i,ind)=aux1(ind);
	end
end
