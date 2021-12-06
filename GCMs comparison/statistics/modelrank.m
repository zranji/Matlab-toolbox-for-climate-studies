function [ ] = modelrank(statm,k,param,reanl)
statm=statm(1:end,:);
reanl=reanl(1:end);
ind={'Mean','SD','RMSD','CC','Rsquared','RMSE','Bias'};
% indnd={'CC','Rsquared','RMSE','Bias'};
indnd={'SD','RMSD','Bias','CC'};
% reanl={'REANALYSIS',gcm};
na=size(reanl,2);
sz1=size(ind,2);
sz=size(indnd,2);

for i=1:na
    for j=1:sz1     
        if contains(ind{j},'SD') || contains(ind{j},'RMSD') || contains(ind{j},'Bias') || contains(ind{j},'CC')
            if contains(ind{j},'RMSD')
                jj=2;
            elseif contains(ind{j},'Bias')
                jj=3;
            elseif contains(ind{j},'CC')
                jj=4;
            else
                jj=1;
            end            
            statemin=min(abs(statm(:,j)));
            statemax=max(abs(statm(:,j)));
            state(i,jj)=(abs(statm(i,j)-statemin))./(statemax-statemin);
        end
    end
end
%     statenorm=[state.('CC') state.('Rsquared') state.('RMSD') state.('RMSE') state.('Bias')];
%     figure(fig)
%     subplot(3,2,k)
    r = 1:length(state(:,1));
    [~,ind1] = sort(state(:,1),'ascend'); % sorted from min to max
    r1(ind1)=r;
    [~,ind2] = sort(state(:,2),'ascend');
    r2(ind2)=r;
    [~,ind3] = sort(state(:,3),'ascend');
    r3(ind3)=r;
    [~,ind4] = sort(state(:,4),'ascend');
    r4(ind4)=r;
    txt={reanl{ind1};reanl{ind2};reanl{ind3};reanl{ind4}};
    x=repmat(1:na,sz,1);y=(repmat(1:sz,na,1))';
    t=num2cell([r1;r2;r3;r4]);
    subaxis(3,2,k)
    t=cellfun(@num2str, t, 'UniformOutput', false);
    
    h=imagesc(1:na,1:sz,state');
    text(x(:),y(:),t)
    colormap(hot(20))
    caxis([0 1])
    ax = gca;
    ax.XTick=1:1:na;
    xticklabels(reanl)
    ax.YTick=1:1:sz;
    yticklabels(indnd)
%     ytickangle(90)
%     xtickangle(90)
    hold on
    for iii = 1:na+1
       plot([iii-.5,iii-.5],[.5,na+1.5],'k-');
    end
    hold on
    for jjj = 1:na+1
        plot([.5,na+1.5],[jjj-.5,jjj-.5],'k-');
    end
    title(param)
    save(strcat(param,'.mat'),'t')
    save(strcat('reanl','.mat'),'reanl')
end
