addpath(genpath('data'));
clc
clear
close all
% load data
load Ripley.mat

%%  Linear FR-TSVM

Parameter.ker='linear';
Parameter.CC=0.25  ;
Parameter.CR= 2^-8;
Parameter.v=10;
Parameter.algorithm='CD';    

% Training
[frtsvm_struct] = frtsvmtrain(traindata,trainlabel,Parameter);
% Testing 
acc = frtsvmclass(frtsvm_struct,testdata,testlabel);
% visualization
frtsvmplot(frtsvm_struct,traindata,trainlabel);


% Nonlinear FR-TSVM
Parameter.ker='rbf';
Parameter.CC=8;
Parameter.CR=1;
Parameter.p1=0.2;
Parameter.v=10;
Parameter.algorithm='CD';   

% Training
[frtsvm_struct] = frtsvmtrain(traindata,trainlabel,Parameter);
% Testing 
acc= frtsvmclass(frtsvm_struct,testdata,testlabel);
% visualization
frtsvmplot(frtsvm_struct,traindata,trainlabel);



