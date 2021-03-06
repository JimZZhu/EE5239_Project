% Perform a simulation of a quadcopter, from t = 0 through t = 10.
% As an argument, take a controller function. This function must accept
% a struct containing the physical parameters of the system and the current
% gyro readings. The controller may use the strust to store persistent state, and
% return this state as a second output value. If no controller is given,
% a simulation is run with some pre-determined inputs.
% The output of this function is a data struct with the following fields, recorded
% at each time-step during the simulation:
%
% data =
%
%         x: [3xN double]
%     theta: [3xN double]
%       vel: [3xN double]
%    angvel: [3xN double]
%         t: [1xN double]
%     input: [4xN double]
%        dt: 0.0050
function result = simulate(controller, tstart, tend, dt)
    % Physical constants.
    g = 9.81;
    m = 0.5;
    L = 0.25;
    k = 3e-6; % kf
    b = 1e-7; % kt
    I = diag([5e-3, 5e-3, 10e-3]);
    kd = 0.25;

    % Simulation times, in seconds.
    if nargin < 4
        tstart = 0;
        tend = 4;
        dt = 0.005;
    end
    ts = tstart:dt:tend;

    % Number of points in the simulation.
    N = numel(ts);

    %%%%%%%%%%%%% Trjectory (thetadot) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     thetadot_norm = zeros(3,N);

%     % Sinewave input
%     thetadot_norm = zeros(3,N);
%     Amplitude = 0.1; % rad/s
%     T_norm = 5; % T
%     freq = 2*pi/T_norm; % frequency 
%     for my_ind = 1:N
%         thetadot_norm(1,my_ind) = Amplitude * sin(freq*my_ind*dt);
%     end
    
    % step input
    thetadot_norm = zeros(3,N);
    pulse_width = 100; % time_step
    pulse_interval = ceil(N/5);
    pulse_magnitude = 0.5;
    thetadot_norm(1,1:pulse_width) = pulse_magnitude*ones(1,pulse_width);
    thetadot_norm(2,1+pulse_interval:pulse_width+pulse_interval) = pulse_magnitude*ones(1,pulse_width);
    thetadot_norm(1,1+2*pulse_interval:pulse_width+2*pulse_interval) = -pulse_magnitude*ones(1,pulse_width);
    thetadot_norm(2,1+3*pulse_interval:pulse_width+3*pulse_interval) = -pulse_magnitude*ones(1,pulse_width);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Output values, recorded as the simulation runs.
    xout = zeros(3, N); xout_meas = zeros(3, N); Rxout = diag([1 1 1]);
    xdotout = zeros(3, N);
    thetaout = zeros(3, N);
    thetadotout = zeros(3, N);
    inputout = zeros(4, N);
    
    v_local = zeros(3, N);
    omegaout = zeros(3, N); omegaout_meas = zeros(3, N); Romegaout = diag([0.05 0.05 0.05]);
    qout = zeros(4, N); qout_meas = zeros(4, N); Rqout = diag([0.05 0.05 0.05 0]);% Quaternion
    accelout = zeros(3, N); accelout_meas = zeros(3, N); Raccelout = diag([1 1 1]); % accel in local frame

    % Struct given to the controller. Controller may store its persistent state in it.
    controller_params = struct('dt', dt, 'I', I, 'k', k, 'L', L, 'b', b, 'm', m, 'g', g);

    % Initial system state.
    x = [0; 0; 10];
    xdot = zeros(3, 1);
    theta = zeros(3, 1);

    % If we are running without a controller, do not disturb the system.
    if nargin == 0
        thetadot = zeros(3, 1);
    else
        % With a control, give a random deviation in the angular velocity.
        % Deviation is in degrees/sec.
        deviation = 50;
        thetadot = deg2rad(2 * deviation * rand(3, 1) - deviation);
        
        %%%%%%%%% My implementation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Disturbance in roll rate
%         thetadot = [1;0;0];
%         % Disturbance in roll rate
%         thetadot = [0;1;0];
        % Disturbance in roll rate
