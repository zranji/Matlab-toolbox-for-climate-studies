function Clustering=makeClustering(Data,Type,NumberCenters,varargin)
%Clustering=makeClustering(Data,Type,N)
%	Make clustering from DATA. TYPE can be 'kmeans' or 'som'. 
%	If TYPE='som' you will indicate a 2D-SOM making N=[NX NY],
%	If TYPE='kmeans' you will indicate the number of centers with N.
%	The function return a structure with the next fields:
%
%	Clustering.NumberCenters: Number of Centers of the Clustering
%	Clustering.Type: Type of Clustering ('kmeans' or 'som')
%	Clustering.Centers: Centers or Prototypes of the Clustering
%	Clustering.PatternsGroup: Cluster that belongs each pattern in Data (by rows)
%	Clustering.PatternDistanceGroupCenter: Distance of each pattern to the center of the cluster
%	Clustering.SizeGroup: Size of each cluster
%	Clustering.Group: Patterns from DATA that belongs to each cluster.
%
%  AIMet Group, 2003 Santander

loc=[];shape='sheet';center=[-5 40];
if nargin==4
	shape=varargin{1};
else
	for i=1:2:length(varargin)
		switch lower(varargin{i}),
			case 'location', loc=varargin{i+1};
			case 'center', center=varargin{i+1};
			case 'shape', shape=varargin{i+1};
			otherwise
				warning(sprintf('Option ''%s'' not defined',varargin{i}))
		end
	end
end

switch lower(Type),
	case 'lamb',type='Lamb';Clustering.Type=type;
		disp('Computing Lamb weather types...')
		wtseries=lambtyping(Data,center,'location',loc);[wtseries,I,Clustering.PatternsGroup]=unique(wtseries);
		Clustering.Centers=Data(I,:);
		Clustering.lambCenter=center;Clustering.Location=loc;
		Clustering.NumberCenters=length(wtseries);Clustering.PatternDistanceGroupCenter=repmat(NaN,length(Clustering.PatternsGroup),1);
		ncenters=Clustering.NumberCenters;Clustering.SizeGroup=cell(ncenters,1);
        for k=1:ncenters,
            iC=find(Clustering.PatternsGroup==k);
            Clustering.SizeGroup{k,1}=length(iC);
            if(~isempty(iC))
                ind=find(~isnan(nanmean(Data(iC,:),1)));
                [c,aux1]=kmeans(Data(iC,ind),1);
                Clustering.Centers(k,ind)=aux1;
                Clustering.PatternDistanceGroupCenter(iC)=nansum((Data(iC,:)-repmat(Clustering.Centers(k,:),length(iC),1)).^2,2);
                Clustering.Group{k,1}=iC;
            else
                Clustering.Group{k,1}=[];
            end
        end
	otherwise
		if strcmpi(Type,'som')
			type='SOM';
			disp('Training SOM...')
			Clustering.NumberCenters=NumberCenters;
			Clustering.Type=type;Clustering.Shape=shape;
			ncenters=prod(Clustering.NumberCenters);
			sMap = som_make(Data,'msize', NumberCenters,'neigh','ep','lattice','rect','training',[10,100],'shape',shape); 
			Clustering.Centers=sMap.codebook;  
		end
		if strcmpi(Type,'kmeans')
			type='KMeans';
			Clustering.NumberCenters=prod(NumberCenters);
			Clustering.Type=type;Clustering.Shape=shape;
			ncenters=Clustering.NumberCenters;
			disp('Training k-Means...')
			[c,Clustering.Centers]=kmeans(Data,Clustering.NumberCenters);
		end
		[Clustering.PatternsGroup,Clustering.PatternDistanceGroupCenter]=MLknn(Data,Clustering.Centers,1,'Norm-2');
		for k=1:ncenters
			iC=find(Clustering.PatternsGroup(:,1)==k);
			Clustering.SizeGroup{k,1}=length(iC);
			if(~isempty(iC))
				Clustering.Group{k,1}=iC(:)';
			else
				Clustering.Group{k,1}=[];
			end
		end
end
