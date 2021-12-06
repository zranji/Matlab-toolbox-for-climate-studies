function drawValgen(V)
ColorLine={'b','r','g','c','m'};
figure
pos=get(gcf,'position');
pos(4)=325;
set(gcf,'Position',pos);
hrel=axes('units','normal','position',[0.10,0.10,2/3-0.20,0.80],...
   'box','on','DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',0:0.25:1,'YTickMode','manual','Ytick',0:0.25:1,...
   'XTickLabelMode','auto','YTickLabelMode','auto',...
   'XLim',[0 1],'YLim',[0 1],'XGrid','on','YGrid','on','FontSize',7,'Nextplot','add');
hold on
title('Reliability','FontSize',9,'FontWeight','bold');
xlabel('Forecast probability','FontSize',9);ylabel('P(o=1 | p=1)','FontSize',9);
line([0 1],[0 1],'Color','k','Marker','none','linestyle','-');
      
hres=axes('units','normal','position',[2/3+0.05,0.10,1/3-0.10,0.80],'Nextplot','add');
hold on
%set(gca,...
%   'box','on','DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','xlimmode','manual','ylimmode','manual',...
%   'XTickMode','manual','Xtick',0:0.25:1,'YTickMode','manual','Ytick',0:0.25:1,...
%   'XTickLabelMode','Manual','YTickLabelMode','Manual',...
%   'XLim',[0 1],'YLim',[0 1],'XGrid','on','YGrid','on');
title('Resolution','FontSize',9,'FontWeight','bold');

figure
pos=get(gcf,'position');
pos(4)=210;
set(gcf,'Position',pos);
%Diagram ROC
hroc=axes('units','normal','position',[0.07 0.10 0.25 0.80],...
   'box','on','DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',0:0.25:1,'YTickMode','manual','Ytick',0:0.25:1,...
   'XTickLabelMode','auto','YTickLabelMode','auto',...
   'XLim',[0 1],'YLim',[0 1],'XGrid','on','YGrid','on','FontSize',7,'Nextplot','add');
hold on
   line([0 1],[0 1],'Color','k','Marker','none','linestyle','-');
xlabel('FAR','FontSize',8);ylabel('HIR','FontSize',8);
title('ROC','FontSize',9,'FontWeight','bold');

%set(findobj(h,'Type','text'),'FontSize',7);


hev=axes('units','normal','position',[0.45 0.10 0.50 0.80],...
   'box','on','DataAspectRatio',[1 2 1],'DataAspectRatioMode','manual','xlimmode','manual','ylimmode','manual',...
   'XTickMode','manual','Xtick',0:0.25:1,'YTickMode','manual','Ytick',0:0.25:1,...
   'XTickLabelMode','auto','YTickLabelMode','auto',...
   'XLim',[0 1],'YLim',[0 1],'XGrid','off','YGrid','off','FontSize',7,'Nextplot','add');
hold on
xlabel('Costs losses ratio','FontSize',8);ylabel('Economic Value','FontSize',8);
title('Economic Value','FontSize',9,'FontWeight','bold');

Valor=linspace(0,1,1000);
ic=1;
X=[];
Y=[];
for ip=1:length(V)
   if ~isempty(V(ip).FBO)
      axes(hrel)
      REL=V(ip).FBO./V(ip).FBP;
      N=sum(V(ip).FBP);
      RES=V(ip).FBP/N;
      line(V(ip).PRB,REL,'Marker','o','linestyle','-','MarkerSize',7,'LineWidth',1,'Color',ColorLine{ic});
      line([0 1],V(ip).Pc*[1 1],'linestyle','-','MarkerSize',7,'LineWidth',1,'Color',ColorLine{ic});
      %legend(['BSS='num2str(V(ip).BSS)],2)
      
      %axes(hres)
      X=V(ip).PRB;
      Y=[Y,RES];
      %bar(V(ip).PRB,RES,ColorLine{ic});
      %set(gca,...
      %   'box','on','FontSize',7);
      %legend(['#=' num2str(N)]);
      
      axes(hroc)
      line(V(ip).FAR,V(ip).HIR,'Marker','o','linestyle','-','MarkerSize',7,'LineWidth',1,'Color',ColorLine{ic});
      %legend(['Area=',num2str(sum(0.5*(V(ip).HIR(1:end-1)+V(ip).HIR(2:end)).*(V(ip).FAR(1:end-1)-V(ip).FAR(2:end))))],4);
      
      Valorm=min(Valor,V(ip).Pc);
      axes(hev)   
      EconVal=(ones(size(V(ip).HIR))*Valorm-V(ip).HIR*V(ip).Pc*Valor-V(ip).FAR*(1-V(ip).Pc)*Valor-(1-V(ip).HIR)*V(ip).Pc*ones(size(Valor)))./(ones(size(V(ip).HIR))*(Valorm-V(ip).Pc*Valor));
      %line(Valor,EconVal,'Color',ColorLine{ic});
      line(Valor,max(EconVal,[],1),'Color',ColorLine{ic},'LineWidth',2)
      line([V(ip).Pc V(ip).Pc],[0 1],'Color',ColorLine{ic},'LineWidth',1)
      ic=ic+1;
      if ic>length(ColorLine)
         ic=1;
      end
   end
end
axes(hres)

bar(X,Y,1);
set(gca,'xlim',[0,1])