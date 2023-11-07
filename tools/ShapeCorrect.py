
"""

Iteratively correct the intersections by first identifying all intersections, i.e., the starting and ending points of each line, through vector data. 
Remove nearby or duplicate values to obtain all intersections in the image. Then, match the intersections using a detection box to find the most suitable one, 
correct it, and remove the intersection. Repeat the above steps until no intersection appears in the detection box.

"""

import os
import geopandas as gpd
from shapely import geometry
from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import math


#define StartDirection 1
#define EndDirection -1


"""
The Function is used for Calculate the distance between 2 points(x1,y1),(x2,y2)
"""

def DistanceCal(x1,y1,x2,y2):
    distance = np.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1))
    return distance


"""
The Function is used for Correcting the ShapeFile of the Preliminary results of RoadNetwork Extraction.

Contains 3 parameters:

shape_path : The ShapeFile which haven't been corrected in your disk
txt_path : The Detection Box data from Objection Detection (Our Format Only)
dis_threshold : the distance threshold used to match the intersections into the Boxes

"""

def CorrectShape(ShapeData,txt_path,dis_threshold,output_path):
    #Detection Box data process
    Box_Data = pd.read_table(txt_path,header=None,sep="\s+") # read the Detection Box Coordination

    Box_Data = np.array(Box_Data)
    Box_Data = np.delete(Box_Data,np.where(Box_Data[:,5] == 1),axis = 0) # retain the False Crossing,Delete the True Crossing

    Mid_X = (Box_Data[:,0] + Box_Data[:,2]) / 2
    Mid_Y = (Box_Data[:,1] + Box_Data[:,3]) / 2 # Calculate the mid point of the detection boxes

    Box_Data = np.c_[Box_Data,np.c_[Mid_X,Mid_Y]]# Add these columns into the original data

    Line = []
    Direct = []
    for box in Box_Data:
        Line_Index = []
        Tmp_D = []
        Min_Distance = 1e+12
        Min_X,Min_Y = 0,0
        for idx in range(len(ShapeData["geometry"])): # Get which lines in ShapeFile are connecting with the Mid Point of the detection box
            Written = False
            X,Y = ShapeData["geometry"][idx].xy
            Start_Dis = DistanceCal(X[0],-Y[0],box[-2],box[-1])
            End_Dis = DistanceCal(X[-1],-Y[-1],box[-2],box[-1])

            if Start_Dis < Min_Distance and Start_Dis < dis_threshold:
                Min_X = X[0]
                Min_Y = Y[0]
                Min_Distance = Start_Dis

            if End_Dis < Min_Distance and End_Dis < dis_threshold:
                Min_X = X[-1]
                Min_Y = Y[-1]
                Min_Distance = End_Dis

        if Min_Distance == 1e+12:continue

        for idx in range(len(ShapeData["geometry"])):
            Written = False
            X,Y = ShapeData["geometry"][idx].xy
            if X[0] == Min_X and Y[0] == Min_Y:
                Line_Index.append(idx)
                Tmp_D.append(1)
                Written = True

            if X[-1] == Min_X and Y[-1] == Min_Y and Written == False:
                Line_Index.append(idx)
                Tmp_D.append(-1)


        Line.append(Line_Index)
        Direct.append(Tmp_D)


    if len(Direct[0]) == 0:
        print(ShapeData)
        return ShapeData

    Line = np.array(Line,dtype = int)

    slope = []
    for idx in range(len(Box_Data)):
        k = []
        counter = 0
        for ele in Line[idx]:
            X,Y = ShapeData["geometry"][ele].xy
            if Direct[idx][counter] == -1:
                tmp_K = (Y[-2] - Y[-1]) / (X[-2] - X[-1])
                tmp_K = np.rad2deg(np.arctan(tmp_K))
                k.append(tmp_K)

            if Direct[idx][counter] == 1:
                tmp_K = (Y[1] - Y[0]) / (X[1] - X[0])
                tmp_K = np.rad2deg(np.arctan(tmp_K))
                k.append(tmp_K)
            
            counter += 1

        slope.append(k)
    
    slope = np.array(slope)

    Line = np.array(Line)
    Direct = np.array(Direct)

    print(Line)

    Tmp_Shp = ShapeData

    for idx in range(len(slope)):
        for jdx in range(len(slope[idx])):
            Now_A = slope[idx,jdx]
            Now_Idx = Line[idx,jdx]
            Other_A = abs(np.delete(slope[idx],jdx) - Now_A)  # Close Number = min(|OtherAngle - NowAngle|)
            Other_Idx =np.delete(Line[idx],jdx)

            Close_Idx = Other_Idx[np.where(Other_A == min(Other_A))][0]
            if Tmp_Shp["geometry"][Close_Idx] == None:
                continue

            N_X,N_Y = ShapeData["geometry"][Now_Idx].xy
            C_X,C_Y = ShapeData["geometry"][Close_Idx].xy

            Con_X = np.hstack((N_X,C_X))
            Con_Y = np.hstack((N_Y,C_Y))
            Con_XY = np.vstack((Con_X,Con_Y)).T

            Tmp_Shp.loc[len(Tmp_Shp["geometry"])] = {"OBJECTID":len(Tmp_Shp["geometry"]) + 1,"SHAPE_Leng":100,"geometry":geometry.LineString(Con_XY)}
            Tmp_Shp["geometry"] = Tmp_Shp["geometry"].drop([Now_Idx])
            Tmp_Shp["geometry"] = Tmp_Shp["geometry"].drop([Close_Idx])
                

    ShapeData = ShapeData.dropna()
    ShapeData = ShapeData.reset_index(drop = True)
    ShapeData.to_file(output_path,driver='ESRI Shapefile',encoding='utf-8')
    ShapeData = gpd.read_file(output_path)
    CorrectShape(ShapeData,txt_path,dis_threshold)

"""
The function is used for show the shape which extracted by the Detection Box.

Contains 2 parameters:
LineIndex : The Original Index of the lines which have been extracted by the box of the original shapefile
ShapeData : The data of the shapefile which has been read

"""

def ShapeExtract(LineIndex,ShapeData):
    
    for i in range(len(ShapeData["geometry"])):
        if i in LineIndex:
            continue
        ShapeData["geometry"] = ShapeData["geometry"].drop([i]) #if the lines are not in the Extracted Index, delete these lines

    ShapeData.plot()
    plt.show()


def SingleLine(LineIndex,ShapeData):
    cq = gpd.GeoSeries([ShapeData["geometry"][LineIndex]])
    cq.plot()
    plt.show()


if __name__ == "__main__":
    
    #Shapefile processing
    shape_path = r"E:\Road extraction and recognition\Data\shapefile\roadnet\Wrong.shp"
    txt_path = r"E:\Road extraction and recognition\Data\Raster\CITY\img_test\iter_Ext4_4_2.txt"
    output_path = r'E:\Road extraction and recognition\Data\shapefile\roadnet\Corrected.shp'
    ShapeData = gpd.read_file(shape_path)#Read the ShapeFile
    CorrectShape(ShapeData,txt_path,50,output_path)
    ShapeData.to_file(output_path,driver='ESRI Shapefile',encoding='utf-8')


