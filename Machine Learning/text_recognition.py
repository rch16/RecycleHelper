import cv2
import pytesserac
from PIL import Image

def singleImageText(path):
    img = cv2.imread(path)
    text = pytesseract.image_to_string(img)
    print(text)

def multipleImageText(path, matches):
    count = 0
    # iterate through images
    for i in range(1,63):
        s = path + str(i) + ".jpg"
        img = cv2.imread(s)
        text = pytesseract.image_to_string(img)
        print(i, " : ", text)
        if any(word in text for word in matches):
            count += 1
    # calculate accuracy
    accuracy = (count/63)*100
    print(accuracy,"%")

def pytesseractMethod():

    # - - - - - - - - - - text from one image - - - - - - - - - - 
    image_path = "Datasets/label_dataset/cardboard/0.jpg"
    singleImageText(image_path)

    # - - - - - - - - - text from folder of images - - - - - - - - -
    matches = ["cardboard", "CARDBOARD", "card", "CARDBOARD" "paper", "PAPER"]
    folder = "Datasets/label_dataset/cardboard/"
    multipleImageText(folder, matches)



