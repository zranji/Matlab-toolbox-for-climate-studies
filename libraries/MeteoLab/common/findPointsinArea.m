function inod = findPointsinArea(nod,xlim,ylim)
%inod = findPointsinArea(nod,xlim,ylim)
%
%Function that extracts from 'nod' all the points that fall within the geographic area 
%determined by 'xlim' and 'ylim'.
%'nod' must be given as a matrix n*2, in which the first column corresponds to the longitude
%and the second to the latitude.
%'inod' are the indices that indicates these points within 'nod'
xlim = sort(xlim);
ylim = sort(ylim);

inod = intersect(find(nod(:,1) >= xlim(1) & nod(:,1) <= xlim(2) == 1), find(nod(:,2) >= ylim(1) & nod(:,2) <= ylim(2) == 1));
end
