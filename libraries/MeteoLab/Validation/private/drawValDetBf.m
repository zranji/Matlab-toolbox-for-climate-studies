function drawValDetBf(Prdc,Loc,Umb,Maes,kDay,kStn,Action)
if(nargin<5)
   fg=figure('menubar','figure','name',['Briefing of deterministic validation of' Maes.lVar],'Resize','off');
   PP=get(fg,'Position');
   set(fg,'Position',[PP(1:2) 400 400])
   Data.Prdc=Prdc*Maes.fctr;Data.Loc=Loc;Data.Maes=Maes;
   set(fg,'UserData',Data);  
   drawValDetBf([],[],[],[],1,1,'This');
   return
else
   Data=get(gcf,'UserData');
   Prdc=Data.Prdc;
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
      fg=figure('menubar','figure','name',['Briefing of deterministic validation of' Maes.lVar],'Resize','off');
      PP=PP+[10 -10 0 0];
  		set(fg,'Position',[PP(1:2) 400 400])
      set(fg,'UserData',Data)   
   else
      clf
   end
end

colormap(valZ);
sZ=size(valZ,1);
pdn=min(sqrt(nanmean(Prdc(:,:).^2,1)));
pdx=max(sqrt(nanmean(Prdc(:,:).^2,1)));
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

axes('units','normal','position',[0.125 0.50 0.75 0.04],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...
   'XLim',[0 1],'YLim',[0 1]);
hold on
image([0 1],[0 1],1:size(valZ,1))

axes('units','normal','position',[0 0.5625 1 0.375],'DataAspectRatioMode','Manual','DataAspectRatio',[1 1 1],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',[],'YTickMode','manual','Ytick',[],...
   'XLim',[minx maxx],'YLim',[miny maxy]);
Maes.lDay{kDay},Maes.lVar,Maes.lUnt,num2str(sqrt(nanmean(Prdc(1:end).^2)))
title(['Validacion de ' Maes.lVar ' ' Maes.lUnt '. Dia: ' Maes.lDay{kDay} '. RMSE=' num2str(sqrt(nanmean(Prdc(1:end).^2)))],'FontSize',7);
line(bnd(:,1),bnd(:,2),'Color','k','linestyle','-');
for k=1:size(Loc,1)
   %cmenu=uicontextmenu;
	%uimenu(cmenu,'Label',Maes.lStn{k});
   %fm=uimenu(cmenu,'Label','View Station in','Separator','on');
  	%nwStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(k) ',''New'');'];
   %thStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(k) ',''This'');'];
   %uimenu(fm,'Label','New Figure','Callback',nwStr);
   %uimenu(fm,'Label','This Figure','Callback',thStr);
   coZ=round((sqrt(nanmean(Prdc(:,k).^2,1))-pdn)/(pdx-pdn)*(sZ-1)+1);
      if any(k==NodEv)
      mk='s';
   else
      mk='o';
   end

   if(~isnan(coZ))
      line(Loc(k,1),Loc(k,2),'linestyle','none','marker',mk,'MarkerEdgeColor','k','MarkerSize',5 ...
         ,'MarkerFaceColor',valZ(coZ,:)); ...
%         ,'ButtonDownFcn',['if(strcmp(get(gcf,''SelectionType''),''normal'')),' thStr ',elseif(strcmp(get(gcf,''SelectionType''),''extend'')),' nwStr ',end']...
   else
      line(Loc(k,1),Loc(k,2),'linestyle','none','marker','.','MarkerEdgeColor','k','MarkerSize',5 ...
         ,'MarkerFaceColor','none');
      %         ,'ButtonDownFcn',['if(strcmp(get(gcf,''SelectionType''),''normal'')),' thStr ',elseif(strcmp(get(gcf,''SelectionType''),''extend'')),' nwStr ',end']...
   end
   
   
end

%nwStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',''New'');'];
%thStr=['drawValDet([],[],[],[],' num2str(kDay) ',' num2str(kStn) ',''This'');'];
%cmenu=uicontextmenu;
%fm=uimenu(cmenu,'Label','View Day in');
%uimenu(fm,'Label','New Figure','Callback',nwStr);
%uimenu(fm,'Label','This Figure','Callback',thStr);

%line(Loc(kStn,1),Loc(kStn,2),'linestyle','none','marker','+','MarkerSize',6,'MarkerEdgeColor','k','HitTest','off'...
%   ...
%   );

%thStr=['PP=get(gca,''CurrentPoint'');drawValDet([],[],[],[],round(PP(1,1)),' num2str(kStn) ',''This'');'];
%nwStr=['PP=get(gca,''CurrentPoint'');drawValDet([],[],[],[],round(PP(1,1)),' num2str(kStn) ',''New'');'];
pdn=min(sqrt(nanmean(Prdc(:,:).^2,2)));
pdx=max(sqrt(nanmean(Prdc(:,:).^2,2)));
axes('units','normal','position',[0.125 0.0625 0.75 0.375],...
   'box','on','xlimmode','manual','ylimmode','manual',...
   'XLim',[1 size(Prdc,1)],'YLim',[pdn pdx],'FontSize',7);
%   'ButtonDownFcn',['if(strcmp(get(gcf,''SelectionType''),''normal'')),' thStr ',elseif(strcmp(get(gcf,''SelectionType''),''extend'')),' nwStr ',end'],...

title(['Validacion de ' Maes.lVar ' 'Maes.lUnt '. Estacion: ' Maes.lStn{kStn} '. RMSE=' num2str(sqrt(nanmean(Prdc(1:end).^2)))],'FontSize',7);
xlabel('Dia','FontSize',7);ylabel('RMSE');
line([kDay kDay],[pdn pdx],'Color','r','linewidth',2,'HitTest','off');
line(1:size(Prdc,1),sqrt(nanmean(Prdc(:,:).^2,2)),'Color','k','linestyle','-','HitTest','off');
