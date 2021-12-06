function RP_Grid=makeGrid(data,loc,x,y,method)

switch method
	case 'nearest',
		[XP,YP]=meshgrid(x,y);
		RP_Grid = griddata(loc(:,1),loc(:,2),data',XP,YP,'nearest')';
		RP_Grid=RP_Grid(:);
	case 'interp',
		RP_Grid=single(1);
		RP_Grid(1:size(data,1),1:length(y)*length(x))=0;
		k=0;
		for j=1:length(y)
			for i=1:length(x)
				k=k+1;
				g=[x(i) y(j)];
				[lista,dd]=MLknn(g,loc,10,2);
				dd=1./dd.^2;dd=dd/sum(dd);
				b=repmat(dd,size(data(:,lista),1),1);
				a=nansum(data(:,lista).*b,2);
				RP_Grid(:,k)=a;  
			end
		end
end
