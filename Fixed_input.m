function [ control ] = Fixed_input(num, scale)

load(['4SystemID_' num2str( num ) '.mat']);

msize = size(inputout,2);

control = zeros(4,scale*(msize-1) + 1);

for i = 1:msize-1
   control(1,(i-1)*scale+1:i*scale) = inputout(1,i)*ones(1,scale); 
   control(2,(i-1)*scale+1:i*scale) = inputout(2,i)*ones(1,scale); 
   control(3,(i-1)*scale+1:i*scale) = inputout(3,i)*ones(1,scale); 
   control(4,(i-1)*scale+1:i*scale) = inputout(4,i)*ones(1,scale); 
end

 control(:,end) = inputout(:,end);

end

