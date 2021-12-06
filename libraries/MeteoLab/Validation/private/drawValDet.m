function drawValDet(VP,Loc,Umb,Maes,kDay,kStn,Action)
if(nargin<5)
   fg=figure('menubar','figure','name',['Deterministic validation of ' Maes.lVar],'Resize','off','Position',[100 100 400 600]);
   PP=get(fg,'Position');
   set(fg,'Position',[PP(1:2) 400 600])
   Data.Prdc=VP.Prdc*Maes.fctr;Data.Obsr=VP.Obsr*Maes.fctr;Data.Loc=Loc;Data.Maes=Maes;
   set(fg,'UserData',Data);  
   drawValDet([],[],[],[],1,1,'This');
   return
else
   Data=get(gcf,'UserData');
   Prdc=abs((Data.Prdc-Data.Obsr));
   if (~isstruct(Data.Loc))
      Loc=Data.Loc;
      NodEv=[];   
      colorMap=[];
   else
      Loc=Data.Loc.loc;
      if(isfield(Data.Loc,'NodEv'))
         NodEv=Data.Loc.NodEv;
      else
         NodEv=[];
        
      end
   
		if(isfield(Data.Loc,'colorMap'))
         colorMap=Data.Loc.colorMap;
      else
      	colorMap=[];  
      end
      

   end
	if isempty(NodEv)
      NodEv=0;
   end
   if isempty(colorMap)
   	colorMap=hsv(20);
      colorMap=colorMap(1:end-5,:);
   end
   valZ=colorMap;  
   
Maes=Data.Maes;
   
   if(strcmp(Action,'New'))
      PP=get(gcf,'Position');
      fg=figure('menubar','figure','name',['Deterministic validation of ' Maes.lVar],'Resize','off');
      PP=PP+[10 -10 0 0];
  		set(fg,'Position',[PP(1:2) 400 600])
      set(fg,'UserData',Data)   
   else
      clf
   end
end

colormap(valZ);
sZ=size(valZ,1);
pdn=min(min(Prdc));
pdx=max(max(Prdc));
fidbnd=fopen('worldcoasthi.bin','rb','ieee-be');
bnd=fread(fidbnd,[2,inf],'single')';
fclose(fidbnd);
maxx=max(Loc(:,1));minx=min(Loc(:,1));
maxy=max(Loc(:,2));miny=min(Loc(:,2));
Dx=maxx-minx;
Dy=maxy-miny;
if (Dx~=0 & Dy~=0)
	maxx=maxx+Dx*0.2;minx=minx-Dx*0.2;
	maxy=maxy+Dy*0.2;miny=miny-Dy*0.2;
else
	maxx=max(bnd(:,1));minx=min(bnd(:,1));
	maxy=max(bnd(:,2));miny=min(bnd(:,2));
end

axes('units','normal','position',[0.125 0.50*2/3+1/3 0.75 0.04*2/3],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...
   'XLim',[0 1],'YLim',[0 1]);
hold on
image([0 1],[0 1],1:size(valZ,1))

axes('units','normal','position',[0 0.5625*2/3+1/3 1 0.375*2/3],'DataAspectRatioMode','Manual','DataAspectRatio',[1 1 1],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...
   'XLim',[minx maxx],'YLim',[miny maxy]);
title(['Validacion de ' Maes.lVar ' 'Maes.lUnt '. Dia: ' Maes.lDay{kDay} '. RMSE=' num2str(sqrt(nanmean(Prdc(kDay,:).^2,2)))],'FontSize',7);
line(bnd(:,1),bnd(:,2),'Color','k','linestyle','-');
for k=1:size(Loc,1)
   cmenu=uicontextmenu;
	uimenu(cmenu,'Label',Maes.lStn{k});
   fm=uimenu(cmenu,'Label','View Station in','Separator','on');
  	nwStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(k) ',''New'');'];
   thStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(k) ',''This'');'];
   uimenu(fm,'Label','New Figure','Callback',nwStr);
   uimenu(fm,'Label','This Figure','Callback',thStr);
   coZ=round((Prdc(kDay,k)-pdn)/(pdx-pdn)*(sZ-1)+1);
   if any(k==NodEv)
      mk='s';
   else
      mk='o';
   end
   if(~isnan(coZ))
      line(Loc(k,1),Loc(k,2),'linestyle','none','marker',mk,'MarkerEdgeColor','k','MarkerSize',5,'UIContextMenu',cmenu...
         ,'MarkerFaceColor',valZ(coZ,:)...
         ,'ButtonDownFcn',['if(strcmp(get(gcf,''SelectionType''),''normal'')),' thStr ',elseif(strcmp(get(gcf,''SelectionType''),''extend'')),' nwStr ',end']...
         );
   else
      line(Loc(k,1),Loc(k,2),'linestyle','none','marker','.','MarkerEdgeColor','k','MarkerSize',5,'UIContextMenu',cmenu...
         ,'MarkerFaceColor','none'...
         ,'ButtonDownFcn',['if(strcmp(get(gcf,''SelectionType''),''normal'')),' thStr ',elseif(strcmp(get(gcf,''SelectionType''),''extend'')),' nwStr ',end']...
         );
   end
   
   
