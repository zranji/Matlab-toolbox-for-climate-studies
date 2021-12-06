clc
clear
close all
var2={'CC','Rsquared'};
var={'RMSD','RMSE','Bias'};
mat=dir('*.mat');
param={'hurs','psl','tas','theta','u'};
hj=0;pj=0;tj=0;thj=0;uj=0;
for j=1:size(mat,1)
    if contains(mat(j).name,'hurs')
       hj=hj+1;
       h=load(mat(j).name);
       hurs(:,:,hj)=table2array(h.T(:,1:7));
    elseif contains(mat(j).name,'psl')
       pj=pj+1;
       p=load(mat(j).name);
       psl(:,:,pj)=table2array(p.T(:,1:7));        
    elseif contains(mat(j).name,'tas')
       tj=tj+1;
       t=load(mat(j).name);
       tas(:,:,tj)=table2array(t.T(:,1:7));
    elseif contains(mat(j).name,'theta')
       thj=thj+1;
       th=load(mat(j).name);
       theta(:,:,thj)=table2array(th.T(:,1:7));
    elseif contains(mat(j).name,'u')
       uj=uj+1;
       U=load(mat(j).name);
       u(:,:,uj)=table2array(U.T(:,1:7));
    end
end
hursm=array2table(mean(hurs,3),'VariableNames',h.T.Properties.VariableNames(1:7));
hurs=[hursm table({'Synope';'CFSR'},'VariableNames',{'name'})];
pslm=array2table(mean(psl,3),'VariableNames',p.T.Properties.VariableNames(1:7));
psl=[pslm table({'Synope';'CERA';'CFSR';'ERA5';'Interim'},'VariableNames',{'name'})];
tasm=array2table(mean(tas,3),'VariableNames',t.T.Properties.VariableNames(1:7));
tas=[tasm table({'Synope';'CERA';'CFSR';'ERA5';'Interim'},'VariableNames',{'name'})];
thetam=array2table(mean(theta,3),'VariableNames',th.T.Properties.VariableNames(1:7));
theta=[thetam table({'Synope';'CERA';'CFSR';'ERA5';'Interim'},'VariableNames',{'name'})];
um=array2table(mean(u,3),'VariableNames',U.T.Properties.VariableNames(1:7));
u=[um table({'Synope';'CERA';'CFSR';'ERA5';'Interim'},'VariableNames',{'name'})];
cd mean
save('statistics-hurs.mat','hurs');
save('statistics-psl.mat','psl');
save('statistics-tass.mat','tas');
save('statistics-theta.mat','theta');
save('statistics-u.mat','u');


matt=dir('statistics*.mat');
for i=1:size(matt,1)
    clear state statenorm
     state=load(matt(i).name);
    for j=1:3      
        statemin=min(abs(state.(param{i}).(var{j})));
        statemax=max(abs(state.(param{i}).(var{j})));
        state.(param{i}).(var{j})=(abs(state.(param{i}).(var{j})-statemin))/(statemax-statemin);
    end
    for jj=1:2      
        statemin=min(abs(state.(param{i}).(var2{jj})));
        statemax=max(abs(state.(param{i}).(var2{jj})));
        state.(param{i}).(var2{jj})=1-state.(param{i}).(var2{jj});
    end 
%     idx = contains(state.T.name,'ERA');
%     state.T(idx,:) = [];
%     idy = strcmp(state.T.name,'CFSR');
%     state.T(idy,:) = [];  
    statenorm=[state.(param{i}).('CC') state.(param{i}).('Rsquared') state.(param{i}).('RMSD') state.(param{i}).('RMSE') state.(param{i}).('Bias')];
    subplot(3,2,i)    
    h=imagesc(1:size(state.(param{i}),1),1:5,statenorm');
    colormap(hot(20))
    caxis([0 1])
    ax = gca;
    ax.XTick=1:1:size(state.(param{i}),1);
    xticklabels(state.(param{i}).name)
%     ax.XTickLabelRotation=-90;
    ax.YTick=1:1:5;
    yticklabels({'CC','Rsquared','RMSD','RMSE','Bias'})
    str=split(matt(i).name,{'statistics-','.mat'});
    hold on
    for iii = 1:22
       plot([iii-.5,iii-.5],[.5,21.5],'k-');
    end
    hold on
    for jjj = 1:5
       plot([.5,21.5],[jjj-.5,jjj-.5],'k-');
    end
    title(str{2,1})
end
