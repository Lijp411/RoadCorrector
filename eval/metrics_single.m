
P_test=imread("");% Read the road segmentation map (8192*8192)
GT=imread("");% GroundTruth (8192*8192)

P_union=zeros(size(P_GT));
P_union(find(P_GT~=0))=1;
P_union(find(P_test~=0))=1;

A=GT&P_test;

TP=length(find(P_test~=0&P_GT~=0)==1);
TN=length(find(P_test==0&P_GT==0)==1);
FP=length(find(P_test==0&P_GT~=0)==1);
FN=length(find(P_test~=0&P_GT==0)==1);

Acc=(TP+TN)/(TP+TN+FP+FN)
Precision=TP/(TP+FP)
Recall=TP/(TP+FN)
F1=2*Recall*Precision/(Recall+Precision)
IOU=(length(find(A==1)))/(length(find(P_union~=0)))