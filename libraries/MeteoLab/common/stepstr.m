function y=stepstr(period,form)
if nargin<2
    form=0;
end

y=[];
for i=1:size(period,1)
    a=find(period(i,:)~=0);
    switch(a)
        case(1)
            y=char(y,[num2str(period(i,a)) 'Y']);
        case(2)
            y=char(y,[num2str(period(i,a)) 'M']);
        case(3)
            y=char(y,[num2str(period(i,a)) 'D']);
        case(4)
            switch(form)
                case(0)
                    y=char(y,[num2str(period(i,a)) 'h']);
                case(1)
                    y=char(y,[num2str(period(i,a)) ':00:00']);
            end
        case(5)
            switch(form)
                case(0)
                    y=char(y,[num2str(period(i,a)) 'm']);
                case(1)
                    y=char(y,['00:' num2str(period(i,a)) ':00']);
            end
        case(6)
            switch(form)
                case(0)
                    y=char(y,[num2str(period(i,a)) 's']);
                case(1)
                    y=char(y,['00:00:' num2str(period(i,a))]);
            end
    end
end
y=y(2:end,:);