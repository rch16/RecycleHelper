# RecycleHelper
## A persuasive smartphone app for improving recycling performance

This repo documents the design and development of RecycleHelper, and contains the source code of the three versions developed, as well as testing results and machine learning experimentation.

# Contents

* [About RecycleHelper](#about-recyclehelper)
* [Technologies Used](#technologies-used)
* [Access the current app version](#access-the-current-app-version)
* [Contribute to further development](#contribute-to-further-development)
* [Repository Structure](#repository-structure)
* [Credits](#credits)

## About RecycleHelper

RecycleHelper is an iOS application designed to improve recycling performance of consumers in the UK. It provides location-specific recycling information that is accessible via a search feature, or by a machine learning scan feature that predicts the material of the object presented to it. The app can also be used to track and provide reminders of upcoming household waste collections, as well as find the nearest Recycling Centre, Supermarket or Charity Shop, for items that can be recycled but aren't accepted in a kerbside collection. To help improve consumers' motivation to recycle, persuasive techniques are employed to improve the user experience and make users feel more positive about recycling. Some examples of techniques include the Mere-Exposure Effect, used in the UI design, as well as social motivation through a recycling tracking feature.

![alt text](https://github.com/rch16/FYP/blob/master/App%20Development/Version%203/App%20Screenshots/Onboarding.png)

The app provides resources to allow users find out how to recycle 100+ items, and currently provides specific information for the following locations:

**England**
* London Boroughs of Barnet, Ealing, Kensington and Chelsea, Newham and Westminster
* St Albans and Rickmansworth, Hertfordshire
* Leeds
* Manchester

**Wales**
* Cardiff
* Penarth

**Ireland**
* Dublin

And generic information for the rest of the UK. Persuasive techniques are employed to help motivate users to improve their recycling behaviour - for more information, please see the Final Report.


![alt text](https://github.com/rch16/FYP/blob/master/App%20Development/Version%203/App%20Screenshots/Homescreen.png)
![alt text](https://github.com/rch16/FYP/blob/master/App%20Development/Version%203/App%20Screenshots/Search.png)
![alt text](https://github.com/rch16/FYP/blob/master/App%20Development/Version%203/App%20Screenshots/Scan.png)
![alt text](https://github.com/rch16/FYP/blob/master/App%20Development/Version%203/App%20Screenshots/Symbols.png)
![alt text](https://github.com/rch16/FYP/blob/master/App%20Development/Version%203/App%20Screenshots/Locate.png)

## Technologies Used

RecycleHelper was built in [XCode 11.5](https://apps.apple.com/gb/app/xcode/id497799835?mt=12), using:
* [Swift 5](https://swift.org/blog/swift-5-released/)
* [Python 3.8.0](https://www.python.org/downloads/release/python-380/)

## Access the Current App Version

RecycleHelper is not yet available on the App Store as it is still in the Beta Testing stage. Therefore current version of RecycleHelper, V3.0 build 7, can be accessed by [downloading TestFlight](https://apps.apple.com/gb/app/testflight/id899247664) on your iOS device and then following [this link](https://testflight.apple.com/join/YrAypbv3) to join the testing program. Any Beta Feedback, such as crash reports or bugs found, would be greatly appreciated.

## Contribute to Further Development

RecycleHelper can be 

## Repository Structure

* [App Development](https://github.com/rch16/RecycleHelper/tree/master/App%20Development): RecycleHelper project, containing entire code for app versions 1, 2 and 3
    * [Version 1](https://github.com/rch16/RecycleHelper/tree/master/App%20Development/Version%201)
    * [Version 2](https://github.com/rch16/RecycleHelper/tree/master/App%20Development/Version%202)
    * [Version 3](https://github.com/rch16/RecycleHelper/tree/master/App%20Development/Version%203)
* [Machine Learning](https://github.com/rch16/RecycleHelper/tree/master/Machine%20Learning): Source code for current and previous machine learning models, as well as experimentation results
    * [Experimentation](https://github.com/rch16/RecycleHelper/tree/master/Machine%20Learning/Experimentation)
    * [Initial Model](https://github.com/rch16/RecycleHelper/tree/master/Machine%20Learning/Initial%20Model)
    * [Optimised Model](https://github.com/rch16/RecycleHelper/tree/master/Machine%20Learning/Optimised%20Model)
* [Testing](https://github.com/rch16/RecycleHelper/tree/master/Testing): Results and resources for the rounds of testing completed after development of each app version 
    * [Performance and Stability](https://github.com/rch16/RecycleHelper/tree/master/Testing/Performance%20and%20Stability)
    * [Usability](https://github.com/rch16/RecycleHelper/tree/master/Testing/Usability)

## Credits

**Author**: Rebecca Hallam

**CID**: 01190898

**Email**: rch16@ic.ac.uk

RecycleHelper was created under the supervision of Dr. Thomas J. W. Clarke, submitted in partial fulfillment for an MEng degree in Electrical & Electronic Engineering from Imperial College, London
