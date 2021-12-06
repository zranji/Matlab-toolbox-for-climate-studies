function y=stepcmp(steps,step,form)
if form==0
    steps=stepvec(steps);
    step=stepvec(step);
end
[bloque,escala]=max(step);
[aux,a,b]=unique(steps,'rows');
y=zeros(size(steps,1),1);
for i=1:length(a)
    [bloque1,escala1]=max(aux(i,:));
    if escala1>escala
        y(find(b==i))=1;
    elseif escala1==escala
        if bloque1>bloque
            y(find(b==i))=-1;
        elseif bloque1==bloque
            y(find(b==i))=0;
        else
            y(find(b==i))=1;
        end
    else
        y(find(b==i))=-1;
    end
end