load('4SystemID.mat');

figure
for i = 1:3
plot(real_state(i,:),'k');
hold on;
plot(observ(i,:),'r');
end
title('x');

figure
for i = 7:9
plot(real_state(i,:),'k');
hold on;
plot(observ(i,:),'r');
end
title('omega');

figure
for i = 10:12
plot(real_state(i,:),'k');
hold on;
plot(observ(i,:),'r');
end
title('q1-q3');