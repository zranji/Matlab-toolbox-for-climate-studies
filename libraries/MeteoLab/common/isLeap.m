function res=isLeap(YY)
if (~mod(YY,4) & (mod(YY,100) | ~mod(YY,400)))
   res=1;
else
   res=0;
end
