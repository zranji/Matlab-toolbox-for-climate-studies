function d=dn2dn(s,DF)
%d=dn2dn(S,DF)
%	Converts from datenum2 to datenum
%

if isstr(DF)
   df=datenum(['00-Jan-0000 ' DF]);
else
   if (size(DF,2)==3)
      df=datenum(DF(:,1),DF(:,2),DF(:,3));
   else
      df=datenum(DF(:,1),DF(:,2),DF(:,3),DF(:,4),DF(:,5),DF(:,6));
   end
end

d=s.*df;