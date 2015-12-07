function [ fk ] = Omega_est_obj_func( qk, qkk, wk, dt )
L_qkk = left_quat_mat(qkk);
R_qk = right_quat_mat(qk);
abk = [0 0 0 1] * L_qkk' * R_qk;
v = [( sin(norm(wk)*dt/2)/norm(wk) ) * wk; cos(norm(wk)*dt/2)];
fk = 0.5*(1 - abk*v)^2;
end

