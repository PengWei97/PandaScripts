clear all
close all
clc

% x = [10; 30; 60; 120];
% fraction_twinType = [
% 0.0847, 0.9153;
% 0.1135, 0.8865;
% 0.0851, 0.9149;
% 0.0105, 0.9895;];

x = [30; 120; 240; 480];
fraction_twinType = [
0.0856    0.9144
0.0280    0.9720
0.0436    0.9564
0.0527    0.9473];
my_type_legendName = {'Coherence twin boundary', 'Incoherence twin boundary'};

% 可视化参数
my_color = {'#0085c3','#14d4f4','#f2af00','#b7295a','#00205b','#00205b','#009f4d','#84bd00','#efdf00','#e4002b','#a51890'};
my_lineStyle = {'-','--',':','-.','-','-','--',':','-.','-'};  
my_marker = {'o','>','s','h','p','*','^','v','d' ,'<'};
num_front_xy = 20; % 字体大小
num_FontSize_legend = 22;  % legend的字体大小
num_FontSize_labelTitle = 22;
num_line_width = 2; % 线宽
num_mark_size = 10;
figure(1)
i = 1;
plot(x,fraction_twinType(:,1).*100,...
    'color',char(my_color(i)),...
    'LineWidth',num_line_width,...
    'LineStyle',char(my_lineStyle(i)),...
    'marker',char(my_marker(i)),...
    'MarkerSize',num_mark_size,...
    'MarkerFaceColor',char(my_color(i)),...
    'MarkerEdgeColor',char(my_color(i)),...
    'DisplayName',char(my_type_legendName(i))); 
hold on
i = 2;
plot(x,fraction_twinType(:,2).*100,...
    'color',char(my_color(i)),...
    'LineWidth',num_line_width,...
    'LineStyle',char(my_lineStyle(i)),...
    'marker',char(my_marker(i)),...
    'MarkerSize',num_mark_size,...
    'MarkerFaceColor',char(my_color(i)),...
    'MarkerEdgeColor',char(my_color(i)),...
    'DisplayName',char(my_type_legendName(i))); 
lgd = legend('FontSize',num_FontSize_legend,'TextColor',...
  'black','Location','best','NumColumns',1);
hold off
xlim([0.0 500]);
figWidth = 25;
figHeight = 9;

xlabel('Time (min)','FontSize',num_FontSize_labelTitle,'FontName','Times New Roman','FontWeight','bold');
ylabel('Fraction of TBG (%)','FontSize',num_FontSize_labelTitle,'FontName','Times New Roman','FontWeight','bold');
set(gca,'FontSize',num_front_xy,...
  'Linewidth',num_line_width,...
  'FontName','Times New Roman'); % 设置x y轴

set(gcf,'unit','centimeters','position',[0,0,figWidth,figHeight])
set(gcf,'Color','None'); % 设置图窗的颜色为透明，gcf 返回当前Figure 对象的句柄值
set(gca,'Color','None'); % 设置图中背景颜色为透明，返回当前axes 对象的句柄值

% D:\Github\PandaScripts\p21-GMSTi-2023\experiments\exp1_draw_coherence_and_incoherence_curve.m