dirCachedData='./CACHED/Tx05/';
comun='SEAS00'; 	%parte comun de todos los ficheros .grb, asi como de la carpeta que los contiene.

lstMiembros=[0:39];  	%número de miembros
lstStep=1:183; 			%alcance mensual de la predicción [0:6] ej. Con la salida de mayo para predecir agos-sept, entonces step=3:4
Mes=5;
lstAnos=[1987:2005];

climDate={'1-Jan-1987','31-Aug-2004'};
iNetwork=1; %2, caso 1 red de completas y caso 2 red de grid203
switch iNetwork
case 1
   Obs.Network={'INM'};%para datos del grid de 203 puntos
   Obs.Stations={'completasSinCanarias.stn'};
   Obs.Variable={'Rellenos\Tx'};
case 2
   Obs.Network={'GridINM203'};%para datos del grid de 203 puntos
   Obs.Stations={'Grid.stn'};
   Obs.Variable={['prometeo/Tx']};
end

[Climatologia,Obs]=climatologia(Obs,climDate);
Clim=reshape(Climatologia,[size(Climatologia,1)*size(Climatologia,2), size(Climatologia,3)]);
k=12;
Clim2=Clim(1:size(Clim,1)-(k+7),:);
dim=size(Clim2,1);
for i=1:size(Clim2,2),
   [w, A]=arfit(Clim2(:,i),2,7); 
   predJ(i)=w+Clim2(dim-size(A,2)+1:dim,i)'*flipud(A');
   dat=[Clim2(1:dim-1,i);predJ(i)];
   predJu(i)=w+dat(dim-size(A,2)+1:dim,1)'*flipud(A');
   dat=[dat;predJu(i)];
   predA(i)=w+dat(dim-size(A,2)+1:dim,1)'*flipud(A');
end

figure
subplot(3,1,1)
plot(predJ)
hold on
plot(Clim(end-(k+6),:),'r')
subplot(3,1,2)
plot(predJu)
hold on
plot(Clim(end-(k+5),:),'r')
subplot(3,1,3)
plot(predA)
hold on
plot(Clim(end-(k+4),:),'r')

pred=(predJ+predJu+predA)/3;
Climat=(Clim(end-(k+6),:)+Clim(end-(k+5),:)+Clim(end-(k+4),:))/3;
figure
plot(pred)
hold on
plot(Climat,'r')

%percentiles de la climatologia
series=squeeze(mean(Climatologia([6 7 8],1:16,:),1)); %media para el trimestre de interés
percClima=percentiles(Climatologia,[0:20:100]);%quintiles de las observaciones, climatologia
percClima(1,:)=-Inf;
percClima(end,:)=Inf;
percObsr=asignarPercentilesEstaciones(permute(Climat,[2 1 3]),permute(percClima,[2 1 3]));%a cada estación le asigno su quintil en la clim
percPred=asignarPercentilesEstaciones(permute(pred,[2 1 3]),permute(percClima,[2 1 3]));%a cada estación le asigno su quintil en la clim

titulos={['Percentiles de la observacion para 2003' ]};
drawIrregularGrid(percObsr',Obs.Info.Location,'titles',titulos,'colorlim',[1 5],'nx',50,'ny',50,'colormap',jet(11));
titulos={['Percentiles del Autoregresivo para 2003' ]};
drawIrregularGrid(percPred',Obs.Info.Location,'titles',titulos,'colorlim',[1 5],'nx',50,'ny',50,'colormap',jet(11));
