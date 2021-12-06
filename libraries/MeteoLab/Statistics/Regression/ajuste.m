function [yest,c,yest2,lv]=ajuste(y,x,METODO,lv,NumA,xAng,xe)
NOXE=0;
if(nargin<7 | isempty(xe))
    xe=x;
    NOXE=1;
end
yest2=[];

c=[NaN NaN]';
switch upper(METODO)
    case 'STEPWISE' %Regresion lineal
        [B,SE,PVAL,INMODEL,STATS,NEXTSTEP,HISTORY]=stepwise_fit(x(:,lv),y,'penter',0.01,'scale','on','display','off');
        lv=lv(find(INMODEL));
        %modelo
        c=regression(y,[ones(length(y),1) x(:,lv)]);
        %estimacion
        yest=[ones(size(x,1),1) x(:,lv)]*c;
        yest2=[ones(size(xe,1),1) xe(:,lv)]*c;
    case 'LINEAL' %Regresion lineal
        %modelo
        c=regression(y,[ones(length(y),1) x(:,lv)]);
        %estimacion
        yest=[ones(size(x,1),1) x(:,lv)]*c;
        yest2=[ones(size(xe,1),1) xe(:,lv)]*c;
    case 'KNN' %k-vecinos
        %yest=nanmean(y(indStn(ind,2:NumA)),2);
        yest=ones(size(y))+NaN;
        [indStn,distStn]=MLknn(x(:,xAng),x(:,xAng),NumA+1,2);
        for k=1:length(y)
            xx=x(indStn(k,1:end),:);
            yy=y(indStn(k,1:end));
            indd=find(~isnan(yy) & sum(isnan(xx(:,lv)),2)==0 & sum(isnan(xx(:,xAng)),2)==0);
            c=regression(yy(indd(1:NumA)),[ones(NumA,1) xx(indd(1:NumA),lv)]);
            %estimacion
            yest(k)=[1 x(k,lv)]*c;
        end
        if(NOXE)
            yest2=yest;    
        else
            yest2=ones([size(xe,1),1])+NaN;
            [indStn,distStn]=MLknn(xe(:,xAng),x(:,xAng),2*NumA,2);
            for k=1:size(xe,1)
                xx=x(indStn(k,1:end),:);
                yy=y(indStn(k,1:end));
                indd=find(~isnan(yy) & sum(isnan(xx(:,lv)),2)==0 & sum(isnan(xx(:,xAng)),2)==0);
                c=regression(yy(indd(1:NumA)),[ones(NumA,1) xx(indd(1:NumA),lv)]);
                %estimacion
                yest2(k)=[1 xe(k,lv)]*c;
            end
        end
    case 'KNNSTEPWISE' %k-vecinos
        %yest=nanmean(y(indStn(ind,2:NumA)),2);
        flv=zeros(1,length(lv));
        yest=ones(size(y))+NaN;
        [indStn,distStn]=MLknn(x(:,xAng),x(:,xAng),2*NumA,2);
        for k=1:length(y)
            xx=x(indStn(k,2:end),:);
            yy=y(indStn(k,2:end));
            indd=find(~isnan(yy) & sum(isnan(xx(:,lv)),2)==0 & sum(isnan(xx(:,xAng)),2)==0);
            
            [B,SE,PVAL,INMODEL,STATS,NEXTSTEP,HISTORY]=stepwise_fit(xx(indd(1:NumA),lv),yy(indd(1:NumA)),'penter',0.05,'scale','on','display','off');
            lv2=lv(find(INMODEL));
            flv=flv+INMODEL;
            c=regression(yy(indd(1:NumA)),[ones(NumA,1) xx(indd(1:NumA),lv2)]);
            %estimacion
            yest(k)=[1 x(k,lv2)]*c;
            mdl{k}=c;
            mdlV{k}=lv2;
        end
        if(NOXE)
            yest2=yest;    
        else
            yest2=ones([size(xe,1),1])+NaN;
            [indStn,distStn]=MLknn(xe(:,xAng),x(:,xAng),2*NumA,2);
            for k=1:size(xe,1)
                %try
                    yest2(k)=[1 xe(k,mdlV{indStn(k,1)})]*mdl{indStn(k,1)};
                    %catch
                    %keyboard    
                    %end
                
                %xx=x(indStn(k,1:end),:);
                %yy=y(indStn(k,1:end));
                %indd=find(~isnan(yy) & sum(isnan(xx(:,lv)),2)==0 & sum(isnan(xx(:,xAng)),2)==0);
                %[B,SE,PVAL,INMODEL,STATS,NEXTSTEP,HISTORY]=stepwise_fit(xx(indd(1:NumA),lv),yy(indd(1:NumA)),'penter',0.05,'scale','on','display','off');
                %lv2=lv(find(INMODEL));
                %flv=flv+INMODEL;
                %c=regression(yy(indd(1:NumA)),[ones(NumA,1) xx(indd(1:NumA),lv2)]);
                %estimacion
                %yest2(k)=[1 xe(k,lv2)]*c;
            end
        end
        lv=mdlV;
        c=mdl;
    case 'NN' %NEURAL NETWORK
        T=y(:)';
        P=x(:,lv)';
        nnet=newff([min(P')' max(P')'],[1],{'purelin'},'trainlm');
        nnet.trainParam.epochs=1000;
        nnet.trainParam.show=100;
        nnet=train(nnet,P,T);
        yest2=sim(nnet,P)';
        yest2=sim(nnet,xe(:,lv)')';
    otherwise
        error(sprintf('METODO desconocido: %s',METODO))
end

