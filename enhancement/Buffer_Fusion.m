function [F_fuse,Expansion_Width,Empirical_Width] = Buffer_Fusion(F_seg,F_cen,crossing_type)
%UNTITLED3 此处提供此函数的摘要
%   此处提供详细说明

%% 估计Empirical_Width
F_skel=bwmorph(F_cen,'skel',inf);
Empirical_Width=length(find(F_seg~=0))./length(find(F_skel~=0));

%% Buffer-Fusion
Max_IOU=0;
Best_i=0;
for i=1:10
    se = strel('disk',i);
    F_cen_expansion = imdilate(F_cen,se);
%     subplot(1,2,1);
%     imshow(F_cen_expansion);
%     subplot(1,2,2);
%     imshow(F_seg);
%     PT=F_seg&F_cen_expansion;
    F_union=zeros(size(F_cen_expansion));
    F_union(find(F_cen_expansion~=0))=1;
    F_union(find(P_seg_cut~=0))=1;
    imshow(F_union);
    IOU=(length(find(A==1)))/(length(find(F_union~=0)));
    if (IOU>Max_IOU)
        Max_IOU=IOU;
        Best_i=i;
    end
end

se = strel('disk',Best_i);
F_best = imdilate(F_cen,se);
P_union=zeros(size(F_best));
P_union(find(F_best~=0))=1;
P_union(find(P_seg~=0))=1;

Expansion_Width=Best_i;
F_fuse=255*P_union;

end