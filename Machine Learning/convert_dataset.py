import os, os.path
import csv
import time
import pandas as pd 
import numpy as np
from PIL import Image

DIRECTORY = 'Datasets/label_dataset/all'
FORMAT = '.jpg'

def make_labels_csv():
    # get list of files
    files = [f for f in os.listdir(DIRECTORY)]
    # possible categories
    categories = ['cardboard','glass','metal','plastic']
    # create csv of class labels
    for f in files:
        for i in range(0,len(categories)):
            if categories[i] in f:
                category = np.array(i).flatten()
                with open("label_dataset_l.csv",'a') as csv_file:
                    writer = csv.writer(csv_file)
                    writer.writerow(category)

def make_data_csv():
    # get list of files
    files = [f for f in os.listdir(DIRECTORY)]
    # extract and add to csv
    for f in files:
        if (f != '.DS_Store'):
            s = '/Users/beccahallam/Documents/GitHub/FYP/Machine Learning/Datasets/label_dataset/all/' + f
            img = Image.open(s)
            w,h = img.size
            form = img.format
            mode = img.mode
            img_grey = img.convert('L')
            val = np.asarray(img_grey.getdata(), dtype=np.int).reshape((img_grey.size[1], img_grey.size[0]))
            val = val.flatten()
            with open("label_dataset.csv",'a') as csv_file:
                writer = csv.writer(csv_file)
                writer.writerow(val)
    
make_data_csv()
make_labels_csv()
