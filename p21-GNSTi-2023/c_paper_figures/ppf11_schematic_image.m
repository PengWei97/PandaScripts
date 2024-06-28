% D:\Github\PandaScripts\p21-GNSTi-2023\c_paper_figures\ppf11_schematic_image.m

% Clear workspace, close all figures, and clear command window
clear;
close all;
clc;

% Define input range
x = linspace(-5, 5, 100);

% Define parameter
a = 8;

% Calculate Sigmoidal function value
y = sigmoidalFunction(x, a);

% Visualization parameters
my_color = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
my_lineStyle = {'-','--',':','-.','-','-','--',':','-.','-'};  
my_marker = {'o','>','s','h','p','*','^','v','d' ,'<'};
fontSizeXY = 14; % Font size for axes
fontSizeLegend = 16;  % Font size for legend
fontSizeLabelTitle = 20;
lineWidth = 2; % Line width
markerSize = 80;

% Create figure
figure;
box on
plot(x, y, ...
    'color', char(my_color(1)), ...
    'LineWidth', lineWidth-0.5, ...
    'lineStyle', char(my_lineStyle(1)));
hold on

plot(x, y * 5, ...
    'color', char(my_color(2)), ...
    'LineWidth', lineWidth-0.5, ...
    'lineStyle', char(my_lineStyle(2)));

% Set labels
xlabel('x', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');
ylabel('Stored energy', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');

% Set limits
ylim([-1 6]);
figWidth = 13.0;
figHeight = 9.0;

% Set axes properties
set(gca, 'FontSize', fontSizeXY, ...
    'LineWidth', lineWidth, ...
    'FontName', 'Times New Roman');

% Set figure properties
set(gcf, 'unit', 'centimeters', 'position', [10, 5, figWidth, figHeight]);
set(gcf, 'Color', 'None'); % Set figure window color to transparent
set(gca, 'Color', 'None'); % Set axes background color to transparent

% Sigmoidal function definition
function y = sigmoidalFunction(x, a)
    y = 1 ./ (1 + exp(-a * x));
end
