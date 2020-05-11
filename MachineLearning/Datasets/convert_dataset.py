import os, os.path
import csv
import time
import pandas as pd 
import numpy as np
from PIL import Image

DIRECTORY = 'label_dataset/all'
DIRECTORY2 = 'MachineLearning/Datasets/letter_dataset'

def make_labels_csv_from_folder():
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

def make_labels_csv_from_dir(dir,format):
    # get list of files
    fileList = []
    for root, dirs, files in os.walk(dir, topdown=False):
        for name in files:
            if name.endswith(format):
                fullName = os.path.join(root, name)
                fileList.append(fullName)
    # extract numbers from each file name
    for f in fileList:
        substring = int(f[56:59])
        category = np.array(substring - 11).flatten()
        with open("letter_dataset_l.csv",'a') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow(category)

def make_data_csv_from_folder(dir):
    # get list of files
    files = [f for f in os.listdir(dir)]
    # extract and add to csv
    for f in files:
        if (f != '.DS_Store'):
            s = dir + '/' + f
            img = Image.open(s)
            w,h = img.size
            form = img.format
            mode = img.mode
            img_grey = img.convert('L')
            val = np.asarray(img_grey.getdata(), dtype=np.int).reshape((img_grey.size[1], img_grey.size[0]))
            val = val.flatten()
            with open("label_datset.csv",'a') as csv_file:
                writer = csv.writer(csv_file)
                writer.writerow(val)
    
def make_data_csv_from_dir(dir,format):
    # get list of files
    fileList = []
    for root, dirs, files in os.walk(dir, topdown=False):
        for name in files:
            if name.endswith(format):
                fullName = os.path.join(root, name)
                fileList.append(fullName)
    # extract and add to csv
    for f in fileList:
        if (f != '.DS_Store'):
            img = Image.open(f)
            img_grey = img.convert('L')
            val = np.asarray(img_grey.getdata(), dtype=np.int).reshape((img_grey.size[1], img_grey.size[0]))
            val = val.flatten()
            with open("letter_dataset.csv",'a') as csv_file:
                writer = csv.writer(csv_file)
                writer.writerow(val)

def find_longest_row():
    # get list of files
    files = [f for f in os.listdir(DIRECTORY)]
    lengths = []
    print(files)
    # extract and add to csv
    for f in files:
        if (f != '.DS_Store'):
            s = 'label_dataset/all/' + f
            img = Image.open(s)
            w,h = img.size
            form = img.format
            mode = img.mode
            img_grey = img.convert('L')
            val = np.asarray(img_grey.getdata(), dtype=np.int).reshape((img_grey.size[1], img_grey.size[0]))
            val = val.flatten()
            l = len(val)
            lengths.append(l)
    print(max(lengths))
    # find unique elements
    unique_lengths = []
    for l in lengths:
        if l not in unique_lengths:
            unique_lengths.append(l)
    #print(unique_lengths)
    print(min(lengths))

# make_data_csv_from_folder(DIRECTORY,"label_dataset.csv")
# make_data_csv_from_dir(DIRECTORY2,'.png')
# make_labels_csv_from_folder()
make_labels_csv_from_dir(DIRECTORY2,'.png')
# find_longest_row()
