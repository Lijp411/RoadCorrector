% Connectivity_Refinement is an adaptive algorithm to improve the 
% connectivity of the pavement segmentation graph, aiming to better 
% transform the raster roads into vector roads.
% Contributed by Jinpeng Li (lijp57@mail2.sysu.edu.cn)
% at Sun Yat-sen University, Guangdong, China.

tic
clear;
clc;
P_image=imread("E:\osm\imagery_8192\chicago.png");% path of image
P_seg=imread("E:\ALL_GRSL_Cal\chicago_seg.png");% path of segmentation map
P_cen=imread("E:\ALL_GRSL_Cal\chicago_cen.png");% path of centerline map
corner_pos=load("E:\ALL_GRSL_Cal\crossing\chicago.txt"); % results of intersection detection

P_image=P_image(1:7168,1:7168,:);
P_cen=P_cen(1:7168,1:7168,:);

[row,col]=size(P_cen);
P_cen_Optimization=P_cen;

% Initial threshold setting for the road centerline extraction (CrossingTracer or Traditional method) 
%% Otsu
% h = histogram(P_cen);
threshold_otsu = 255*graythresh(P_cen);

P_cen(P_cen<threshold_otsu)=0;
P_cen(P_cen>=threshold_otsu)=255;
P_cen = bwareaopen(P_cen,2000,8); % Small area removal
% figure
% imshow(P_cen);

%% CrossingTracer

[E_total] = CrossingTracer(threshold_otsu,P_cen,P_seg,corner_pos);
for i=1:size(P_cen_Optimization,1)
    for j=1:size(P_cen_Optimization,2)
        if (P_cen_Optimization(i,j)<(E_total(i,j)*threshold_otsu))
            P_cen_Optimization(i,j)=0;
        elseif (P_cen_Optimization(i,j)>=(E_total(i,j)*threshold_otsu))
            P_cen_Optimization(i,j)=255;
        end
    end
end
P_cen_Optimization = bwareaopen(P_cen_Optimization,3000,8);
%% 

buffer_size=100;% △The intersection is defined as the action area whose center radius is buffer_size
all_crossing=1;% all_crossing: Whether CrossingTracer should be used for all intersections to track (No——0 or Yes——1)
P_fusion=P_seg;
for i=1:size(corner_pos,1)
    if ((corner_pos(i,2)<buffer_size)||(corner_pos(i,1)<buffer_size)||(corner_pos(i,4)+buffer_size>row)||(corner_pos(i,3)+buffer_size>col))
        continue;
    end
    if (all_crossing~=1) 
        if corner_pos(i,6)==1 % Whether to act only on stacking intersections
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

P_fusion = bwareaopen(P_fusion,5000,8);% Discontinuous fine road segments will be removed by morphological methods
figure
imshow(P_fusion);
% imwrite(P_fusion,'');

toc