end
line(Loc(kStn,1),Loc(kStn,2),'linestyle','none','marker','+','MarkerSize',6,'MarkerEdgeColor','k','HitTest','off'...
   ...
   );

nwStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',''New'');'];
thStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',''This'');'];
cmenu=uicontextmenu;
fm=uimenu(cmenu,'Label','View Day in');
uimenu(fm,'Label','New Figure','Callback',nwStr);
uimenu(fm,'Label','This Figure','Callback',thStr);

thStr=['PP=get(gca,''CurrentPoint'');drawValDet([],[],[],[],round(PP(1,1)),' num2str(kStn) ',''This'');'];
nwStr=['PP=get(gca,''CurrentPoint'');drawValDet([],[],[],[],round(PP(1,1)),' num2str(kStn) ',''New'');'];
axes('units','normal','position',[0.125 0.0625*2/3+1/3 0.75 0.375*2/3],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'ButtonDownFcn',['if(strcmp(get(gcf,''SelectionType''),''normal'')),' thStr ',elseif(strcmp(get(gcf,''SelectionType''),''extend'')),' nwStr ',end'],'FontSize',7,...
   'XLim',[1 size(Prdc,1)],'YLim',[pdn pdx],'UIContextMenu',cmenu);
title(['Validacion de ' Maes.lVar ' 'Maes.lUnt '. Estacion: ' Maes.lStn{kStn} '. RMSE=' num2str(sqrt(nanmean(Prdc(:,kStn).^2,1)))],'FontSize',7);
xlabel('Dia','FontSize',7);ylabel('|e|');
line([kDay kDay],[pdn pdx],'Color','r','linewidth',2,'HitTest','off');
line(1:size(Prdc,1),squeeze(Prdc(:,kStn)),'Color','k','linestyle','-','HitTest','off');


nwStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',''New'');'];
thStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',''This'');'];
cmenu=uicontextmenu;
fm=uimenu(cmenu,'Label','View Day in');
uimenu(fm,'Label','New Figure','Callback',nwStr);
uimenu(fm,'Label','This Figure','Callback',thStr);


thStr=['PP=get(gca,''CurrentPoint'');drawValDet([],[],[],[],round(PP(1,1)),' num2str(kStn) ',''This'');'];
nwStr=['PP=get(gca,''CurrentPoint'');drawValDet([],[],[],[],round(PP(1,1)),' num2str(kStn) ',''New'');'];
pdn=min(min([Data.Prdc(1:end),Data.Obsr(1:end)]));
pdx=max(max([Data.Prdc(1:end),Data.Obsr(1:end)]));
axes('units','normal','position',[0.125 0.0625*2/3 0.75 0.375*2/3],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'ButtonDownFcn',['if(strcmp(get(gcf,''SelectionType''),''normal'')),' thStr ',elseif(strcmp(get(gcf,''SelectionType''),''extend'')),' nwStr ',end'],'FontSize',7,...
   'XLim',[1 size(Prdc,1)],'YLim',[pdn pdx],'UIContextMenu',cmenu);
title(['Prediccion & Observacion de ' Maes.lVar ' 'Maes.lUnt '. Estacion: ' Maes.lStn{kStn} '. RMSE=' num2str(sqrt(nanmean(Prdc(:,kStn).^2,1)))],'FontSize',7);
xlabel('Dia','FontSize',7);ylabel('');
line([kDay kDay],[pdn pdx],'Color','r','linewidth',2,'HitTest','off');


line(1:size(Data.Obsr,1),squeeze(Data.Obsr(:,kStn)),'Color','r','linestyle','-','HitTest','off');
line(1:size(Data.Prdc,1),squeeze(Data.Prdc(:,kStn)),'Color','b','linestyle','-','HitTest','off');
