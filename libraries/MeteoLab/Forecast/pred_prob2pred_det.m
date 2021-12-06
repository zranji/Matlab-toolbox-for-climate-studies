function [Ypred_det thre] = pred_prob2pred_det(Ypred_prob,clim)
%   [Ypred_det thre] = pred_prob2pred_det(Ypred_prob,clim)
%   This function transforms probabilistic forecasts into binary ones (1=event,0=no event) using calibrated 
%   thresholds. Such thresholds make the forecasted frecuency of the event closest to the observed one.
%   Inputs:
%       Ypred_prob: Matrix of probabilistic predictions (rows: timesteps, columns: stations).
%       clim: Vector of the length = number of columns in Ypred_prob with the climatological frequency of the event.
%   Outputs:
%       Ypred_det: Matrix of deterministic predictions (rows: timesteps, columns: stations).
%       thre: vector of calibrated thresholds.
Ypred_det = nan(size(Ypred_prob));
thre = nan(1,size(Ypred_prob,2));
for k = 1:size(Ypred_prob,2)
    p = Ypred_prob(:,k);
    c = clim(k);
    
    u = prctile(p,(1-c)*100);
    thre(1,k) = u;
    Ypred_det(:,k) = p >= u;  % favorezco el acierto en la prediccion del evento (HIR)
end



