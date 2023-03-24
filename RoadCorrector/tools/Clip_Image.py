from PIL import Image
import os
import argparse
import math
from tqdm import tqdm

clip_height = 640
clip_width = 640
source_img_path = r"E:\Road extraction and recognition\Data\Raster\CITY\Paris"
save_img_path = r"E:\Road extraction and recognition\Data\Raster\CITY\Paris"


dataname = os.listdir(source_img_path)

if os.path.exists(save_img_path) == False:os.mkdir(save_img_path)

fp = open(save_img_path + "\\metedata.txt" , "w")

for data in tqdm(dataname):
    if os.path.isdir(source_img_path + "\\" + data):
        continue

    path = source_img_path + "\\" + data

    if path[-4:] in [".tif",".png",".jpg",".bmp"]:
        img = Image.open(path)
    else :
        print("CANNOT OPEN %s!!"%data)
        continue
    
    counter = 1
    h = 0
    w = 0
    W,H = img.size
    col = 0
    row = 0
    if os.path.exists(save_img_path + "\\" + data.split(".")[0]) == False:
        os.mkdir(save_img_path + "\\" + data.split(".")[0])
    save_each_img_path = save_img_path + "\\" + data.split(".")[0]

    for i in range(H):
        if h + clip_height > H: break
        if w + clip_width < W:
            cropped = img.crop((w,h,w + clip_width,h + clip_height))
            save_path = save_each_img_path + "\\" +  str(counter) +".jpg" 
            cropped.save(save_path) 
            w = w + clip_width
            counter = counter + 1
        else:
            cropped = img.crop((w,h,W,h + clip_height))
            save_path = save_each_img_path + "\\" +  str(counter) +".jpg" 
            cropped.save(save_path) 
            w = 0
            h = h + clip_height
            counter = counter + 1

    w = 0
    for i in range(W):
        if h + clip_height > H + clip_height: break
        if w + clip_width < W:
            cropped = img.crop((w,h,w + clip_width,H))
            save_path = save_each_img_path + "\\" +  str(counter) +".jpg" 
            cropped.save(save_path) 
            w = w + clip_width
            counter = counter + 1
        else:
            cropped = img.crop((w,h,W,H))
            save_path = save_each_img_path + "\\" +  str(counter) +".jpg" 
            cropped.save(save_path) 
            w = 0
            h = h + clip_height
            counter = counter + 1

    fp.write(data + " " + str(W) + " " + str(H) + " " + str(math.ceil(H / clip_height)) + " " + str(math.ceil(W / clip_width)) + "\n")

fp.close()