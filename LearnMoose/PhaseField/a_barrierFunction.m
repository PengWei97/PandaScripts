% Define the range for eta
eta = linspace(0, 1, 100);

% Define the functions
g1 = eta.^2 .* (1 - eta).^2;
g2 = eta .* (1 - eta);
g3 = eta.^2 .* (1 - eta.^2).^2;

% Create a new figure
figure;

% Plot each function
plot(eta, g1, 'r-', 'LineWidth', 2); hold on;
plot(eta, g2, 'b--', 'LineWidth', 2);
plot(eta, g3, 'g-.', 'LineWidth', 2);

% Adding legends
legend('g(\eta) = \eta^2(1 - \eta)^2', 'g(\eta) = \eta(1 - \eta)', 'g(\eta) = \eta^2(1 - \eta^2)^2', 'Location', 'best');

% Title and labels
title('Plot of g(\eta) Functions');
xlabel('\eta');
ylabel('g(\eta)');

% ylim([-5, 5])
% Display grid
grid on;
