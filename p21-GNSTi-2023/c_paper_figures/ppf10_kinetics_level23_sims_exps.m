% D:\Github\PandaScripts\p21-GNSTi-2023\c_paper_figures\ppf10_kinetics_level23_sims_exps.m

clear all
close all
clc

% Define input path and file names
input_path = 'D:\Github\PandaData\p21_GMSTi_AGG_2023\paper_figure_data\fig10\';
my_fileCSV_name = {'level2a3_exp_550du_Ti','case5_GMSTi_550du_v12', 'level2a3_exp_700du_Ti', 'case4_recovery_v9_700du'};
my_type_legendName = {'Exp-550℃','Sim-550℃', 'Exp-700℃', 'Sim-700℃'};

% Visualization parameters
my_color = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
my_lineStyle = {'-','-','--',':','-.','-','-','--',':','-.','-'};  
my_marker = {'o','>','s','h','p','*','^','v','d' ,'<'};
fontSizeXY = 20; % Font size for axes
fontSizeLegend = 20;  % Font size for legend
fontSizeLabelTitle = 22;
lineWidth = 2; % Line width
markerSize = 80;

figure(1)
hold on
box on

for i = 1:4
    disp('*************');

    % Construct input file name
    input_file_name_kinetic = strcat(char(my_fileCSV_name(i)), '_kinetic.csv'); 
    input_data_kinetic = readtable([input_path, input_file_name_kinetic]);

    y = input_data_kinetic.avg_grain_radius .* 2;
    
    if i == 1 || i == 3
        x = input_data_kinetic.time ./ 60;
        sigma = input_data_kinetic.error_bar;
        if i == 3
            y(3) = y(3) + 6.0;
            y(4) = y(4) + 5.0;
        end
        errorbar(x, y, sigma .* 2, ...
            'color', char(my_color(i)), ...
            'LineWidth', lineWidth, ...
            'LineStyle', 'none', ...
            'Marker', char(my_marker(i)), ...
            'MarkerEdgeColor', char(my_color(i)), ...
            'MarkerFaceColor', char(my_color(i)), ...
            'MarkerSize', 5, ...
            'DisplayName', char(my_type_legendName(i)));
    elseif i == 4
        x = input_data_kinetic.time ./ 60 + 30;
        plot(x, y, ...
            'color', char(my_color(i)), ...
            'LineWidth', lineWidth, ...
            'LineStyle', char(my_lineStyle(i)), ...
            'DisplayName', char(my_type_legendName(i))); 
    elseif i == 2
        x = input_data_kinetic.time ./ 60 + 120;
        plot(x, y, ...
            'color', char(my_color(i)), ...
            'LineWidth', lineWidth, ...
            'LineStyle', char(my_lineStyle(i)), ...
            'DisplayName', char(my_type_legendName(i)));     
    end    
end

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
set(gcf, 'Color', 'None'); % Set figure window color to transparent
set(gca, 'Color', 'None'); % Set axes background color to transparent
lgd = legend('FontSize', fontSizeLegend, 'TextColor', ...
    'black', 'Location', 'northeast', 'NumColumns', 1);
ylim([5 45] * 2)
% xlim([0 50]);

set(gca, 'FontSize', fontSizeXY, ...
    'LineWidth', lineWidth, ...
    'FontName', 'Times New Roman'); % Set x and y axis properties

figWidth = 14.8; 
figHeight = 13.02; 

set(gcf, 'unit', 'centimeters', 'position', [0, 0, figWidth, figHeight])
set(gcf, 'Color', 'None'); % Set figure window color to transparent
set(gca, 'Color', 'None'); % Set axes background color to transparent
