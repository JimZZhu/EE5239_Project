% Create a controller based on it's name, using a look-up table.
function c = controller(name, Kd, Kp, Ki)
    % Use manually tuned parameters, unless arguments provide the parameters.
    if nargin == 1
        Kd = 4;
        Kp = 3;
        Ki = 5.5;
    elseif nargin == 2 || nargin > 4
        error('Incorrect number of parameters.');
    end

    if strcmpi(name, 'pd')
        c = @(state, thetadot, thetadot_norm, theta) pd_controller(state, thetadot, thetadot_norm, theta, Kd, Kp);
    elseif strcmpi(name, 'pid')
        c = @(state, thetadot, thetadot_norm, theta) pid_controller(state, thetadot, thetadot_norm, theta, Kd, Kp, Ki);
    else
        error(sprintf('Unknown controller type "%s"', name));
    end
end

% Implement a PD controller. See simulate(controller).
function [input, state] = pd_controller(state, thetadot, thetadot_norm, theta, Kd, Kp)
    % Initialize integral to zero when it doesn't exist.
    if ~isfield(state, 'integral')
        state.integral = zeros(3, 1);
    end

    % Compute total thrust.
%     total = state.m * state.g / state.k / ...
%         (cos(state.integral(1)) * cos(state.integral(2)));
    total = state.m * state.g / state.k / ...
        (cos(theta(1)) * cos(theta(2)));

    % Compute PD error and inputs.
    thetadot_err = thetadot - thetadot_norm;
    err = Kd * thetadot_err + Kp * state.integral;
    input = err2inputs(state, err, total);

    % Update controller state.
    state.integral = state.integral + state.dt .* thetadot_err;
end

% Implement a PID controller. See simulate(controller).
function [input, state] = pid_controller(state, thetadot, thetadot_norm, theta, Kd, Kp, Ki)
    % Initialize integrals to zero when it doesn't exist.
    if ~isfield(state, 'integral')
        state.integral = zeros(3, 1);
        state.integral2 = zeros(3, 1);
    end

    % Prevent wind-up
    if max(abs(state.integral2)) > 0.01
        state.integral2(:) = 0;
    end

    % Compute total thrust.
%     total = state.m * state.g / state.k / ... 
%           (cos(state.integral(1)) * cos(state.integral(2)));
      total = state.m * state.g / state.k / ...
        (cos(theta(1)) * cos(theta(2)));

    % Compute error and inputs.
    thetadot_err = thetadot - thetadot_norm;
    err = Kd * thetadot_err + Kp * state.integral - Ki * state.integral2;
    input = err2inputs(state, err, total);

    % Update controller state.
    state.integral = state.integral + state.dt .* thetadot_err;
    state.integral2 = state.integral2 + state.dt .* state.integral;
end

% Given desired torques, desired total thrust, and physical parameters,
% solve for required system inputs.
function inputs = err2inputs(state, err, total)
%     e1 = err(1);
%     e2 = err(2);
%     e3 = err(3);
%     Ix = state.I(1, 1);
%     Iy = state.I(2, 2);
%     Iz = state.I(3, 3);
%     k = state.k;
%     L = state.L;
%     b = state.b;
% 
%     inputs = zeros(4, 1);
%     inputs(1) = total/4 -(2 * b * e1 * Ix + e3 * Iz * k * L)/(4 * b * k * L);
%     inputs(2) = total/4 + e3 * Iz/(4 * b) - (e2 * Iy)/(2 * k * L);
%     inputs(3) = total/4 -(-2 * b * e1 * Ix + e3 * Iz * k * L)/(4 * b * k * L);
%     inputs(4) = total/4 + e3 * Iz/(4 * b) + (e2 * Iy)/(2 * k * L);

%%%%%%%%%%%%%%%%% Implementation in local frame %%%%%%%%%%%%%%%%%%%%%%%%%%%
    k = state.k;
    L = state.L;
    b = state.b;

    A = zeros(4,4);
    A(1,:) = (L*k/sqrt(2))*[1 -1 1 -1];
    A(2,:) = (L*k/sqrt(2))*[1 -1 -1 1];
    A(3,:) = b*[-1 -1 1 1];
    A(4,:) = [1 1 1 1]; % k already included in expression of 'total'
    b = [-state.I*err;total];
    
    inputs = A\b;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
