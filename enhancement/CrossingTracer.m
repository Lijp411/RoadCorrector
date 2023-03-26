function [E_total] = CrossingTracer(threshold_global,P_cen,P_seg,corner_pos,buffer_intersection,buffer_terminal)
% CrossingTracer
% CrossingTracer is a local adaptive threshold segmentation strategy for road centerlines. 
% On the basis of the global threshold, an energy function is constructed to promote the 
% extraction of the road network at the discontinuous road segments. The energy function 
% is composed of a cost term and a smoothness term. The cost term considers the prior 
% information of the original road surface, and the smoothness term is related to the type 
% of the current intersection. For discontinuous road segments, the existence of smoothing 
% term can appropriately reduce the threshold to better maintain better road connectivity, 
% and effectively overcome the problems of tree occlusion and shadow coverage.

P_skel=bwmorph(P_cen,'skel',inf);
Empirical_Width=length(find(P_seg~=0))./length(find(P_skel~=0));
threshold_local=threshold_global.*ones(size(P_cen));
E_total=ones(size(P_seg));
[row,col]=size(P_seg);

corner_pos(:,5)=1;

buffer_size=30;
all_crossing=1;
Factor_reduction=0.5;% The discriminant weight of the intersection for the road network is equal to the weight of the original road surface
for i=1:size(corner_pos,1)
    if ((corner_pos(i,2)<buffer_size)||(corner_pos(i,1)<buffer_size)||(corner_pos(i,4)+buffer_size>row)||(corner_pos(i,3)+buffer_size>col))
        continue;
    end
    if (all_crossing~=1) 
        if corner_pos(i,6)==1
            continue;
        end
    end
    % centerline map
    F_cen=P_cen(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:);
    % segmentation map
    F_seg=P_seg(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:);
    Cost_idx=find(F_seg~=0);% The value interval of road pixels in the original road surface segmentation is (0,255)

    Cost=1-0.5*F_seg./255;% Cost term   (The original is a road (255) with a cost of 0.5/The original is background 0 and the cost is 1)
    confidence=corner_pos(i,5); % Confidence level of intersection detection
    P=confidence*ones(size(F_cen)); % P (related to the confidence level)
    D=zeros(size(F_cen));
    r=(size(F_cen,1)+size(F_cen,2))/4;
    for ii=1:size(F_cen,1)
        for jj=1:size(F_cen,2)
            D(ii,jj)=sqrt((ii-r).^2+(jj-r).^2);
        end
    end
    D_nor=(max(max(D))-D)./(max(max(D))-min(min(D)));
    T=D_nor;
    E=zeros(size(Cost));
    for ii=1:size(F_cen,1)
       for jj=1:size(F_cen,2)
           if (Cost(ii,jj)<=0.5) % The pixel of road
               E(ii,jj)=Cost(ii,jj);
           elseif (Cost(ii,jj)>0.5) % The pixel of background
               E(ii,jj)=double(Cost(ii,jj))-Factor_reduction*P(ii,jj)*T(ii,jj);
%                E(ii,jj)=double(Cost(ii,jj))-P(ii,jj)*T(ii,jj);
           end       
       end
    end   
    E_TEM=E;
    E_total(corner_pos(i,2)+1-buffer_size/2:corner_pos(i,4)+buffer_size/2,corner_pos(i,1)+1-buffer_size/2:corner_pos(i,3)+buffer_size/2,:)=E_TEM;
end

E_total(find(E_total==0))=1;

end