# RoadCorrector: An intersection-aware road extraction method for road connectivity and topology correction

## Abstract
  Road extraction from high-resolution remote sensing images has been an important research problem for decades. Due to the challenges such as the occlusion of trees and the stacking of multiple roads in complex scenes, existing road extraction methods still suffer from generating broken road surfaces, inaccurate topology and connections, etc. In this work, we propose a new road extraction method, named RoadCorrector, which solves the above limitations of existing methods via adding a road intersection detection network and two road correction modules. Specifically, RoadCorrector contains three main modules, i.e., intersection detection and road extraction, connectivity refinement, and topology correction. Based on the outputs of road extraction and intersection detection, the connectivity refinement module enables the complementary advantages of road segmentation and centerline tracking through the constraints of energy function, which enhances the road connectivity in the occluded and intersection regions. The topology correction module aims at constructing more accurate road connection relations, producing the final vectorized road network with more accurate topology information. Experimental results show that our proposed method achieves remarkable improvements compared with state-of-the-art methods, with the F1-score and intersection over union (IoU) improved by 1.1%-7.9% and 1.6%-11.3%, respectively.
Moreover, the road network extraction results of RoadCorrector have more accurate connection relations and topology, demonstrating its great potential in actual application scenes. 


## Note

 * RoadCorrector used [YOLOv7](https://github.com/WongKinYiu/yolov7) in the object detection stage, requiring users to install the corresponding environment in the root file directory of this experiment, so as to directly conduct the inspection of stacked intersections and ordinary intersections.

 * In the road network extraction stage, RoadCorrector is based on [D-Linknet]() and [RoadTracer](), which requires users to install the corresponding environment in the root file directory of this experiment, so as to directly extract the road network and road centerline.

   ![image-20230324153121154](figure\image-20230324153121154.png)

## Dataset Preparation

This repo only tested on [RoadTracer dataset](https://roadmaps.csail.mit.edu/roadtracer).Users need to download the Dataset and place it in the Dataset folder.

## Intersection Detection

 * After installing YOLOv7 and obtaining the RoadTracer dataset, users need to crop the 4096×4096 small image in RoadTracer into 640×640 sub-images using Crop_Image.py in tools.

 * After obtaining the corresponding subimage by cropping, place it in the same folder as the annotation file provided in dataset/intersection annotations (a new folder is recommended).

 * Users can put the DetectionExport.py provided in tools (this script does not require data format) and the training model provided in model/YOLOv7 into the root directory of YOLOv7 and run it to get the intersection detection results of the corresponding image (TXT format).

 * Users can use [roboflow](https://roboflow.com/) to convert the dataset to your desired MSCOCO or YOLO dataset format.*

## Road Extraction
 ### Fusion enhancement
*Matlab Connectivity_Refinement.m*
  This module mainly focuses on road connectivity enhancement using CrossingTracer and Buffer-Fusion strategies.

 ### Evaluation
*Matlab metrics_single.m*
It will evalute this model in test dataset, and print the metrics, including IOU, precision, recall, F1.

## Contact us
For any questions,please contact us via hejun36@mail2.sysu.edu.cn or lijp57@mail2.sysu.edu.cn.

