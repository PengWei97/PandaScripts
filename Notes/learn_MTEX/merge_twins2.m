
%% 创建数组
colNames = {'GrainID', 'Ori_m', 'Ori_t', 'SF-V1', 'SF-V2', 'SF-V3', 'SF-V4', 'SF-V5', 'SF-V6', 'Activated', 'GrainSize'};
varTypes = {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'string', 'double'};
T = table('Size', [0, size(colNames,2)], 'VariableNames', colNames, 'VariableTypes', varTypes);

while true
    figure(h1);

    disp('请用鼠标点击母体晶粒，以获取其晶体取向。')
    [x,y]=ginputzp(1);
    Mori=ebsd(x,y);
    % 得到母体晶粒取向
    Mori=Mori.orientations;
    % 得到母体晶粒merged之后的ID，知道ID后，计算其等效圆晶粒尺寸和滑移系水平晶粒尺寸
    ID_m=mergedGrains(x,y).id;

    disp('母体晶粒取向已定义完成，请用鼠标点击孪晶，以获取其晶体取向。')
    % 选择孪晶
    [x,y]=ginputzp(1);
    Tori=ebsd(x,y);
    % 得到孪晶变体晶粒取向
    Tori=Tori.orientations;
    ID_t=grains(x,y).id;
    disp('孪晶取向已完成定义。')

    figure(h2)
    hold on
    plot(mergedGrains(ID_m).boundary,'linewidth',2,'lineColor','white')
        hold on
    plot(grains(ID_t).boundary,'linewidth',2,'lineColor','blue')
    hold off

    % 母体晶粒和实际孪晶取向定义完成
    % 可画出母体晶粒和孪晶变体的PF图，可选
        McS=crystalShape.hex(Mori.CS);
        McSGrains=Mori*McS*0.8;
        % 根据母体晶粒取向得到的密排六方结构
        setMTEXpref('xAxisDirection','east');
        setMTEXpref('zAxisDirection','outtoPlane');
        h=[Miller(0,0,0,1,cs), Miller(1,0,-1,0,cs), Miller(1,1,-2,0,cs)];
        % 上述Mtex设定得到的PF图的xy轴，与C5软件中默认的xy轴一致
        figure
        plotPDF(Mori,h,'antipodal') % contour 可选参数
        % plotPDF(calcDensity(ori),h,'antipodal') % contour 可选参数
        hold all
        plot(Mori,0.6*McSGrains,'add2all') % add2all 可选参数
        % 也画出实际孪晶的PF
        plotPDF(Tori,h,'antipodal') % contour 可选参数
        hold off

    %% 根据母体晶粒取向推演六个孪晶变体的取向
    % 六个孪晶变体转转轴，及其所对应的孪晶指数
    ax1=Miller(1,1,-2,0,cs,'uvw');
    ax2=Miller(1,-2,1,0,cs,'uvw');
    ax3=Miller(-1,2,-1,0,cs,'uvw');
    ax4=Miller(-1,-1,2,0,cs,'uvw');
    ax5=Miller(-2,1,1,0,cs,'uvw');
    ax6=Miller(2,-1,-1,0,cs,'uvw');

    ax=[ax1 ax2 ax3 ax4 ax5 ax6];
    V1="(-1102)[1-101]";
    V2="(10-12)[-1011]";
    V3="(-1012)[10-11]";
    V4="(1-102)[-1101]";
    V5="(0-112)[01-11]";
    V6="(01-12)[0-111]";

    % 六个孪晶转轴在母体晶粒取向上的指数
    vari1=Mori * ax1;
    vari2=Mori * ax2;
    vari3=Mori * ax3;
    vari4=Mori * ax4;
    vari5=Mori * ax5;
    vari6=Mori * ax6;
    % 旋转角度
    angle=86.3;
    % 旋转矢量
    rot1=rotation('axis',vari1,'angle',angle*degree);
    rot2=rotation('axis',vari2,'angle',angle*degree);
    rot3=rotation('axis',vari3,'angle',angle*degree);
    rot4=rotation('axis',vari4,'angle',angle*degree);
    rot5=rotation('axis',vari5,'angle',angle*degree);
    rot6=rotation('axis',vari6,'angle',angle*degree);
    % 最终得到潜在的孪晶变体晶体取向
    Tori_theory_1=rot1 * Mori;
    Tori_theory_2=rot2 * Mori;
    Tori_theory_3=rot3 * Mori;
    Tori_theory_4=rot4 * Mori;
    Tori_theory_5=rot5 * Mori;
    Tori_theory_6=rot6 * Mori;
    %% 计算六个理论孪晶变体与实际孪晶变体之间的取向差，即c轴角度差
    misori1=c_mis([rad2deg(Tori_theory_1.phi1),rad2deg(Tori_theory_1.Phi),rad2deg(Tori_theory_1.phi2)],...
        [rad2deg(Tori.phi1),rad2deg(Tori.Phi),rad2deg(Tori.phi2)]);
    misori2=c_mis([rad2deg(Tori_theory_2.phi1),rad2deg(Tori_theory_2.Phi),rad2deg(Tori_theory_2.phi2)],...
        [rad2deg(Tori.phi1),rad2deg(Tori.Phi),rad2deg(Tori.phi2)]);
    misori3=c_mis([rad2deg(Tori_theory_3.phi1),rad2deg(Tori_theory_3.Phi),rad2deg(Tori_theory_3.phi2)],...
        [rad2deg(Tori.phi1),rad2deg(Tori.Phi),rad2deg(Tori.phi2)]);
    misori4=c_mis([rad2deg(Tori_theory_4.phi1),rad2deg(Tori_theory_4.Phi),rad2deg(Tori_theory_4.phi2)],...
        [rad2deg(Tori.phi1),rad2deg(Tori.Phi),rad2deg(Tori.phi2)]);
    misori5=c_mis([rad2deg(Tori_theory_5.phi1),rad2deg(Tori_theory_5.Phi),rad2deg(Tori_theory_5.phi2)],...
        [rad2deg(Tori.phi1),rad2deg(Tori.Phi),rad2deg(Tori.phi2)]);
    misori6=c_mis([rad2deg(Tori_theory_6.phi1),rad2deg(Tori_theory_6.Phi),rad2deg(Tori_theory_6.phi2)],...
        [rad2deg(Tori.phi1),rad2deg(Tori.Phi),rad2deg(Tori.phi2)]);

    % 取向差数组
    misori=[misori1,misori2,misori3,misori4,misori5,misori6];
    [~,id]=min(misori);
    misori_name=["V1","V2","V3","V4","V5","V6"];
    % 旋转轴
    ax_index=round(ax.UVTW);
    fprintf('\n')
    disp('----------------------------Summary-------------------------')
    fprintf('----母体晶粒的三个欧拉角为%.2f°,%.2f°,%.2f° \n',rad2deg(Mori.phi1),rad2deg(Mori.Phi),rad2deg(Mori.phi2))
    fprintf('----实际孪晶的三个欧拉角为%.2f°,%.2f°,%.2f° \n',rad2deg(Tori.phi1),rad2deg(Tori.Phi),rad2deg(Tori.phi2))
    fprintf('----理论孪晶V1:(-1102)[1-101]的三个欧拉角为%.2f°,%.2f°,%.2f°,与实际孪晶取向差为%.2f° \n',rad2deg(Tori_theory_1.phi1),rad2deg(Tori_theory_1.Phi),rad2deg(Tori_theory_1.phi2),misori(1))
    fprintf('----理论孪晶V2:(10-12)[-1011]的三个欧拉角为%.2f°,%.2f°,%.2f°,与实际孪晶取向差为%.2f° \n',rad2deg(Tori_theory_2.phi1),rad2deg(Tori_theory_2.Phi),rad2deg(Tori_theory_2.phi2),misori(2))
    fprintf('----理论孪晶V3:(-1012)[10-11]的三个欧拉角为%.2f°,%.2f°,%.2f°,与实际孪晶取向差为%.2f° \n',rad2deg(Tori_theory_3.phi1),rad2deg(Tori_theory_3.Phi),rad2deg(Tori_theory_3.phi2),misori(3))
    fprintf('----理论孪晶V4:(1-102)[-1101]的三个欧拉角为%.2f°,%.2f°,%.2f°,与实际孪晶取向差为%.2f° \n',rad2deg(Tori_theory_4.phi1),rad2deg(Tori_theory_4.Phi),rad2deg(Tori_theory_4.phi2),misori(4))
    fprintf('----理论孪晶V5:(0-112)[01-11]的三个欧拉角为%.2f°,%.2f°,%.2f°,与实际孪晶取向差为%.2f° \n',rad2deg(Tori_theory_5.phi1),rad2deg(Tori_theory_5.Phi),rad2deg(Tori_theory_5.phi2),misori(5))
    fprintf('----理论孪晶V6:(01-12)[0-111]的三个欧拉角为%.2f°,%.2f°,%.2f°,与实际孪晶取向差为%.2f° \n',rad2deg(Tori_theory_6.phi1),rad2deg(Tori_theory_6.Phi),rad2deg(Tori_theory_6.phi2),misori(6))
    fprintf('----你的这个孪晶为%s,转轴为<%d%d%d%d> \n',misori_name(id),ax_index(id,:));
    disp('----------------------------End-------------------------')
    %% so far so good
    %% SF计算
    %% Mtex计算SF
    sSttwin=slipSystem.twinT1(cs);
    sS=sSttwin.symmetrise('antipodal');
    sSLocal=Mori*sS;
    % 单轴应力
    sigma = -1 * stressTensor.uniaxial(vector3d.X);    % 必须要根据个人情况定义力轴方向,-1代表压，1代表拉
    SF=sSLocal.SchmidFactor(sigma);
    %
    fprintf('\n')
    fprintf('---Mtex计算结果---\n')
    fprintf('   V1-(%d%d%d%d)<%d%d%d%d>-SF: %.3f\n',round(sS(1).n.hkil),round(sS(1).b.UVTW),SF(1))
    fprintf('   V2-(%d%d%d%d)<%d%d%d%d>-SF: %.3f\n',round(sS(2).n.hkil),round(sS(2).b.UVTW),SF(2))
    fprintf('   V3-(%d%d%d%d)<%d%d%d%d>-SF: %.3f\n',round(sS(3).n.hkil),round(sS(3).b.UVTW),SF(3))
    fprintf('   V4-(%d%d%d%d)<%d%d%d%d>-SF: %.3f\n',round(sS(4).n.hkil),round(sS(4).b.UVTW),SF(4))
    fprintf('   V5-(%d%d%d%d)<%d%d%d%d>-SF: %.3f\n',round(sS(5).n.hkil),round(sS(5).b.UVTW),SF(5))
    fprintf('   V6-(%d%d%d%d)<%d%d%d%d>-SF: %.3f\n',round(sS(6).n.hkil),round(sS(6).b.UVTW),SF(6))
    disp('-------End------')
    %% 按照重大师弟要求，加上可视化，画个PF和IPF的图
    % 再次罗列出目前有的几个晶体取向
    % 1、母体晶粒的取向，Mori，通过输入欧拉角定义
    % 2、实际孪晶的取向，Tori，通过输入欧拉角定义
    % 3、母体晶粒的六个理论孪晶变体取向，Tori_theory_1、Tori_theory_2、Tori_theory_3、Tori_theory_4、Tori_theory_5、Tori_theory_6

    %     setMTEXpref('xAxisDirection','east');
    %     setMTEXpref('zAxisDirection','outtoPlane');
    %     figure
    %     plotPDF(Mori,h(1),'grid','grid_res',30*degree,'antipodal')
    %     hold all
    %     strP='P';    % 给母体晶粒加上标签
    %     annotate(Mori,'label',{strP},'MarkerSize',1,'VerticalAlignment','top');
    %     plotPDF(Tori,h(1),'DisplayName','Actual Variant','MarkerSize',8,'MarkerColor','g','grid','grid_res',30*degree,'antipodal')
    %     plotPDF(Tori_theory_1,h(1),'DisplayName','Variant 1','MarkerSize',8,'MarkerColor','b','grid','grid_res',30*degree,'antipodal') % contour 可选参数
    %     plotPDF(Tori_theory_2,h(1),'DisplayName','Variant 2','MarkerSize',8,'MarkerColor','y','grid','grid_res',30*degree,'antipodal') % contour 可选参数
    %     plotPDF(Tori_theory_3,h(1),'DisplayName','Variant 3','MarkerSize',8,'MarkerColor','m','grid','grid_res',30*degree,'antipodal') % contour 可选参数
    %     plotPDF(Tori_theory_4,h(1),'DisplayName','Variant 4','MarkerSize',8,'MarkerColor','c','grid','grid_res',30*degree,'antipodal') % contour 可选参数
    %     plotPDF(Tori_theory_5,h(1),'DisplayName','Variant 5','MarkerSize',8,'MarkerColor','r','grid','grid_res',30*degree,'antipodal') % contour 可选参数
    %     plotPDF(Tori_theory_6,h(1),'DisplayName','Variant 6','MarkerSize',8,'MarkerColor','k','grid','grid_res',30*degree,'antipodal') % contour 可选参数
    %
    %     % 将各拉伸孪晶变体的SF转化为字符串，方便显示
    %     V1_SF=num2str(round(ExtTwinArray(1,1),3));
    %     V2_SF=num2str(round(ExtTwinArray(1,2),3));
    %     V3_SF=num2str(round(ExtTwinArray(1,3),3));
    %     V4_SF=num2str(round(ExtTwinArray(1,4),3));
    %     V5_SF=num2str(round(ExtTwinArray(1,5),3));
    %     V6_SF=num2str(round(ExtTwinArray(1,6),3));
    %     % 给孪晶变体加上标签
    %     annotate(Tori_theory_1,'label',{V1_SF},'MarkerSize',1,'VerticalAlignment','top');
    %     annotate(Tori_theory_2,'label',{V2_SF},'MarkerSize',1,'VerticalAlignment','top');
    %     annotate(Tori_theory_3,'label',{V3_SF},'MarkerSize',1,'VerticalAlignment','top');
    %     annotate(Tori_theory_4,'label',{V4_SF},'MarkerSize',1,'VerticalAlignment','top');
    %     annotate(Tori_theory_5,'label',{V5_SF},'MarkerSize',1,'VerticalAlignment','top');
    %     annotate(Tori_theory_6,'label',{V6_SF},'MarkerSize',1,'VerticalAlignment','top');
    %     hold off
    %     legend('show');

    %% 等效圆直径
    P=mergedGrains(ID_m).equivalentPerimeter;

    %% 滑移系水平晶粒尺寸、


    %% 保存到数组
    newData = {ID_m,...
               [rad2deg(Mori.phi1),rad2deg(Mori.Phi),rad2deg(Mori.phi2)],...
               [rad2deg(Tori.phi1),rad2deg(Tori.Phi),rad2deg(Tori.phi2)],...
               SF(1),SF(2),SF(3),SF(4),SF(5),SF(6),...
               misori_name(id),...
               P};
    T = [T; newData]; % 在表格末尾添加新行数据

    cha=get(gcf,'CurrentCharacter');
    if strcmpi(cha,'q')   % q means quit
        cha='z';
        break;
    end

end