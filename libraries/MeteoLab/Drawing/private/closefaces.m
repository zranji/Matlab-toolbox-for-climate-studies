function [lat,lon] = closefaces(latin,lonin)
%CLOSEFACES closes all faces of a polygon

%  Copyright 1996-2002 Systems Planning and Analysis, Inc. and The MathWorks, Inc.
%  $Revision: 1.3 $    $Date: 2002/03/20 21:26:42 $

[lat,lon]=deal(latin,lonin);

if ~iscell(lat)
   [lat,lon]=polysplit(lat,lon);      
end
   
   
for i=1:length(lat)
   [latface,lonface]=deal(lat{i},lon{i});
   [latfacecell,lonfacecell]=polysplit(latface,lonface);
      
   for j=1:length(latfacecell)
      
      % close open polygons        
      if latfacecell{j}(1) ~= latfacecell{j}(end) | lonfacecell{j}(1) ~= lonfacecell{j}(end)
         latfacecell{j}(end+1)=latfacecell{j}(1);
         lonfacecell{j}(end+1)=lonfacecell{j}(1);
      end
      
   end
   
   
   [lat{i},lon{i}]=polyjoin(latfacecell,lonfacecell);
   
end

if ~iscell(latin)
   [lat,lon] = polyjoin(lat,lon);
end

      
