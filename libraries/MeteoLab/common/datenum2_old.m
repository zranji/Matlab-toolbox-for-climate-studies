function d=datenum2(D,DF)
%d=datenum2(D,DF)
%	Function with equal behaviour like datenum, but the serial number is in DF units
%	(the units in datenum are days)
%

if isstr(D)
   d=datenum(D);
else
   if (size(D,2)==3)
      d=datenum(D(:,1),D(:,2),D(:,3));
   else
      d=datenum(D(:,1),D(:,2),D(:,3),D(:,4),D(:,5),D(:,6));
   end
end

if isstr(DF)
   df=datenum(DF);
else
   if (size(DF,2)==3)
      df=datenum(DF(:,1),DF(:,2),DF(:,3));
   else
      df=datenum(DF(:,1),DF(:,2),DF(:,3),DF(:,4),DF(:,5),DF(:,6));
   end
end

d=round(d./df);