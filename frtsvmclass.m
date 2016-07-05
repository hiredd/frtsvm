function [acc,outclass,f,fp,fn,ExpendTime]= frtsvmclass(frtsvm_struct,Testdata,Testlabel)
%  Author: Bin-Bin Gao 
%  Email:csgaobb@gmail.com
%  July 5, 2016

% check correct number of arguments
if ( nargin>3||nargin<2) 
    help frtsvmclass
else
    [rt,ct]=size(Testdata);
    
    st1 = cputime;
    if ~isempty(frtsvm_struct.scaleData)
        scaleData=frtsvm_struct.scaleData;
        for k = 1:size(Testdata, 2)
            Testdata(:,k) = scaleData.scaleFactor(k) * ...
                (Testdata(:,k) +  scaleData.shift(k));
        end
    end
    
    
    groupString=frtsvm_struct.groupString;
    vp=frtsvm_struct.vp;
    vn=frtsvm_struct.vn;
    
    X=frtsvm_struct.X;
    
    
    kfun =frtsvm_struct.KernelFunction;
    kfunargs = frtsvm_struct.KernelFunctionArgs;
    
    fprintf('Testing ...\n');
    switch frtsvm_struct.Parameter.ker
        case 'linear'
            fp=(Testdata*vp(1:(length(vp)-1))+vp(length(vp)))./norm(vp(1:(length(vp)-1)));
            fn=(Testdata*vn(1:(length(vn)-1))+vn(length(vn)))./norm(vn(1:(length(vn)-1)));
        case 'rbf'
            K = feval(kfun,Testdata,X,kfunargs{:});
            fp=(K*vp(1:(length(vp)-1))+vp(length(vp)))./norm(vp(1:(length(vp)-1)));
            fn=(K*vn(1:(length(vn)-1))+vn(length(vn)))./norm(vn(1:(length(vn)-1)));
    end
    f=fp+fn;
    
    classified=ones(rt,1);
    classified(abs(fp)>abs(fn)) = -1;
    classified(classified == -1) = 2;
    
    outclass = classified;
    unClassified = isnan(outclass);
    [~,groupString,glevels] = grp2idx(frtsvm_struct.L);
    
    outclass = glevels(outclass(~unClassified),:);
    
    if nargin==3
        correct=sum(outclass==Testlabel);
        acc=100*correct/length(Testlabel);
        fprintf('Accuracy : %3.4f (%d/%d)\n',acc,correct,length(Testlabel));
    else
        acc=[];
        fprintf('the accuracy can not be calculated, because of lack of the labels of testing data\n');
    end
    ExpendTime= cputime-st1;
end
