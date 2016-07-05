function  [frtsvm_struct] = frtsvmtrain(Traindata,Trainlabel,Parameter)
% [A,B,C_label,alpha,gama,z1,z2,ExpendTime,ExpendQPTime] = Tsvmtrain(train_data,train_label,ker,cp,p1,p2,ep)
% train_data 
% train_label 
% c1 c2 ˫
% p1 p2 ˫
%  Author: gaobin (gaobin@163.com)
if ( nargin>3||nargin<3) % check correct number of arguments
    help  ftsvmtrain
end

ker=Parameter.ker;
CC=Parameter.CC;
CR=Parameter.CR;
Parameter.autoScale=0;
Parameter.showplots=0;
autoScale=Parameter.autoScale;

% 1 
st1 = cputime;
[groupIndex, groupString] = grp2idx(Trainlabel);
groupIndex = 1 - (2* (groupIndex-1));
scaleData = [];
if autoScale
    scaleData.shift = - mean(Traindata);
    stdVals = std(Traindata);
    scaleData.scaleFactor = 1./stdVals;
    % leave zero-variance data unscaled:
    scaleData.scaleFactor(~isfinite(scaleData.scaleFactor)) = 1;
    % shift and scale columns of data matrix:
    for k = 1:size(Traindata, 2)
        scTraindata(:,k) = scaleData.scaleFactor(k) * ...
            (Traindata(:,k) +  scaleData.shift(k));
    end
else
    scTraindata= Traindata;
end

Xp=scTraindata(groupIndex==1,:);
Lp=Trainlabel(groupIndex==1);
Xn=scTraindata(groupIndex==-1,:);
Ln=Trainlabel(groupIndex==-1);
X=[Xp;Xn];
L=[Lp;Ln];
[sp,sn,NXpv,NXnv]=Gbbftsvm(Xp,Xn,Parameter);

lp=sum(groupIndex==1);
ln=sum(groupIndex==-1);
switch ker
    case 'linear'
        kfun = @linear_kernel;kfunargs ={};
    case 'quadratic'
        kfun = @quadratic_kernel;kfunargs={};
    case 'radial'
        p1=Parameter.p1;
        kfun = @rbf_kernel;kfunargs = {p1};
    case 'rbf'
        p1=Parameter.p1;
        kfun = @rbf_kernel;kfunargs = {p1};
    case 'polynomial'
        p1=Parameter.p1;
        kfun = @poly_kernel;kfunargs = {p1};
    case 'mlp'
        p1=Parameter.p1;
        p2=Parameter.p2;
        kfun = @mlp_kernel;kfunargs = {p1, p2};
end
switch ker
    case 'linear'
        Kpx=Xp;Knx=Xn;
    case 'rbf'
        Kpx = feval(kfun,Xp,X,kfunargs{:});%K(X+,X)
        Knx = feval(kfun,Xn,X,kfunargs{:});%K(X-,X)
end
S=[Kpx ones(lp,1)];R=[Knx ones(ln,1)];

CC1=CC*sn;%c1lb 
CC2=CC*sp;%c2lb 

fprintf('Optimising ...\n');
switch  Parameter.algorithm
    case  'CD'
        [alpha ,vp] =  L1CD(S,R,CR,CC1);
        [beta , vn] =  L1CD(R,S,CR,CC2);
        vn=-vn;
    case  'qp'
        QR=(S'*S+CR*eye(lp+ln+1))\R';
        RQR=R*QR;
        RQR=(RQR+RQR')/2;
        
        QS=(R'*R+CR*eye(lp+ln+1))\S';
        SQS=S*QS;
        SQS=(SQS+SQS')/2;

        [alpha,~,~]=qp(RQR,-ones(ln,1),[],[],zeros(ln,1),CC1,ones(ln,1));ftsvm_struct
        [beta,~,~] =qp(SQS,-ones(lp,1),[],[],zeros(lp,1),CC2,ones(lp,1));
        
        vp=-QR*alpha;
        vn=QS*gama;
    case  'QP'
        QR=(S'*S+CR*eye(size(S'*S)))\R';
        RQR=R*QR;
        RQR=(RQR+RQR')/2;
        
        QS=(R'*R+CR*eye(size(R'*R)))\S';
        SQS=S*QS;
        SQS=(SQS+SQS')/2;
        
        qp_opts = optimset('display','off');
        [alpha,~,~]=quadprog(RQR,-ones(ln,1),[],[],[],[],zeros(ln,1),CC1,zeros(ln,1),qp_opts);
        [beta,~,~]=quadprog(SQS,-ones(lp,1),[],[],[],[],zeros(lp,1),CC2,zeros(lp,1),qp_opts);
        
        vp=-QR*alpha;
        vn=QS*beta;
end
ExpendTime=cputime - st1;
frtsvm_struct.scaleData=scaleData;

frtsvm_struct.X = X;
frtsvm_struct.L = L;
frtsvm_struct.sp = sp;
frtsvm_struct.sn = sn;

frtsvm_struct.alpha = alpha;
frtsvm_struct.beta  = beta;
frtsvm_struct.vp = vp;
frtsvm_struct.vn = vn;

frtsvm_struct.KernelFunction = kfun;
frtsvm_struct.KernelFunctionArgs = kfunargs;
frtsvm_struct.Parameter = Parameter;
frtsvm_struct.groupString=groupString;
frtsvm_struct.time=ExpendTime;

frtsvm_struct.NXpv=NXpv;
frtsvm_struct.NXnv=NXnv;
frtsvm_struct.nv=length(NXpv)+length(NXnv);
if  Parameter.showplots
    ftsvmplot(frtsvm_struct,Traindata,Trainlabel);
end   
end





