% conjunto de datos
dataset = randn(100,20,3);

% Primera opcion para dibujar: utilizando arrays multidimensionales
figure,
h1=boxplotCsub( dataset(:,:,1),0,'.',1,1,'r',1,0.5,false,[1 3])
h2=boxplotCsub( dataset(:,:,2),0,'.',1,1,'g',1,0.5,false,[2 3])
h3=boxplotCsub( dataset(:,:,3),0,'.',1,1,'b',1,0.5,false,[3 3])
set(h1(end,:),'MarkerSize',3);
set(h2(end,:),'MarkerSize',3);
set(h3(end,:),'MarkerSize',3);

% Segunda opcion para dibujar: utilizando vectores
% Hago un reshape de tal forma que ahora todos los valores estan en un
% vector de longitud 100 x 20
dataset1 = reshape(dataset(:,:,1),prod(size(dataset(:,:,1))),1);
dataset2 = reshape(dataset(:,:,2),prod(size(dataset(:,:,2))),1);
dataset3 = reshape(dataset(:,:,3),prod(size(dataset(:,:,3))),1);
% En S almaceno a que grupo pertence cada elemento de los vectores de datos
S = repmat([1:size(dataset,2)],size(dataset,1),1); 
S = reshape(S,prod(size(S)),1);
figure,
h1 = boxplotCsub(dataset1,S,1,'.',1,1,'r',1,0.5,false,[1 3]); 
h2 = boxplotCsub(dataset2,S,1,'.',1,1,'g',1,0.5,false,[2 3]); 
h3 = boxplotCsub(dataset3,S,1,'.',1,1,'b',1,0.5,false,[3 3]); 
set(h1(end,:),'MarkerSize',3);
set(h2(end,:),'MarkerSize',3);
set(h3(end,:),'MarkerSize',3);

% La segunda opcion es especialmente util para dibujar series de diferente longitud
% En este ejemplo dejo solo los dos primeros elementos elementos de los grupos 
% 1 y 2 en el subgrupo 1 y elimino el subgrupo 3 a partir del grupo 10
dataset1 = reshape(dataset(:,:,1),prod(size(dataset(:,:,1))),1);
dataset2 = reshape(dataset(:,:,2),prod(size(dataset(:,:,2))),1);
dataset3 = reshape(dataset(:,:,3),prod(size(dataset(:,:,3))),1);
S = repmat([1:size(dataset,2)],size(dataset,1),1); 
S = reshape(S,prod(size(S)),1);
% Ahora quito los elementos:
i1  = find(S==1); i2 = find(S==2); ii = sort([i1(1:2); i2(1:2); find(S>2)]);
ii3 = sort(find(S>10));
figure,
h3 = boxplotCsub(dataset3(ii3),S(ii3),1,'.',1,1,'b',1,0.5,false,[3 3]);
h1 = boxplotCsub(dataset1(ii),S(ii),1,'.',1,1,'r',1,0.5,false,[1 3]);
h2 = boxplotCsub(dataset2,S,1,'.',1,1,'g',1,0.5,false,[2 3]);
set(h1(end,:),'MarkerSize',3);
set(h2(end,:),'MarkerSize',3);
set(h3(end,:),'MarkerSize',3);