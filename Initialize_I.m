% Function to get the matrix L (L*para = 0)
function [ L ] = Initialize_I( omega, dt, u, scale )
addpath ('./robotics3D');

omega = omega(:,1:scale:end);
u = u(:,1:scale:end);
dt = dt*scale;

N = size(omega,2);
% L = zeros(3*(N-1),8);
L = zeros(3*(N-1),5);

for i = 2:N
   [ L_1_temp ] = L_matrix( omega(:,i) - omega(:,i-1) );
   [ L_2_temp ] = L_matrix( omega(:,i) );
   [ Lk ] = ControlMatrix( u(:,i) );
   L((i-2)*3 + 1:(i-1)*3,:) = [L_1_temp + dt*skewsymm(omega(:,i))*L_2_temp -dt*Lk*1e-4];   
end

end

function [ F ] = ControlMatrix( u )
    A = [u(1) - u(2) + u(3) - u(4); u(1) - u(2) - u(3) + u(4);0];
    B = [0;0; -u(1) - u(2) + u(3) + u(4)];
    F = [A/sqrt(2) B];
end

function [ L ] = L_matrix( a )
 L1 = diag(a);
 L2 = [a(2) a(3) 0;a(1) 0 a(3);0 a(1) a(2)];
%  L = [L1 L2];
 L = [L1];
end