function test_omega_est_obj_func

clear all;
close all;

x_true = zeros(3,1);
y_opt = Omega_est_obj_func(qkk ,qk, x_true);

fprintf(' ------ Steepest descent with Armijo rule step size -------\n');
[iter, f1, x1, t1] = GradientDescent1(qkk, qk ,x0);
fprintf('iteration: %d \n', iter);
fprintf('distance from convergent point: %d \n', norm(x1(end) - x_opt));

figure(1)
plot(abs(f1 - y_opt)/abs(y_opt))
title('Steepest descent with Armijo rule: Objective function');

end

% Finding Armijo stepsize
function [m,x1] = ArmijoUpdate(sigma, beta, qkk, qk, x0)
    dx = Omega_est_grad_func(qkk,qk,,x0);  %%% <---- Change the gradient function right here
    m = 0;
    x1 = x0 - beta^m * dx;
    % dropping value bounded above by linear prediction
    while(Omega_est_obj_func(qkk, qk, x0) - Omega_est_obj_func(qkk, qk, x1) <= sigma*beta^m*norm(dx)^2)        
        m = m + 1;        
        x1 = x0 - beta^m * dx;
        % fprintf('diff f: %f \n',Omega_est_obj_func(qkk,qk,x0) - Omega_est_obj_func(qkk,qk,x1)); 
        % fprintf('size step: %f \n',sigma*beta^m*norm(dx)^2); 
    end
end

% Using steepest descent with Armijo rule
function [iter, f_obj, x_1, time] = GradientDescent1(q_kk, q_k, x0)
    
    sigma = 0.1; beta = 0.3;
    x_1 = zeros(length(x0), 100);
    
    tic;
    % initial value
    x_1(:,1) = x0;    
    f_obj(1) = Omega_est_obj_func(q_kk, q_k ,x_1(:,1));
    
    % first step
    [~, x_1(:,2)] = ArmijoUpdate(sigma, beta, Q, b, x_1(:,1));
    f_obj(2) = Omega_est_obj_func(q_kk, q_k ,x_1(:,2));
    iter = 1;
    time(iter) = toc;
    
    while( norm(x_1(:,iter+1) - x_1(:,iter))/norm(x_1(:,iter)) > 0.01 ||...
           abs(Omega_est_obj_func(q_kk, q_k, x_1(:,iter+1)) - Omega_est_obj_func(q_kk, q_k, x_1(:,iter)))/abs(Omega_est_obj_func(q_kk, q_k, x_1(:,iter))) > 1e-2 )        
        tic;
        iter = iter + 1;
        [~, x_1(:,iter+1)] = ArmijoUpdate(sigma, beta, q_kk, q_k, x_1(:,iter));
        f_obj(iter+1) = Omega_est_obj_func(q_kk, q_k, x_1(:,iter+1));
        time(iter) = toc;
        % fprintf('norm x: %f \n',norm(x_1(:,iter+1) - x_1(:,iter))/norm(x_1(:,iter)));
        % fprintf('norm f: %f \n',abs(Omega_est_obj_func(qkk,qk,x_1(:,iter+1)) - Omega_est_obj_func(qkk,qk,x_1(:,iter)))/abs(Omega_est_obj_func(qkk,qk,x_1(:,iter)))); 
        % fprintf('f: %f \n',Omega_est_obj_func(qkk,qk,x_1(:,iter+1))); 
    end    
end