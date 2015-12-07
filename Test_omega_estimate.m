% Test to get initial estimation of the omega based on quaternion
% measurement and noisy omega measurement

simulate(controller('pid'), 0, 20, 0.001); % (1000Hz)
load('4SystemID_1.mat');

% Measuremed with 100 Hz
scale = 10; % 1000/100
omega_m = observ(1:scale:end,7:9);
quat_m = observ(1:scale:end,10:13);


