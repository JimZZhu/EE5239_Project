% Test to get initial estimation of the parameters based on perfect omega

simulate(controller('pid'), 0, 20, 0.001); % (1000Hz)
load('4SystemID_1.mat');

% Find the null space of L
% Actual sampling rate (1000Hz)
[ L1 ] = Initialize_I( real_state(7:9,:), 0.001, inputout,1 );
[v1,d1]  = eig(L1'*L1); 
% smaller sampling rate (100Hz)
[ L2 ] = Initialize_I( real_state(7:9,:), 0.001, inputout, 10 );
[v2,d2]  = eig(L2'*L2); 


real_parameters(7:8,1) = real_parameters(7:8,1)*1e4;

% With only Ix Iy Iz
real_parameters = real_parameters([1:3,7:8],1);

% Scaled with kt
v1_real = v1(:,1)*real_parameters(end,1)/v1(end,1);
v2_real = v2(:,1)*real_parameters(end,1)/v2(end,1);

err1 = (v1_real-real_parameters)./real_parameters;
err2 = (v2_real-real_parameters)./real_parameters;


