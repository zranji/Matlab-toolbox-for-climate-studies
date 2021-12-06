%cfg.cam='E:\Meteo\Prometeo\AreaPatterns\GRID\';
cfg.fil='domain.cfg';
dmn=readDomain(cfg.fil)
[X Y]=meshgrid(dmn.lon,dmn.lat);
load worldlo

STR=load('par130_1000_06');
campo06=STR.campo;
STR=load('par130_1000_18');
campo18=STR.campo;
clear STR

Z{1}=reshape(std(campo06),[21 17])';
Z{2}=reshape(mean(campo06),[21 17])';
Z{3}=reshape(std(campo18),[21 17])';
Z{4}=reshape(mean(campo18),[21 17])';
Titles={'STD T 1000mb 06Z','Mean T 1000mb 06Z','STD T 1000mb 18Z','Mean T 1000mb 18Z'};
for i=1:length(Z),
   subplot(2,2,i)
   pcolor(X,Y,Z{i})
   hold on
   plot(POline(1).long,POline(1).lat,POline(1).otherproperty{:})
   plot(POline(2).long,POline(2).lat,POline(2).otherproperty{:})
   colorbar
   title(Titles{i})
end
return

msizex=8;
msizey=8;
campo=[campo06 campo18];
sMap = som_make(campo,'msize', [msizex msizey],'neigh','ep','lattice','rect'); 

figure
plot(campo(:,1),campo(:,2),'.')
hold on
som_grid(sMap,'Coord',sMap.codebook(:,[1 2]),'markercolor',som_normcolor(sMap.codebook(:,[2])),'linecolor','b');

Centers=sMap.codebook;


[OP,EOF]=g03aaf(campo);
%[CP,lambda,EOF]=svds(campo06,2);
CP=campo*EOF;
CentersCP=Centers*EOF;
figure
plot(CP(:,1),CP(:,2),'.')
hold on
som_grid(sMap,'Coord',CentersCP(:,[1 2]),'markercolor',som_normcolor(CentersCP(:,2)),'linecolor','r');

figure
L=[min(Centers(:)) max(Centers(:))];
for i=1:(msizex),
   for j=1:(msizey),
      z=reshape(Centers((j-1)*msizex+i,1:357),[21 17])';
      axes('DataAspectRatioMode','manual','DataAspectRatio',[1 1 1],...
         'units','normal','Position',[(i-1)/msizex 1-(j)/msizey 1/msizex 1/msizey]);
      
      %pcolor(X,Y,z)
      %shading flat
      contourf(X,Y,z)
      set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1],...
         'XTickLabelMode','manual','XTickLabel',[],...
         'XTickMode','manual','XTick',[],...
         'YTickLabelMode','manual','YTickLabel',[],...
         'YTickMode','manual','YTick',[]);
      
      hold on
      plot(POline(1).long,POline(1).lat,POline(1).otherproperty{:})
      plot(POline(2).long,POline(2).lat,POline(2).otherproperty{:})
      caxis(L);
   end   
end
%g=flipud(hot(size(get(gcf,'colormap'),1)+10));
%g=[[1 1 1];g(11:end,:)];
%colormap(g)

[campoNorm,mu,sig] = pstd(campo);
