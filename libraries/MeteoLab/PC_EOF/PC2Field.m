function Field = PC2Field(PC,EOF,MN,DV)
%PC2Field(X,EOF,MN,DV)
%
%Computes the reconstructed field from Principal Components in columns: PC(:,1) is the first PC
% EOF,MN,DV are the outputs returned by 'computeEOF'

Xp = PC*EOF';  %standardized field
Field = (Xp .* repmat(DV,size(Xp,1),1)) + repmat(MN,size(Xp,1),1); %back to standard units