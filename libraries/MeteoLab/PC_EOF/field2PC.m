function [PC, Xp] = field2PC(X,EOF,MN,DV)
%Field2PC(X,EOF,MN,DV)
%
%Computes the Principal Components in columns: PC(:,1) is the first PC 
%corresponding to X (e.g. GCM).
% X(t,:) is the t-th element (observation) in the sample
% X(:,i) is the temporal series of the i-th variable
% EOF,MN,DV are the outputs returned by 'computeEOF' (e.g. REANALYSIS)

%DV(DV == 0) = 1; %dealing with constant fields
Xp = (X - repmat(MN,size(X,1),1)) ./ repmat(DV,size(X,1),1); %standardized field
PC = Xp*EOF;
