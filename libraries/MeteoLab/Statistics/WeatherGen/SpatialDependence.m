Example.Network={'GSN'};
Example.Stations={'Example.stn'}; 
Example.Variable={'Precip'};
date={'1-Jan-1990','31-Dec-1998'};

[data,Example]=loadStations(Example,'dates',date,'ascfile',1);

%los discretizamos
umbrales=[000,005,20,40;... 
      005,20,40,Inf];
dato=[];
dato=ones(size(data))*NaN;
for k=1:size(umbrales,2)
   dato(find( data>=umbrales(1,k) & data<umbrales(2,k)))=k;
end
%aprendemos la estructura del dag
novar=size(dato,2); %numero de nodos
order=1:novar; %orden de eleccion para los padres
ns = size(umbrales,2)*ones(1,novar); %tamaño que toman cada uno de los nodos 
dag= learn_struct_K2(dato', ns, order, 'max_fan_in',novar,'verbose','yes');
%dato(i,m) es el dato m-esimo de la estacion i
%max_fan_in, numero maximo de padres, en este caso el maximo 6 

%dibujamos el grafo que hemos obtenido
drawdag(dag,Example.Info.Location)

%aprendemos los parametros
bnet = mk_bnet(dag, ns); %creamos la red
for i=1:novar
   bnet.CPD{i} = tabular_CPD(bnet, i); %definimos el tipo de cada uno de sus nodos, en este caso todos tabulares
end 
bnet = learn_params(bnet, dato');%aprendemos los parametros a partir de los datos, para la red definida

%propagamos evidencia
%engine=jtree_inf_engine(bnet);%se crea el motor de inferencia
%evidence = cell(1,novar);%definimos la evidencia como una celda vacia, de tamaño el numero de nodos
%evidence{3}=4;%damos evidencia a tantos nodos como queramos, en este caso solo al tercero
%engine=enter_evidence(engine, evidence);%propagamos la evidencia
%obtenemos las tablas de probabilidad para cada uno de los nodos
%el nodo al que hemos dado evidencia no tiene tabla, se le asigna un uno

%nota, se pueden calcular las probabilidades a priori de cada uno de los nodos, propagando la evidencia
%vacía evidence = cell(1,novar);

%generamos una muestra a partir de la estructura y los parametros de la red
for i=1:size(dato,1), 
   sample(:,i) = sample_bnet(bnet); 
end

figure
subplot(2,1,1)
plot([sample{15,:}])
subplot(2,1,2)
plot(dato(:,15),'r')

%%%%%%%%%%%%%%%%%%%%%%%%
%muestras con evidencia sólo funciona con la BNT2002
%genera una muestra de tamaño 2000, utilizando la estructura y los parametros aprendidos, 
%teniendo en cuenta la evidencia que hemos dado
NodEv=[1 5];%
evidence = cell(1,novar);
for i=1:size(NodEv,2), evidence{NodEv(i)}=2; end 
for i=1:2000, 
   sample2(:,i) = sample_bnet(bnet,'evidence',evidence); 
end

NodEv=[1];
evidence = cell(1,novar);
for i=1:size(NodEv,2), evidence{NodEv(i)}=4; end 
for i=1:2000, 
   sample3(:,i) = sample_bnet(bnet,'evidence',evidence); 
end

figure
subplot(4,1,1)
plot([sample{2,:}])
subplot(4,1,2)
plot([sample{3,:}])
subplot(4,1,3)
plot([sample{4,:}])
subplot(4,1,4)
plot([sample{6,:}])

figure
subplot(4,1,1)
plot([sample2{2,:}])
subplot(4,1,2)
plot([sample2{3,:}])
subplot(4,1,3)
plot([sample2{3,:}])
subplot(4,1,4)
plot([sample2{6,:}])

figure
subplot(4,1,3)
plot([sample3{2,:}])
subplot(4,1,2)
plot([sample3{3,:}])
subplot(4,1,1)
plot([sample3{4,:}])
subplot(4,1,4)
plot([sample3{6,:}])
