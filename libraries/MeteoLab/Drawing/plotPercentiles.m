function plotPercentiles(obs,pred,varargin)
% plotPercentiles(obs,pred);
% 
% Draws the observed percentiles and the probability of each of them.
% 
% Input : 
% 	obs : vector with observed percentiles (terciles, quintiles, etc.)
%   pred: matrix with the probabilities of each percentile (first row for the highest percentile and last row for the lowest percentile).
% 	varargin	 : optional parameters
% 	
% Example:
%   obs=floor(rand([1 20])*3+1); %Terciles
%   pred=rand([3 20])*0.5; pred(3,:)=1-(pred(1,:)+pred(2,:));
% 	plotPercentiles(obs,pred);

myPcolor(pred);
hold on, plot(1.5:length(obs)+0.5,obs+0.5,'ko','MarkerSize',5,'Color','r');
set(gca,'clim',[0,1],'xlim',[1,length(obs)+1],'ylim',[1,size(pred,1)+1]);
colormap(flipud(gray(10))); colorbar; hold off;

