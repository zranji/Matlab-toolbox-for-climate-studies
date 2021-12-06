function [PEV,PEVprojected,PCprojected]=validateEOF(c,struct,varargin)
%Example:
%[PEVprojected,PCprojected]=validateEOF(c,{'dmnRef','dmnVal','file.ctl','startDate','endDate'},varargin)
%
%The %function projects data to be validated (typically from GCMs) on
%reference EOFs(typically from reanalysis data). Both the explained
%variance of the projected and unprojected PCs (y-axis)is plottet against
%the number of retained PCs (x-axis). The y axis is logarithmic, the x
%axis linear.
%
%%c = number of retained CPs in the semilogx plot
%dmnRef = Defines the domain for the reference EOFs.
%dmnVal = Defines the domain for the data to be validated.
%defines the variable to be validated (file.ctl, e.g. T850.ctl)
%startDate and endDate = period to be validated
%
%IMPORTANT: Remember to calculate the uncumulated PEV for the reference
%data (see: computeEOF.m) before calling this function.
%Otherwise it won't work.
%
%Input data must be given in the following format: X(t,i). 
% X(t,:) is the t-th element (observation) in the sample 
% X(:,i) is the temporal series of the i-th variable
% 
%
%	varargin	: optional parameters
%	    'path'	 -  ['path'] is a path to store the resulting variables. If no path
%		'prestd' -  [{'yes'} | 'no']. Preprocesses the data set fields so that they have zero mean 
%                   and standard deviation of 1 at each grid point.
%
%
disp('Loading EOF and uncumulated PEV for X data...');
dmn=readDomain(struct{1});
dates={struct{4},struct{5}};
[EOF,PC,MN,DV,PEV]=getEOF(dmn,'dates',dates);
%
disp('Loading Y data...');
dmn = readDomain(struct{2});
ctl.cam=dmn.src;
ctl.fil=struct{3};
%dates={'01-Jan-1960','31-Dec-1999'};
[Y,dmn]=getFieldfromGRIB(ctl,dmn,'dates',dates);
%
cam=[];
pst='yes';
for i=1:2:length(varargin)
   switch lower(varargin{i}),
   case 'path', cam = varargin{i+1};
   case 'prestd', pst = varargin{i+1};
   end
end
MNtest=zeros([1,size(Y,2)]);
DVtest=ones([1,size(Y,2)]);
if strcmp(pst,'yes')
    disp('Standartizing Y data...');
    for i=1:size(Y,2),
        [Y(:,i),MNtest(:,i),DVtest(:,i)] = pstd(Y(:,i));
    end
end
%
disp('Projecting Y data on formerly loaded of Ref. data...');
PCprojected=Y*EOF;
PEVprojected=(var(PCprojected)./sum(var(PCprojected))).*100;
%Matrix of transformed Data
PEVprojected=PEVprojected';
if ~isempty(cam),
   disp([cam]);
   disp('Saving files...');
   eval(['save ' cam 'PEVprojected.mat PEVprojected']);
   eval(['save ' cam 'PCprojected.mat PCprojected']);
end
%use c to truncate the PC for visualizing purposes
semilogy(PEV(1:c,1));
hold all;
semilogy(PEVprojected(1:c,1));
set(gca,'xlim',[0 c]);
ylabel ('Explained Variance (%)')
xlabel ('Number of PCs');
