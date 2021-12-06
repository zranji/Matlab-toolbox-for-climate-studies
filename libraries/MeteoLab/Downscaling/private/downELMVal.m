function [Y] = downELMVal(elm_model,P)

% Input:
% elm_mode     - ELM model
% P            - Predictand test matrix (samples x features)
%
% Output: 
% Y            - Prediction
%
% MULTI-CLASSE CLASSIFICATION: NUMBER OF OUTPUT NEURONS WILL BE AUTOMATICALLY SET EQUAL TO NUMBER OF CLASSES
% FOR EXAMPLE, if there are 7 classes in all, there will have 7 output
% neurons; neuron 5 has the highest output means input belongs to 5-th class
%
    %%%%    Authors:    MR QIN-YU ZHU AND DR GUANG-BIN HUANG
    %%%%    NANYANG TECHNOLOGICAL UNIVERSITY, SINGAPORE
    %%%%    EMAIL:      EGBHUANG@NTU.EDU.SG; GBHUANG@IEEE.ORG
    %%%%    WEBSITE:    http://www.ntu.edu.sg/eee/icis/cv/egbhuang.htm
    %%%%    DATE:       APRIL 2004


%%%%%%%%%%% Load testing dataset
P = P';

NumberofTestingData=size(P,2);

%%%%%%%%%%% Calculate the output of testing input
tempH_test=elm_model.InputWeight*P;
clear P;             %   Release input of testing data             
ind=ones(1,NumberofTestingData);
BiasMatrix=elm_model.BiasofHiddenNeurons(:,ind);              %   Extend the bias matrix BiasofHiddenNeurons to match the demention of H
tempH_test=tempH_test + BiasMatrix;
switch lower(elm_model.ActivationFunction)
    case {'sig','sigmoid'}
        %%%%%%%% Sigmoid 
        H_test = 1 ./ (1 + exp(-tempH_test));
    case {'sin','sine'}
        %%%%%%%% Sine
        H_test = sin(tempH_test);        
    case {'hardlim'}
        %%%%%%%% Hard Limit
        H_test = hardlim(tempH_test);        
        %%%%%%%% More activation functions can be added here        
end
TY=(H_test' * elm_model.OutputWeight)';

Y = NaN(NumberofTestingData,1);
if strcmp(elm_model.type,'classifier')
    for i = 1 : size(TY, 2)
        [x, label_index_actual]=max(TY(:,i));
        Y(i)=elm_model.label(label_index_actual);
    end
else
    Y = TY';
end
