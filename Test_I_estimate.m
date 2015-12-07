simulate(controller('pid'), 0, 10, 0.001);
load('4SystemID_1.mat');
[ L ] = Initialize_I( real_state(7:9,:), 0.001, inputout,1 );
[v1 d1]  = eig(L'*L); % Actual sampling rate
[ L ] = Initialize_I( real_state(7:9,:), 0.001, inputout, 10 );
[v2 d2]  = eig(L'*L); % smaller sampling rate

v1_real = v1(:,1)*real_parameters(end,1)/v1(end,1);
v2_real = v2(:,1)*real_parameters(end,1)/v2(end,1);

% err1 = (v1_real-real_parameters)./real_parameters;
% err2 = (v2_real-real_parameters)./real_parameters;
err1 = (v1_real-real_parameters(1:3,7:8))./real_parameters(1:3,7:8);
err2 = (v2_real-real_parameters(1:3,7:8))./real_parameters(1:3,7:8);