function [wtseries,z,d,f,zw,zs,w,s] = lambtyping(X,center,varargin)
%% lambtyping.m calculates automated Lamb weather types as defined in Trigo
%% & daCamara 2000 and Jones et al. 2012, both Int J Climatol
%%
%% Input: X = data matrix of MSLP values, units: Pa, NOT hPa/mbar!!!, rows = dates (one value per day), columns = grid points 
%%        loc = grid-points definining the "cross", must be a row vector ordered like this
%%              (from left to right i.e. from first to 16st column):
%%
%%
%%           01    02
%%     03    04    05    06
%%     07    08    09    10
%%     11    12    13    14
%%           15    16
%%
%% 
%% where the north-south (west-east) distance is 5º (10º)
%%
%% Output:
%% wtseries = column vector of discrete weather types defined as follows:
%%
%% purely anticyclonic = 1
%% directional anticyclonic from NE to N = 2 to 9
%% purely directional from NE to N = 10 to 17
%% purely cyclonic = 18
%% directional cyclonic from NE to N = 19 to 26
%% light indeterminate flow N = 27
%%
%% [z, d, f, zw, zs, w, s] are circulation indices as defined in
%% Jones et al. 2012, Int J Climatol
%follow Jones et al. 2012, Int. J. Climatol., last page

loc=[];indOrder=[];
for i=1:2:length(varargin)
	switch lower(varargin{i}),
		case 'location', loc=varargin{i+1};
		case 'order', indOrder=varargin{i+1};
		otherwise
			warning(sprintf('Option ''%s'' not defined',varargin{i}))
	end
end
ndata=size(X,1);
z=repmat(NaN,ndata,1);d=repmat(NaN,ndata,1);f=repmat(NaN,ndata,1);
zw=repmat(NaN,ndata,1);zs=repmat(NaN,ndata,1);w=repmat(NaN,ndata,1);
s=repmat(NaN,ndata,1);wtseries=repmat(NaN,ndata,1);dirdeg=repmat(NaN,ndata,1);
if isempty(indOrder) & isempty(loc),
	indOrder=[1:16];
elseif isempty(indOrder) & ~isempty(loc),
	crossLocation=repmat(center,16,1)+[-5 10;5 10;-15 5;-5 5;5 5;15 5;-15 0;-5 0;5 0;15 0;-15 -5;-5 -5;5 -5;15 -5;-5 -10;5 -10];
	[indOrder,distOrder]=MLknn(crossLocation,loc,1,'Norm-2');
end
centerlat=center(2);
sfconst= 1/cosd(centerlat);
zwconst1 = sind(centerlat)/sind(centerlat - 5);
zwconst2 = sind(centerlat)/sind(centerlat + 5);
zsconst = 1/(2*cosd(centerlat)^2);
%FORTRAN code from Colin Harpham, CRU
w=0.005*(nansum(X(:,indOrder([12,13])),2)-nansum(X(:,indOrder([4 5])),2));
s=(sfconst*0.0025)*(X(:,indOrder(5))+2*X(:,indOrder(9))+X(:,indOrder(13))-X(:,indOrder(4))-2*X(:,indOrder(8))-X(:,indOrder(12)));
ind=find(abs(w)> 0 & ~isnan(w));
dirdeg(ind)=atand(s(ind)./w(ind));
ind=find(w==0 & ~isnan(w));
ind1=intersect(ind,find(s > 0 & ~isnan(s)));dirdeg(ind1) = 90;
ind1=intersect(ind,find(s < 0 & ~isnan(s)));dirdeg(ind1) = -90;
d(find(w>=0 & ~isnan(w)))=270-dirdeg(find(w>=0 & ~isnan(w))); %SW & NW quadrant
d(find(w<0 & ~isnan(w)))=90-dirdeg(find(w<0 & ~isnan(w))); %SE & NE quadrant
%westerly shear vorticity
zw = (zwconst1*0.005)*(nansum(X(:,indOrder([15 16])),2)-nansum(X(:,indOrder([8 9])),2))-(zwconst2*0.005)*(nansum(X(:,indOrder([8 9])),2)-nansum(X(:,indOrder([1 2])),2));
%southerly shear vorticity
zs = (zsconst*0.0025)*(X(:,indOrder(6))+2*X(:,indOrder(10))+X(:,indOrder(14))-X(:,indOrder(5))-2*X(:,indOrder(9))-X(:,indOrder(13)))-(zsconst*0.0025)*(X(:,indOrder(4))+2*X(:,indOrder(8))+X(:,indOrder(12))-X(:,indOrder(3))-2*X(:,indOrder(7))-X(:,indOrder(11)));
%total shear vorticity
z = zw+zs; %total shear vorticity
f = sqrt(w.^2+s.^2); %resultant flow
guk = sqrt(f.^2+0.25*z.^2);% Esto no se usa para nada

%define direction sectors form 1 to 8, definition like on http://www.cru.uea.ac.uk/cru/data/hulme/uk/lamb.htm
neind = find(d > 22.5 & d <= 67.5); %NE
eind = find(d > 67.5 & d <= 112.5); %E
seind = find(d > 112.5 & d <= 157.5); %SE
soind = find(d > 157.5 & d <= 202.5); %S
swind = find(d > 202.5 & d <= 247.5); %SW
wind = find(d > 247.5 & d <= 292.5); %W
nwind = find(d > 292.5 & d <= 337.5); %NW
nind = find(d > 337.5 | d <= 22.5); % N
d(neind) = 10; d(eind) = 11; d(seind) = 12; d(soind) = 13;
d(swind) = 14; d(wind) = 15; d(nwind) = 16; d(nind) = 17;

%% Define discrete wt series, codes similar to http://www.cru.uea.ac.uk/cru/data/hulme/uk/lamb.htm
pd = find(abs(z) < f);wtseries(pd) = d(pd); %purely directional type
pcyc = find(abs(z) >= (2*f) & z >= 0);wtseries(pcyc) = 18; %purely cyclonic type
pant = find(abs(z) >= (2*f) & z < 0);wtseries(pant) = 1; %purley anticyclonic type
hyb = find(abs(z) >= f & abs(z) < (2*f)); %hybrid type
hybant = intersect(hyb,find(z < 0)); %anticylonic
hybcyc = intersect(hyb,find(z>= 0)); %cyclonic
for i=10:17
	%directional anticyclonic
	wtseries(intersect(hybant,find(d==i))) = i-8;
	%mixed cyclonic
	wtseries(intersect(hybcyc,find(d==i))) = i+9;
end
indFlow = find(abs(z) < 6 & f < 6);wtseries(indFlow) = 27;% indeterminate

