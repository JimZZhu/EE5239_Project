function test_omega_est_obj_func

clear all;
close all;

addpath ../robotics3D/
%% True input output generator
dt = 1;
% x_true = [-0.0591737260258116;-0.543246312713979;-0.0129308279058878];
x_true = [-50.0;-75.0;-120.0];
qk = [-0.0316853555968454;0.150461164599839;-0.0446661059595984;0.990442846983215];

R_qk = right_quat_mat(qk);
v = [( sin(norm(x_true)*dt/2)/norm(x_true) ) * x_true; cos(norm(x_true)*dt/2)];
qkk = R_qk * v;
y_opt = Omega_est_obj_func(qkk ,qk, x_true, dt)

b = [0.001; -0.005; -0.002];
x0 = [1.0;1.0;1.0]; %x_true - b;

%% 
fprintf(' ------ Steepest descent with Armijo rule step size -------\n');
[iter, f1, x1, t1] = GradientDescent1(qkk, qk ,x0, dt);
fprintf('iteration: %d \n', iter);
fprintf('distance from convergent point: %d \n', norm(x1(end) - x_true));

figure(1)
plot(abs(f1 - y_opt)/abs(y_opt))
title('Steepest descent with Armijo rule: Objective function');

end

% Finding Armijo stepsize
function [m,x1] = ArmijoUpdate(sigma, beta, qkk, qk, x0, dt)
    dx = Omega_est_grad_func(qkk,qk,x0, dt);  %%% <---- Change the gradient function right here
    m = 0;
    x1 = x0 - beta^m * dx;
    % dropping value bounded above by linear prediction
    while(Omega_est_obj_func(qkk, qk, x0, dt) - Omega_est_obj_func(qkk, qk, x1, dt) <= sigma*beta^m*norm(dx)^2)        
        m = m + 1;        
        x1 = x0 - beta^m * dx;
        % fprintf('diff f: %f \n',Omega_est_obj_func(qkk,qk,x0) - Omega_est_obj_func(qkk,qk,x1)); 
        % fprintf('size step: %f \n',sigma*beta^m*norm(dx)^2); 
    end
end

% Using steepest descent with Armijo rule
function [iter, f_obj, x_1, time] = GradientDescent1(q_kk, q_k, x0, dt)
    
    sigma = 0.1; beta = 0.3;
    x_1 = zeros(length(x0), 100);
    
    tic;
    % initial value
    x_1(:,1) = x0;    
    f_obj(1) = Omega_est_obj_func(q_kk, q_k ,x_1(:,1), dt);
    
    % first step
    [~, x_1(:,2)] = ArmijoUpdate(sigma, beta, q_kk, q_k, x_1(:,1), dt);
    f_obj(2) = Omega_est_obj_func(q_kk, q_k ,x_1(:,2), dt);
    iter = 1;
    time(iter) = toc;
    
    while( norm(x_1(:,iter+1) - x_1(:,iter))/norm(x_1(:,iter)) > 0.0001 ||...
           abs(Omega_est_obj_func(q_kk, q_k, x_1(:,iter+1), dt) - Omega_est_obj_func(q_kk, q_k, x_1(:,iter), dt))/abs(Omega_est_obj_func(q_kk, q_k, x_1(:,iter), dt)) > 1e-4 )        
        tic;
        iter = iter + 1;
        [~, x_1(:,iter+1)] = ArmijoUpdate(sigma, beta, q_kk, q_k, x_1(:,iter), dt);
        f_obj(iter+1) = Omega_est_obj_func(q_kk, q_k, x_1(:,iter+1), dt);
        time(iter) = toc;
        % fprintf('norm x: %f \n',norm(x_1(:,iter+1) - x_1(:,iter))/norm(x_1(:,iter)));
        % fprintf('norm f: %f \n',abs(Omega_est_obj_func(qkk,qk,x_1(:,iter+1)) - Omega_est_obj_func(qkk,qk,x_1(:,iter)))/abs(Omega_est_obj_func(qkk,qk,x_1(:,iter)))); 
        % fprintf('f: %f \n',Omega_est_obj_func(qkk,qk,x_1(:,iter+1))); 
    end    
end