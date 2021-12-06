
%Function to convert a continuous variable into a categoric one, depending
%on the type of percentil we want to work with, ie, terciles, quintiles...
%[cate numcate]=Categoric(data,percentil)
%For instance, if we work with terciles, 'Categoric' assigns itself, by
%columns, a value '1', '2' or '3' to each data of the column if it belongs
%to the first tercil, second or third, respectively. These values are
%stored in the matris 'cate'. 'numcate' gives the number of data there are
%in each percentil.
%matrix 'data' m*n, where m is the numeber of observations (forecasts)
%and n the number of sites
%'percentil' is a vector defining the type of percentil we want to work
%with, ie, if we are interested about terciles, 'percentil' would be
%100*[1/3 2/3]

function [cate numcate]=Categoric(data,percentil)
   
        cate=zeros(size(data,1),size(data,2))*NaN;
        cate(:,:)=length(percentil)+1;
        numcate=zeros(length(percentil)+1,size(data,2))*NaN;
        indnonans=[];
        ind=[];

        for i=1:size(data,2)      
            for s=1:size(data,1)
                if isnan(data(s,i))==1;
                    cate(s,i)=NaN;
                end
            end
            nmaxi=max(data(:,i));
            nmini=min(data(:,i));   
            if nmaxi==nmini 
               cate(:,i)=NaN;
            end
            indnonans=find(isnan(data(:,i))==0);
            treshold(:,i)=prctile(data(indnonans,i),percentil);
            maxtresh=max(treshold(:,i));
            mintresh=min(treshold(:,i)); 
            if maxtresh==mintresh
               cate(:,i)=NaN;
            end 
            catnum=[length(percentil):-1:1];  
            for j=1:length(percentil) 
                ind=find(data(:,i)<treshold(catnum(j),i));
                cate(ind,i)=catnum(j);
            end
           
            for j=1:(length(percentil)+1)
                numcate(j,i)=length(find(cate(:,i)==j));
            end
        end
end


    