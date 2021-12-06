function str=gzload(name)
if (isempty(dir(name)))
   if (~isempty(dir([name '.gz'])))
   		eval(['!gunzip -c ' name '.gz ' '>' name]);  
   else
      error([name ' not found.']);
   end
end
if nargout==1
   str=load(name);
else
	evalin('base',['load(''' name ''')'])   
end

if (~isempty(dir([name '.gz'])))
   delete(name);  
end



