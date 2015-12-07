clear all;

f1 =  @(x,y) x-y;
f2 =  @(x,y) 2*y-x;

output = zeros(1000:2);
output(1,:) = [1 1];

t1 = 0;
t2 = 1;
for i = 1:999
%     output(i,1)
%     output(i,2)
    output(i+1,1) = integral(@(x)f1(x,output(i,2)),1+i/1000,1+(i+1)/1000);
    output(i+1,2) = integral(@(y)f2((output(i,1)+output(i+1,1))/2,y),1+i/1000,1+(i+1)/1000);
end

A = [1 -1;-1 2];
output_ = zeros(1000:2);
for i = 1:1000
    output_(i,:) = (exp(A*0.001*(i-1))*[1;1])';
end

norm(output - output_);

plot(1:1:1000, output(:,1));
% hold on;
% plot(1:1:1000, output_(:,1), 'r');

% plot(output(2,:), output_(2,:));