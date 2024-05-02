% 绘制700℃和550℃的实验以及模拟的结果

clear all
close all
clc

input_path = 'E:/Github/PandaData/p21_GMSTi_AGG_2023/paper_figure_data/';
my_fileCSV_name = {'case5_GMSTi_550du_v1'};

my_type_legendName = {'Sim-550℃'};

% 可视化参数
my_color = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
my_lineStyle = {'-','-','--',':','-.','-','-','--',':','-.','-'};  
my_marker = {'o','>','s','h','p','*','^','v','d' ,'<'};
num_front_xy = 20; % 字体大小
num_FontSize_legend = 20;  % legend的字体大小
num_FontSize_labelTitle = 22;
num_line_width = 2; % 线宽
num_mark_size = 80;

figure(1)
hold on
box on

for i = 1:1
  disp('*************');

  input_file_name_kinetic = strcat(char(my_fileCSV_name(i)), '_kinetic.csv');

  input_data_kinetic = readtable([input_path, input_file_name_kinetic]);
  x = input_data_kinetic.time./60 + 120.0;
  y = input_data_kinetic.avg_grain_radius .*2;

  plot(x,y,...
    'color',char(my_color(i)),...
    'LineWidth',num_line_width,...
    'LineStyle',char(my_lineStyle(i)),...
    'DisplayName',char(my_type_legendName(i)));
end
xlabel('Time (min)',...
        'FontSize',num_FontSize_labelTitle,...
        'FontWeight','bold',...
        'Color','k',...
        'FontName','Times New Roman');
ylabel('Average diameter (\mum)',...
      'FontSize',num_FontSize_labelTitle,...
      'FontWeight','bold',...
      'Color','k',...
      'FontName','Times New Roman');
set(gcf,'Color','None'); % 设置图窗的颜色为透明，gcf 返回当前Figure 对象的句柄值
set(gca,'Color','None'); % 设置图中背景颜色为透明，返回当前axes 对象的句柄值
lgd = legend('FontSize',num_FontSize_legend,'TextColor',...
              'black','Location','northeast','NumColumns',1);
ylim([5 45].*2)
xlim([0 500]);

set(gca,'FontSize',num_front_xy,...
    'Linewidth',num_line_width,...
    'FontName','Times New Roman'); % 设置x y轴

figWidth = 14.8; 
figHight = 13.02; 

set(gcf,'unit','centimeters','position',[0,0,figWidth,figHight])
set(gcf,'Color','None'); % 设置图窗的颜色为透明，gcf 返回当前Figure 对象的句柄值
set(gca,'Color','None'); % 设置图中背景颜色为透明，返回当前axes 对象的句柄值

% E:\Github\PandaScripts\p21-GMSTi-2023\sim_results_extraction_scripts\sim1_draw_kinetic_data.m