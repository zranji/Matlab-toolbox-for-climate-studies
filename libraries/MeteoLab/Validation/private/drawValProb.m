function drawValProb(VP,Loc,Umb,Maes,kDay,kStn,kUmb,Action)
if(nargin<5)
   fg=figure('menubar','figure','name',['Probabilistic Validation of ' Maes.lVar],'Resize','off');
   PP=get(fg,'Position');
   set(fg,'Position',[PP(1:2) 600 400])
   %VP.BSS(find(VP.BSS<0))=NaN;
   Data.VP=VP;Data.Loc=Loc;Data.Umb=Umb(2,1:end-1);Data.Maes=Maes;
   set(fg,'UserData',Data);  
   drawValProb([],[],[],[],1,1,1,'This');
   return
else
   Data=get(gcf,'UserData');
   VP=Data.VP;
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
   
Umb=Data.Umb;Maes=Data.Maes;
   if(strcmp(Action,'New'))
      PP=get(gcf,'Position');
      fg=figure('menubar','figure','name','Forecast','Resize','off');
      PP=PP+[10 -10 0 0];
  		set(fg,'Position',[PP(1:2) 400 400])
      set(fg,'UserData',Data)   
   else
      clf
   end
end

colormap(valZ);
sZ=size(valZ,1);

pdn=min(VP.BSS(:));
pdx=max(VP.BSS(:));

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

axes('units','normal','position',[0.125 0.50 0.75*2/3 0.04],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...
   'XLim',[0 1],'YLim',[0 1]);
hold on
image([0 1],[0 1],1:size(valZ,1))

nwStr=['drawValProb([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',' num2str(kUmb) ',''New'');'];
thStr=['drawValProb([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',' num2str(kUmb) ',''This'');'];
cmenu=uicontextmenu;
fm=uimenu(cmenu,'Label','Spatial mean BSS');
%uimenu(fm,'Label','New Figure','Callback',nwStr);
%uimenu(fm,'Label','This Figure','Callback',thStr);

axes('units','normal','position',[0 0.5625 1*2/3 0.375],'DataAspectRatioMode','Manual','DataAspectRatio',[1 1 1],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...
   'XLim',[minx maxx],'YLim',[miny maxy],'UIContextMenu',cmenu);
title(['Validacion de ' Maes.lVar '>' Maes.lUmb{kUmb} ' ' Maes.lUnt '. Dia: ' Maes.lDay{kDay}],'FontSize',7);
line(bnd(:,1),bnd(:,2),'Color','k','linestyle','-');
for q=1:size(Umb,2),
   nwStr=['drawValProb([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',' num2str(q) ',''New'');'];
	thStr=['drawValProb([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',' num2str(q) ',''This'');'];
   fm=uimenu(cmenu,'Label',['BSS(' Maes.lVar '>' Maes.lUmb{q} Maes.lUnt ')=' num2str(nanmean(VP.BSS(1,:,q),2),'%4.3f') ]);
   if q==1
      set(fm,'Separator','on');
   end
   uimenu(fm,'Label','New Figure','Callback',nwStr);
	uimenu(fm,'Label','This Figure','Callback',thStr);
end


for k=1:size(Loc,1)
   cmenu=uicontextmenu;
	uimenu(cmenu,'Label',Maes.lStn{k});
   fm=uimenu(cmenu,'Label','View Station in','Separator','on');
  	nwStr=['drawValProb([],[],[],[],' num2str(kDay) ',' num2str(k) ',' num2str(kUmb) ',''New'');'];
   thStr=['drawValProb([],[],[],[],' num2str(kDay) ',' num2str(k) ',' num2str(kUmb) ',''This'');'];
   uimenu(fm,'Label','New Figure','Callback',nwStr);
   uimenu(fm,'Label','This Figure','Callback',thStr);
   for q=1:size(Umb,2),
      nwStrL=['drawValProb([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',' num2str(q) ',''New'');'];
		thStrL=['drawValProb([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',' num2str(q) ',''This'');'];
		fm=uimenu(cmenu,'Label',['BSS(' Maes.lVar '>' Maes.lUmb{q} Maes.lUnt ')=' num2str(VP.BSS(1,k,q),'%4.3f') ]);
	   uimenu(fm,'Label','New Figure','Callback',nwStrL);
   	uimenu(fm,'Label','This Figure','Callback',thStrL);
   end
   coZ=round((VP.BSS(1,k,kUmb)-pdn)/(pdx-pdn)*(sZ-1)+1);
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


thStr=['PP=get(gca,''CurrentPoint'');drawValProb([],[],[],[],round(PP(1,1)),' num2str(kStn) ',' num2str(kUmb) ',''This'');'];
nwStr=['PP=get(gca,''CurrentPoint'');drawValProb([],[],[],[],round(PP(1,1)),' num2str(kStn) ',' num2str(kUmb) ',''New'');'];
axes('units','normal','position',[0.125 0.0625 0.75*2/3 0.375],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'ButtonDownFcn',['if(strcmp(get(gcf,''SelectionType''),''normal'')),' thStr ',elseif(strcmp(get(gcf,''SelectionType''),''extend'')),' nwStr ',end'],'FontSize',7,...
   'XLim',[1 size(VP.BSSD,1)],'YLim',[0 1]);
title(['Temporal BSS for ' Maes.lVar '>' Maes.lUmb{kUmb} ' 'Maes.lUnt],'FontSize',7);
xlabel('Dia','FontSize',7);ylabel('BSS');
line([kDay kDay],[0 1],'Color','r','linewidth',2,'HitTest','off');
line(1:size(VP.BSSD,1),squeeze(VP.BSSD(:,1,kUmb)),'Color','k','linestyle','-','HitTest','off');


axes('units','normal','position',[1*2/3 0.5625 0.75*1/3 0.375],...
   'box','on','DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',0:0.25:1,'YTickMode','manual','Ytick',0:0.25:1,...
   'XTickLabelMode','Manual','YTickLabelMode','Manual',...
   'XLim',[0 1],'YLim',[0 1],'XGrid','on','YGrid','on');
hold on
cla
line(VP.FAR(:,kStn,kUmb),VP.HIR(:,kStn,kUmb),'Color','b','Marker','o','linestyle','-','MarkerSize',7,'LineWidth',1)
line([0 1],[0 1],'Color','k','Marker','none','linestyle','-')

axes('units','normal','position',[1*2/3 0.0625 0.75*1/3 0.375],...
   'box','on','DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',0:0.25:1,'YTickMode','manual','Ytick',0:0.25:1,...
   'XTickLabelMode','Manual','YTickLabelMode','Manual',...
   'XLim',[0 1],'YLim',[0 1],'XGrid','on','YGrid','on');
hold on
cla
line(nanmean(VP.FAR(:,:,kUmb),2),nanmean(VP.HIR(:,:,kUmb),2),'Color','b','Marker','o','linestyle','-','MarkerSize',7,'LineWidth',1)
line([0 1],[0 1],'Color','k','Marker','none','linestyle','-')

