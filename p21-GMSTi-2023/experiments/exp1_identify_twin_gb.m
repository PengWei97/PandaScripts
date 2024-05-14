clear all
close all
clc

num_fig = 1;
my_input_dir = 'D:\Github\PandaData\p31_CoupledCPPF_2024\experiments\ctf\exp_550du\';
my_file_time = {'30min', '120min', '240min', '480min'};
% my_file_time = {'10min', '30min', '60min', '120min'};
% crystal symmetry
CS = {... 
  'notIndexed',...
  crystalSymmetry('6/mmm', [3 3 4.7], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Ti-Hex', 'color', [0.53 0.81 0.98])};

fraction_twinType1 = zeros(length(my_file_time),2);
fraction_twinType2 = zeros(length(my_file_time),2);
fraction_twinType = zeros(length(my_file_time),2);

for i = 1:4
  my_inputfile = strcat('Ti550du_',char(my_file_time(i)),'_excerpt.ctf');
  fname = [my_input_dir my_inputfile]; 

  setMTEXpref('zAxisDirection','outOfPlane'); % outOfPlane
  setMTEXpref('xAxisDirection','east'); % 1-east， 2-west

  % if (i == 3) || (i == 4)
  %   setMTEXpref('zAxisDirection','outOfPlane'); % outOfPlane
  %   setMTEXpref('xAxisDirection','west'); % 1-east， 2-west
  % end

  ebsd = EBSD.load(fname,CS,'interface','ctf',...
                   'convertEuler2SpatialReferenceFrame'); % 460*550

  % 识别晶粒操作
  [grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'threshold',1.0*degree);
  grains = smooth(grains,50);
  ebsd(grains(grains.grainSize<10)) = [];
  [grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'threshold',1.0*degree); % ,'boundary','tight'

  % %% 1 - 可视化 - ebsd map
  % figure(num_fig*i);
  % plot(ebsd,ebsd.orientations,'coordinates','off','micronbar','on');
  % hold on
  % plot(grains.boundary,'linewidth',0.8,'micronbar','off');
  % hold off 

  % b-twin boundary
  gB = grains.boundary;
  gB_TiTi = gB('Ti-Hex','Ti-Hex');
  CS_Ti = grains.CS;                          
  twinning1 = orientation.byAxisAngle(Miller({1 1 -2 0},ebsd.CS),85*degree); % orientation [30   85  330]
  twinning2 = orientation.byAxisAngle(Miller({1 0 -1 0},ebsd.CS),65*degree); % [300   35   60]
  % twinning3 = orientation.byAxisAngle(Miller({1 0 -1 0},ebsd.CS),65*degree); % orientation [0   65    0]
  % twinning4 = orientation.byAxisAngle(Miller({1 1 -2 0},ebsd.CS),57*degree); % [30   57  330]

  twinning = [twinning1, twinning2];
  tolerance_mis = 5.0;

  isTwinning1 = angle(gB_TiTi.misorientation,twinning(1)) < tolerance_mis*degree;
  isTwinning2 = angle(gB_TiTi.misorientation,twinning(2)) < tolerance_mis*degree;
  % isTwinning3 = angle(gB_MgMg.misorientation,twinning(3)) < tolerance_mis*degree;
  % isTwinning4 = angle(gB_MgMg.misorientation,twinning(4)) < tolerance_mis*degree;

  twinBoundary1 = gB_TiTi(isTwinning1);
  twinBoundary2 = gB_TiTi(isTwinning2);

  %% coherent or incoherent twin boundary
  % gb direction in crystal coordinates
  gbdirc1 = inv(grains(twinBoundary1.grainId).meanOrientation).*twinBoundary1.direction;
  gbdirc2 = inv(grains(twinBoundary2.grainId).meanOrientation).*twinBoundary2.direction;
  % angle between gbdirc and {1,0,-1,2}
  MAngle1 = angle(gbdirc1,Miller(1,0,-1,2,ebsd('Ti-Hex').CS));
  MAngle2 = angle(gbdirc2,Miller(1,1,-2,2,ebsd('Ti-Hex').CS));

  GBcoherent1 = gbdirc1(any(MAngle1 < tolerance_mis*degree,2));
  GBcoherent2 = gbdirc2(any(MAngle2 < tolerance_mis*degree,2));
  GBincoherent1 = gbdirc1(all(MAngle1 > tolerance_mis*degree,2));
  GBincoherent2 = gbdirc2(all(MAngle2 > tolerance_mis*degree,2));

  twinBoundary1_coherent = twinBoundary1(any(MAngle1 <= tolerance_mis*degree,2));
  twinBoundary1_incoherent = twinBoundary1(all(MAngle1 > tolerance_mis*degree,2));

  twinBoundary2_coherent = twinBoundary2(any(MAngle2 <= tolerance_mis*degree,2));
  twinBoundary2_incoherent = twinBoundary2(all(MAngle2 > tolerance_mis*degree,2));

  fraction_twinType1(i,1) = sum(twinBoundary1_coherent.segLength)/sum(twinBoundary1.segLength);
  fraction_twinType1(i,2) = sum(twinBoundary1_incoherent.segLength)/sum(twinBoundary1.segLength);
  fraction_twinType2(i,1) = sum(twinBoundary2_coherent.segLength)/sum(twinBoundary2.segLength);
  fraction_twinType2(i,2) = sum(twinBoundary2_incoherent.segLength)/sum(twinBoundary2.segLength);
  
  coherence_TBG = [twinBoundary1_coherent, twinBoundary2_coherent];
  incoherence_TBG = [twinBoundary1_incoherent, twinBoundary2_incoherent];
  TGB = [twinBoundary1, twinBoundary2];

  fraction_twinType(i,1) = sum(coherence_TBG.segLength)/sum(TGB.segLength);
  fraction_twinType(i,2) = sum(incoherence_TBG.segLength)/sum(TGB.segLength);

  % 可视化 2 凸显孪晶界
  figure(i);
  plot(grains.boundary,'linewidth',0.8,'micronbar','off');
  hold on
  plot(incoherence_TBG,'linecolor','Red','linewidth',3,'displayName','Incoherent twin boundary');
  plot(coherence_TBG,'linecolor','Blue','linewidth',3,'displayName','Coherent twin boundary');

  % plot(twinBoundary1,'linecolor','Blue','linewidth',3,'displayName','Compression twin boundary');
  % plot(twinBoundary2,'linecolor','Red','linewidth',3,'displayName','Tensile twin boundary');
  hold off
  lgd = legend('FontSize',18,'TextColor','black','Location','southeast','NumColumns',1,'FontName','Times New Roman');
  % set(lgd, 'Visible', 'off'); % 隐藏图例

  % set(gcf,'Color','None'); % 设置图窗的颜色为透明，gcf 返回当前Figure 对象的句柄值
  % set(gca,'Color','None'); % 设置图中背景颜色为透明，返回当前axes 对象的句柄值
end

% sum(twinBoundary1_coherent.segLength)/sum(twinBoundary1.segLength)
% D:\Github\PandaScripts\p21-GMSTi-2023\experiments\exp1_identify_twin_gb.m
