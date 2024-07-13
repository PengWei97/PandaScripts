clear all
close all
clc

% Visualization parameters
colors = {'#0085c3', '#14d4f4', '#f2af00', '#b7295a', '#00205b', '#009f4d', '#84bd00', '#efdf00', '#e4002b', '#a51890'};
lineStyles = {'-', '--', ':', '-.', '-', '--', ':', '-.'};
markers = {'o', '>', 's', 'h', 'p', '*', '^', 'v', 'd', '<'};
fontSizeXY = 20; % Font size for axes
fontSizeLegend = 22;  % Font size for legend
fontSizeLabelTitle = 22;
lineWidth = 2; % Line width
markerSize = 80;

data = [15.38497971	13.25649973	8.688986753
        26.47175311	38.05213098	32.28810483
        15.56188417	15.29328893	0
        18.78704758	20.7717559	0
        13.42911125	36.61064277	43.60363388
        18.07949432	17.79810077	10.64933666];

time = [10 20 30].*60;

figure(1)
hold on
box on
for i_grains = 1:length(data)
  x = time(data(i_grains, :) > 0);
  y = data(i_grains, :);
  y = y(y>0);

  typeLegendNames = sprintf('Grain %d', i_grains);
  scatter(x, y, 80, ...
          'MarkerEdgeColor', colors{i_grains}, ...
          'MarkerFaceColor', colors{i_grains}, ...
          'Marker', markers{i_grains}, ...
          'DisplayName', typeLegendNames);

  hold on
  plot(x, y, ...
      'Color', colors{i_grains}, ...
      'LineWidth', lineWidth, ...
      'LineStyle', lineStyles{i_grains}, ...
      'HandleVisibility', 'off');
end

xlim([500 2000]);
set(gca, 'FontSize', fontSizeXY, ...
  'LineWidth', lineWidth, ...
  'FontName', 'Times New Roman');
xlabel('Time (s)', ...
  'FontSize', fontSizeLabelTitle, ...
  'FontWeight', 'bold', ...
  'Color', 'k', ...
  'FontName', 'Times New Roman');
ylabel('Grain Radiux (\mum)', ...
  'FontSize', fontSizeLabelTitle, ...
  'FontWeight', 'bold', ...
  'Color', 'k', ...
  'FontName', 'Times New Roman');

% Set figure and axes properties
figWidth = 17.5 * 0.9;
figHeight = 13.0 * 0.9;
set(gcf, 'Unit', 'centimeters', 'Position', [5, 5, figWidth, figHeight]);

% Add legend
legend('FontSize', fontSizeLegend, 'TextColor', ...
    'black', 'Location', 'eastoutside', 'NumColumns', 1);

set(gcf, 'Color', 'None'); % Set figure window color to transparent
set(gca, 'Color', 'None'); % Set axes background color to transparent

% E:\Github\PandaScripts\p23-GNSNi-2024\b_simualtions\sim1_get_mobility_based_exps.m