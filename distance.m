function [distance_xiX,xixing]=distance(xi,X)
%  Author: Bin-Bin Gao 
%  Email:csgaobb@gmail.com
%  July 5, 2016

% check correct number of arguments
if ( nargin>2||nargin<2) 
    help distance
else
    [rx,cx]=size(X);
    for  i=1:rx
        distance_per(i,1)=norm(xi-X(i,:));
    end
    distance_xiX=min(distance_per);
    xxxx=X(find(distance_per(:,1)==distance_xiX),:);
    xixing=xxxx(1,:);
end
end
