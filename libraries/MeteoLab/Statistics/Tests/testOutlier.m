function [data,outlier,indices,RI]=testOutlier(data,varargin)
% [data,outlier,indices,RI]=testOutlier(data,varargin) 
% test to find outliers
% 
% Input
% 	data        : Daily data series.
% 	varargin	: optional parameters
%     'range'   - range of the normal values
%     'variable'- special case of precipitation.
% 	
% Output    
%   data        : data without outliers.
% 	outlier     : value of the outlier.
%   indices     : position of the outlier in the serie.
%   RI          : intercuartilic range.
% 
% Examples
% 
% 		[data,outlier,indices]=testOutlier(data,'range',3,'variable','precipitacion')

rg=4;
variable='';
for i=1:2:length(varargin)
    switch lower(varargin{i}),
        case 'range', rg=varargin{i+1};
        case 'variable', variable=varargin{i+1};
    end
end
outlier=[];
indices=[];
RI=[];
switch(variable)
    case {'precipitacion','precipitation'}
        for i=1:size(data,2)
            % ind=intersect(find(data(:,i)~=0),find(~isnan(data(:,i))));
            ind=find(data(:,i)>0 & ~isnan(data(:,i)));
			if isempty(ind)
                RI=[RI;NaN];
            else
                dato=sqrt(data(ind,i));
                inferior=0;
                superior=prctile(dato,90);
                RI=[RI;superior-inferior];
                index=union(ind(find(dato<inferior)),ind(find(dato>(superior+rg*RI(i)))));
                indices=[indices;index i*ones(length(index),1)];
                outlier=[outlier;data(index,i)];
                data(index,i)=NaN;
            end
        end
    otherwise
        for i=1:size(data,2)
            ind=find(~isnan(data(:,i)));
            if isempty(ind)
                RI=[RI;NaN];
            else
                dato=data(ind,i);
                inferior=prctile(dato,25);
                superior=prctile(dato,75);
                RI=[RI;superior-inferior]; 
                index=union(ind(find(dato<(inferior-rg*RI(i)))),ind(find(dato>(superior+rg*RI(i)))));
                index=index(:);
                if ~isempty(index)
                    indices=[indices;index i*ones(length(index),1)];
                    outlier=[outlier;data(index,i)];
                    data(index,i)=NaN;
                end
            end
        end
end