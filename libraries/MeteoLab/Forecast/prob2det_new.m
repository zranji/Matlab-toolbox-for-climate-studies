function [det thre] = prob2det_new(prob,clim)
%   [det thre] = prob2det_new(prob,clim)
%   This function transforms probabilistic forecasts into binary ones (1=event,0=no event) using calibrated 
%   thresholds. Such thresholds make the forecasted frecuency of the event closest to the observed one.
%   Inputs:
%       prob: Matrix of probabilistic predictions (rows: timesteps, columns: stations).
%       clim: Vector of the length = number of columns in prob with the climatological frequency of the event.
%   Outputs:
%       det: Matrix of deterministic predictions (rows: timesteps, columns: stations).
%       thre: vector of calibrated thresholds.
det = nan(size(prob));
thre = nan(1,size(prob,2));
for k = 1:size(prob,2)
    p = prob(:,k);
    c = clim(k);
    
    u = prctile(p,(1-c)*100);
    thre(1,k) = u;
    det(:,k) = p >= u;  % favorezco el acierto en la prediccion del evento (HIR)
end



