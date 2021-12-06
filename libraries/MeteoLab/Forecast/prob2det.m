function [YpredDet,thresholds]=prob2det(Ypred,clim,varargin);

% function Ypreddet=prob2det(dat,Ypred);
% prob2det function transforms probabilistic forecast into binary predictions (1=event,0=no event) using thresholds.
% These thresholds makes the forecast frecuency closest to the observed climatology.
% Input arguments:
%     Ypred: the probability prediction matrix (rows: time, columns: stations)
%     clim: the climatology vector (same elements as Ypred columns)
%     sens [optional]: the maximimun error (in percentage relative to clim) to accept a threshold. Default: 1 (1%)
% Output parameter:
%     YpredDet: the deterministic prediction (binary)

YpredDet = repmat(NaN,size(Ypred));
thresholds = repmat(NaN,1,size(Ypred,2));

sens = 5;

if nargin>=3
    sens = varargin{1};
end

c = 1;
count = 1;

while 1
    tic;
    prcs = 0:1/c:100;
    ps = prctile(Ypred,prcs);
    if size(Ypred,2)==1
        ps = ps';
    end
    [di,u] = min(abs(ps-repmat(clim,size(ps,1),1)),[],1);    
    ui = sub2ind(size(ps),u,1:size(Ypred,2));
    thresholds = ps(ui);
    YpredDet = Ypred<repmat(thresholds,size(Ypred,1),1);
    sens2 = max(100*(abs(nanmean(YpredDet)-clim))./clim);
    if sens2<sens
        break
    end
    if c>2^10
        warning(['Stop too many iterations. Max error: ' num2str(sens2)]);
        break
    end
    disp(sprintf('Iteration %g in %f secs. Error: %f',count,toc,sens2));
    count = count+1;
    c = c*2;
end
