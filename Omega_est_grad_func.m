function [ fk ] = Omega_est_grad_func( qk, qkk, wk, dt )
L_qkk = left_quat_mat(qkk);
R_qk = right_quat_mat(qk);
abk = [0 0 0 1] * L_qkk' * R_qk;
ak = (abk(1,1:3))'; bk = abk(4);

alpha = norm(wk)*dt/2;

v = [( sin(alpha)/norm(wk) ) * wk; cos(alpha)];

grad_g = ( (cos(alpha)*dt/2 - sin(alpha)/norm(wk))*wk'*ak/(wk'*wk) - (sin(alpha)/norm(wk))*dt*bk/2 )*wk + (sin(alpha)/norm(wk))*ak;

fk = -(1 - abk'*v)*grad_g;

end

