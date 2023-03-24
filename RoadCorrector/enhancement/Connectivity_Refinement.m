
% P_image=imread("");% 原始影像
% P_seg=imread("");% 路面分割
P_cen=imread("E:\RoadTracer_GRSL\3\chicago.png");% 道路中心线
corner_pos=load("E:\ALL_GRSL_Cal\Img8192_txt\chicago.txt"); % 交叉口检测结果
[row,col]=size(P_cen);

% 中心线的初始阈值设置 (CrossingTracer or Traditional method) 经验阈值为30 可按实际情况调整
%% Otsu
h = histogram(P_cen);
threshold_otsu = 255*graythresh(P_cen);

%% CrossingTracer



%%

P_cen(P_cen<threshold_otsu)=0;
P_cen(P_cen>=threshold_otsu)=255;
P_cen = bwareaopen(P_cen,2000,8); % 小区域去除
figure()
imshow(P_cen);


buffer_size=100;% important 定义交叉口为中心半径为buffer_size的作用区域
all_crossing=1;% all_crossing: 是否对所有交叉口都使用CrossingTracer以追踪 0 or 1
P_fusion=P_seg;
for i=1:size(corner_pos,1)
    if ((corner_pos(i,2)<buffer_size)||(corner_pos(i,1)<buffer_size)||(corner_pos(i,4)+buffer_size>row)||(corner_pos(i,3)+buffer_size>col))
        continue;
    end
    if (all_crossing~=1) 
        if corner_pos(i,6)==1 % 是否只作用于假交叉口
            continue;
        end
    end

    detectron_img=P_image(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:);
    detectron_mask=P_seg(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:);
    detectron_lines=P_cen(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:);
    [detectron_fusion,Expansion_Width,Empirical_Width] = Buffer_Fusion(detectron_mask,detectron_lines,corner_pos(i,6));
%     subplot(2,2,1);
%     imshow(detectron_img);
%     subplot(2,2,2);
%     imshow(detectron_mask);
%     subplot(2,2,3);
%     imshow(detectron_lines);
%     subplot(2,2,4);
%     imshow(detectron_GT);

    P_fusion(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:)=detectron_fusion;
end

% P_fusion = bwareaopen(P_fusion,5000,8);% 仍然不连续的细碎路段将通过形态学方法去除
figure
imshow(P_fusion);
% imwrite(P_fusion,'');





