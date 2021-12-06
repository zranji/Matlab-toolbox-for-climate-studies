function S=par2struct(S,lin,tok,num)
%Function to process a line to a struct, tokenized by tok
% mas=1;
% while(mas)
%    [t, lin] = strtok(lin, ',');
%    if(isempty(t))
%       t=lin;
%       mas=0;
%    end
%    [t2,r2] = strtok(t,'=');
%    if(~isempty(t2))
%       campo=deblank(fliplr(deblank(fliplr(t2))));
%       valor=deblank(fliplr(deblank(fliplr(r2(2:end)))));
%       if(~isfield(S,campo))
%          error([campo ' is not field of struct']);
%       end
%       
%       switch(campo)
%          case num
%             valor=str2num(valor);            
%       end
%       %sprintf(':%s:%s:',campo,valor)   
%       S=setfield(S,campo,valor);
%    end
% end

[f,v]=strread(lin,'%s%s','whitespace','=','endofline',tok);
for i=1:length(f)
    switch f{i}
        case num
            S.(f{i})=str2num(v{i});
        otherwise
            S.(f{i})=v{i};
    end
end

