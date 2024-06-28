% D:\Github\PandaScripts\p21-GNSTi-2023\c_paper_figures\ppf8b_ave_kinetic_sims.m

clear all
close all
clc

% Define input path and file names
input_path = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\sim_Ti700du\csv2\csv_kinetics_difference_cases\';
my_fileCSV_name = {'case3_noStored_v1_700du', 'case4_recovery_v9_700du', 'case4_recovery_v8_700du'}; 

my_type_legendName = {'Case I: No stored energy', 'Case II: Stored energy + GND evolution', 'Case III: Stored energy'};

% Visualization parameters
my_color = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
my_lineStyle = {'-','--',':','-.','-','-','--',':','-.','-'};  
my_marker = {'o','>','s','h','p','*','^','v','d' ,'<'};
fontSizeXY = 20; % Font size for axes
fontSizeLegend = 22; % Font size for legend
fontSizeLabelTitle = 22;
lineWidth = 2; % Line width
markerSize = 80;

% Initialize figure
figure(1)
hold on
box on

% Loop through each case
for i = 1:3
    disp('*************');
    disp(['Processing case: ', my_type_legendName{i}]);

    % Construct input file name
    input_file_name_kinetic = strcat(char(my_fileCSV_name[i]), '_kinetic.csv');
    input_data_kinetic = readtable([input_path, input_file_name_kinetic]);

    % Extract time and average grain radius data
    y = input_data_kinetic.avg_grain_radius .* 2;
    x = input_data_kinetic.time ./ 60 + 30;

    % Plot the data
    plot(x, y, ...
        'color', char(my_color(i)), ...
        'LineWidth', lineWidth, ...
        'LineStyle', char(my_lineStyle(i)), ...
        'DisplayName', char(my_type_legendName{i}));
end

% Set labels, limits, and other plot properties
xlabel('Time (min)', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');
ylabel('Average diameter (\mum)', ...
    'FontSize', fontSizeLabelTitle, ...
    'FontWeight', 'bold', ...
    'Color', 'k', ...
    'FontName', 'Times New Roman');
legend('FontSize', fontSizeLegend, 'TextColor', ...
    'black', 'Location', 'southeast', 'NumColumns', 1);
ylim([15 40] * 2)
xlim([25 125]);

% Set axes properties
set(gca, 'FontSize', fontSizeXY, ...
    'LineWidth', lineWidth, ...
    'FontName', 'Times New Roman'); % Set x and y axis properties

% Set figure properties
figWidth = 14.8; 
figHeight = 13.02; 
set(gcf, 'unit', 'centimeters', 'position', [0, 0, figWidth, figHeight])
set(gcf, 'Color', 'None'); % Set figure window color to transparent
set(gca, 'Color', 'None'); % Set axes background color to transparent
