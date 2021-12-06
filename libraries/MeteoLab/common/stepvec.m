function y=stepvec(period)

if(isstr(period))
    period=cellstr(period);
end
y=zeros(size(period,1),6);
for i=1:length(period)
    periodo=strvcat(period(i));
    aux=findstr(periodo,':');
    if ~isempty(aux)
        if length(aux)>1
            D=0;
            h=str2num(periodo(1:aux(1)-1));if mod(h,24)==0 D=h/24;h=0;end
            m=str2num(periodo(aux(1)+1:aux(2)-1));
            s=str2num(periodo(aux(2)+1:end));
            y(i,3:end)=[D h m s];
        else
            D=0;
            h=str2num(periodo(1:aux(1)-1));if mod(h,24)==0 D=h/24;h=0;end
            m=str2num(periodo(aux(1)+1:end));
            y(i,3:5)=[D h m];
        end
    else
        if(~isnan(str2double(periodo)))
            periodo=[periodo 'h'];
        end
        switch (periodo(end))
            case ('Y')
                y(i,1)=str2num(periodo(1:end-1));
            case ('M')
                y(i,2)=str2num(periodo(1:end-1));
            case ('D')
                y(i,3)=str2num(periodo(1:end-1));
            case {'h','H'}
                y(i,4)=str2num(periodo(1:end-1));
            case ('m')
                y(i,5)=str2num(periodo(1:end-1));
            case ('s')
                y(i,6)=str2num(periodo(1:end-1));
        end
    end
end
