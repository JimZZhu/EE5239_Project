% load('4SystemID1.mat');
% 
% figure
% for i = 1:3
% plot(real_state(i,:),'k');
% % hold on;
% % plot(observ(i,:),'r');
% end
% title('x');
% 
% figure
% for i = 7:9
% plot(real_state(i,:),'k');
% % hold on;
% % plot(observ(i,:),'r');
% end
% title('omega');
% 
% figure
% for i = 10:12
% plot(real_state(i,:),'k');
% % hold on;
% % plot(observ(i,:),'r');
% end
% title('q1-q3');

load('4SystemID_1.mat');
figure(1)
plot(real_state(1,:),real_state(2,:),'k');
hold on;
figure(2);
a = real_state(14:16,:);
plot(a(1,:),'k');
hold on;
plot(a(2,:),'k-');
hold on;
plot(a(3,:),'k--');
hold on;

load('4SystemID_2.mat');
figure(1)
plot(real_state(1,:),real_state(2,:),'r');
hold on;
figure(2);
b = real_state(14:16,1:10:end);
plot(b(1,:),'r');
hold on;
plot(b(2,:),'r-');
hold on;
plot(b(3,:),'r--');
hold on;

% load('4SystemID_3.mat');
% figure(1)
% plot(real_state(1,:),real_state(3,:),'b');
% hold on;
% figure(2);
% c = real_state(14:16,1:100:end);
% plot(c(1,:),'b');
% hold on;
% plot(c(2,:),'b-');
% hold on;
% plot(c(3,:),'b--');
% hold on;
% 
% 
% 
% load('4SystemID_4.mat');
% figure(1)
% plot(real_state(1,:),real_state(3,:),'k--');
% hold on;
% 
% load('4SystemID_5.mat');
% figure(1)
% plot(real_state(1,:),real_state(3,:),'r--');
% hold on;
% 
% load('4SystemID_6.mat');
% figure(1)
% plot(real_state(1,:),real_state(3,:),'b--');
% hold on;