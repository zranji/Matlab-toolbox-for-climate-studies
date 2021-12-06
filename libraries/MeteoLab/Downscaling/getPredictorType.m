function [type,ncps,nnns] = getPredictorType(method)

type = 'PC';
ncps = -1;
nnns = 0;

if isfield(method,'properties')
     props = method.properties;
     ncps = 0;
     nnns = 0;
     if isfield(props,'NumberOfPCs')
       if isnumeric(props.NumberOfPCs)
           ncps = props.NumberOfPCs;
       else
           ncps = str2double(props.NumberOfPCs);
       end
     end  
     if isfield(props,'NumberOfNearestNeighbours')
       if isnumeric(props.NumberOfNearestNeighbours)
         nnns = props.NumberOfNearestNeighbours;
       else
         nnns = str2double(props.NumberOfNearestNeighbours);
       end
     end
     if ncps>0 && nnns>0
        type = 'PCFIELDS';
     end
     if ncps<=0 && nnns>0
        type = 'FIELDS';
     end
     if isfield(method.properties,'ClusteringMethod') && strcmp(type,'FIELDS')
        % clusterings are always computed with PCs if ncps>0
        if ~strcmpi(method.properties.ClusteringMethod,'none') && ncps>0
           type = 'PCFIELDS';
        end
     end
end

