function [P_binarization] = CrossingTracer(threshold_global,P_cen,P_seg,corner_pos,buffer_intersection,buffer_terminal)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

P_skel=bwmorph(P_cen,'skel',inf);
Empirical_Width=length(find(F_seg~=0))./length(find(F_skel~=0));
threshold_local=threshold_global.*ones(size(P_cen));
E_total=ones(size(P_seg));

buffer_size=100; % important 定义交叉口为中心半径为buffer_size的作用区域
all_crossing=1; % all_crossing: 是否对所有交叉口都使用CrossingTracer以追踪 0 or 1
Factor_reduction=0.5;% 交叉口对于路网的判别权重与原始路面的权重相等
for i=1:size(corner_pos,1)
    if ((corner_pos(i,2)<buffer_size)||(corner_pos(i,1)<buffer_size)||(corner_pos(i,4)+buffer_size>row)||(corner_pos(i,3)+buffer_size>col))
        continue;
    end
    if (all_crossing~=1) 
        if corner_pos(i,6)==1 % 是否只作用于假交叉口
            continue;
        end
    end
    % 中心线
    F_cen=P_cen(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:);
    % 路面分割
    F_seg=P_seg(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:);
    Cost_idx=find(F_seg~=0);% 原始路面分割中的道路像素取值为(0,255)

    Cost=1-0.5*F_seg./255;% 代价项 原始路面分割中的道路像素取值为(0,255)  归一化至(0,1)区间  原始为道路(255)代价为0.5  原始为背景(0)代价为1
    confidence=corner_pos(i,5); % 交叉口检测的置信程度
    P=confidence*ones(size(F_cen)); % 惩罚项 与置信程度有关
    D=zeros(size(F_cen));
    r=buffer_size/2;
    for ii=1:size(F_cen,1)
        for jj=1:size(F_cen,2)
            D(ii,jj)=sqrt((ii-r).^2+(jj-r).^2);
        end
    end
    D_nor=(max(max(D))-D)./(max(max(D))-min(min(D)));
    T=1-D_nor;
    E=zeros(size(Cost));
    for ii=1:size(F_cen,1)
       for jj=1:size(F_cen,2)
           if (Cost(ii,jj)<=0.5) % 原始路面
               E(ii,jj)=Cost(ii,jj);
           elseif (Cost(ii,jj)>0.5) % 背景路面
               E(ii,jj)=Cost(ii,jj)-0.5*Factor_reduction*P(ii,jj)*T(ii,jj);
           end       
       end
    end   
    E_TEM=2*E;
%     E_total(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:)=E_TEM;
end


end