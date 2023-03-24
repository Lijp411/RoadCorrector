import os
import numpy as np
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import Element
import cv2
from tqdm import tqdm
 
ImgType = [".png",".jpg",".bmp",".tif",".tiff"]

def XMLchange(img_path,ann_path,save_path):
    """
    XMLchange Function

    The function is used to change the XML annotations,
    Make sure the folder containing the images is in the same parent folder as the folder containing the annotations.

    img_path : The original images folder (640 × 640)
    ann_path : The annotations folder (XML format)
    save_path : The output XML file folder (XML format)

    """

    if os.path.exists(save_path) == False:
        os.mkdir(save_path)

    for file in tqdm(os.listdir(img_path)):
        filename,fileext = os.path.splitext(file)
        if fileext in ImgType:# if the file is image then continue
            xml_name = filename.split("_")[-1]
            tree = ET.parse(os.path.join(ann_path,xml_name + ".xml")) #read annotations of the image
            root = tree.getroot()
            for child in root:
                if child.tag == "filename":# change the filename of annotations
                    child.text = file
                if child.tag == "path": # change the image path of the annotations
                    child.text = os.path.join(img_path,file)
            tree.write(os.path.join(save_path,filename + ".xml "), encoding="utf-8", xml_declaration=False) # save the new annotations
    
def ImgRename(img_path,city_name,save_path):

    """
    ImgRename Function

    The function is used to march the sub-images with the original city name

    img_path : The sub-images folder (640 × 640)
    city_name : The original images folder (before cropped)
    save_path : The output images folder

    """
    CityName = os.listdir(city_name)

    if os.path.exists(save_path) == False:
        os.mkdir(save_path)

    counter = 1
    ImgLen = len(os.listdir(img_path)) / 2

    for file in tqdm(os.listdir(img_path)):
        filename,fileext = os.path.splitext(file)

        if counter / ImgLen < 2/3 : # according to relative proportion the divide the dataset(4:1:1)
            Last_Path = os.path.join(save_path,"train")
        
        if counter / ImgLen < 5/6 and counter / ImgLen > 2/3:
            Last_Path = os.path.join(save_path,"val")

        if counter / ImgLen <= 1 and counter / ImgLen > 5/6:
            Last_Path = os.path.join(save_path,"test")
            
        if os.path.exists(Last_Path) == False:
            os.mkdir(Last_Path)

        if fileext in ImgType:
            img = cv2.imread(os.path.join(img_path,file)) 
            ImgNum = int(filename)
            index = int(ImgNum / 49)
            if ImgNum % 49 == 0: # if the image can be totally divide by the sub image number
                index = index - 1 # the index should -1 
            cv2.imwrite(os.path.join(Last_Path,CityName[index] + "_" + file),img)

            counter += 1

if __name__ == "__main__":
    img_path = r"E:\Road extraction and recognition\Data\Raster\Rename_4_1_1\train" 
    ann_path = r"E:\Road extraction and recognition\Data\Raster\Main_Datasets"
    save_path = r"E:\Road extraction and recognition\Data\Raster\Rename_4_1_1\train_ANN"
    XMLchange(img_path,ann_path,save_path)

    img_path = r"E:\Road extraction and recognition\Data\Raster\Main_Datasets"
    city_name = r"E:\Road extraction and recognition\Data\Raster\Imagert_Cilp"
    save_path = r"E:\Road extraction and recognition\Data\Raster\Rename_4_1_1"
    ImgRename(img_path,city_name,save_path)