%         thetadot = [0;0;1];
%         % No disturbance
%         thetadot = [0;0;0];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end

    ind = 0;
    for t = ts
        ind = ind + 1;

        % Get input from built-in input or controller.
        if nargin == 0
            i = input(t);
        else
            [i, controller_params] = controller(controller_params, thetadot, thetadot_norm(:,ind), theta);
        end

        % Compute forces, torques, and accelerations.
        omega = thetadot2omega(thetadot, theta);
        a = acceleration(i, theta, xdot, m, g, k, kd);
        omegadot = angular_acceleration(i, omega, I, L, b, k);

        % Advance system state.
        omega = omega + dt * omegadot;
        thetadot = omega2thetadot(omega, theta); 
        theta = theta + dt * thetadot;
        xdot = xdot + dt * a;
        x = x + dt * xdot;
        % update the quaternion
        R_current = rotation(theta); % L to G
        q_current = rot2quat(R_current'); % G to L 

        % Store simulation state for output.
        xout(:, ind) = x; % position in global frame
        xout_meas(:,ind) = x + Rxout*randn(3,1); % noise added
        xdotout(:, ind) = xdot; % velocity in global frame
        thetaout(:, ind) = theta;
        thetadotout(:, ind) = thetadot;
        inputout(:, ind) = i;
        
        v_local(:,ind) = R_current'*xdot; % in local frame
        omegaout(:,ind) = omega; % angular vel in local frame
        omegaout_meas(:,ind) = omega + Romegaout*randn(3,1); 
        qout(:,ind) = q_current;
        qout_meas(:,ind) = q_current + Rqout*randn(4,1);
        accelout(:,ind) = R_current'*a;
        accelout_meas(:,ind) = R_current'*a + Raccelout*randn(3,1);
    end

    % Put all simulation variables into an output struct.
    result = struct('x', xout, 'theta', thetaout, 'vel', xdotout, ...
                    'angvel', thetadotout, 't', ts, 'dt', dt, 'input', inputout);
                
    %%%%%%%%%%%%%%%% Output state x and measurement z %%%%%%%%%%%%%%%%%%%%%
    real_state = [xout;v_local;omegaout;qout];
    observ = [xout_meas;accelout_meas;omegaout_meas;qout_meas];
    save('4SystemID.mat', 'real_state', 'observ', 'inputout');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure()
    plot(xout(1,:),xout(2,:));
    axis equal;
end

% Arbitrary test input.
function in = input(t)
    in = zeros(4, 1);
    in(:) = 700;
    in(1) = in(1) + 150;
    in(3) = in(3) + 150;
    in = in .^ 2;
end

% Compute thrust given current inputs and thrust coefficient.
function T = thrust(inputs, k)
    T = [0; 0; k * sum(inputs)];
end

% Compute torques, given current inputs, length, drag coefficient, and thrust coefficient.
function tau = torques(inputs, L, b, k)
tau = [
%             L * k * (inputs(1) - inputs(3))
%             L * k * (inputs(2) - inputs(4))
%             b * (inputs(1) - inputs(2) + inputs(3) - inputs(4))
    
    %%%%%%%%%%%%%%%% Our frame %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    L * k * (inputs(1) - inputs(2) + inputs(3) - inputs(4))/sqrt(2)
    L * k * (inputs(1) - inputs(2) - inputs(3) + inputs(4))/sqrt(2)
    b * (-inputs(1) - inputs(2) + inputs(3) + inputs(4))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ];
end

% Compute acceleration in inertial reference frame
% Parameters:
%   g: gravity acceleration
%   m: mass of quadcopter
%   k: thrust coefficient
%   kd: global drag coefficient
function a = acceleration(inputs, angles, vels, m, g, k, kd)
    gravity = [0; 0; -g];
    R = rotation(angles);
    T = R * thrust(inputs, k);
    Fd = -kd * vels;
    a = gravity + 1 / m * T + Fd;
end

% Compute angular acceleration in body frame
% Parameters:
%   I: inertia matrix
function omegad = angular_acceleration(inputs, omega, I, L, b, k)
    tau = torques(inputs, L, b, k);
    %     omegad = inv(I) * (tau - cross(omega, I * omega));
    omegad = I \ (tau - cross(omega, I * omega));
end

% Convert derivatives of roll, pitch, yaw to omega (in local frame).
function omega = thetadot2omega(thetadot, angles)
    phi = angles(1);
    theta = angles(2);
    psi = angles(3);
    W = [
        1, 0, -sin(theta)
        0, cos(phi), cos(theta)*sin(phi)
        0, -sin(phi), cos(theta)*cos(phi)
    ];
    omega = W * thetadot;
end

% Convert omega to roll, pitch, yaw derivatives
function thetadot = omega2thetadot(omega, angles)
    phi = angles(1);
    theta = angles(2);
    psi = angles(3);
    W = [
        1, 0, -sin(theta)
        0, cos(phi), cos(theta)*sin(phi)
        0, -sin(phi), cos(theta)*cos(phi)
    ];
%     thetadot = inv(W) * omega;
    thetadot = W\omega;
end
