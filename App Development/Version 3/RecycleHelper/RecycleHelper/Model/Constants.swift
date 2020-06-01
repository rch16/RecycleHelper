//
//  Constants.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 05/01/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation

struct K {
    // Segues
    static let scanLabelSegue = "BeginScanSegue"
    static let cancelScanLabelSegue = "CancelScanSegue"
    static let unwindLabelScanSegue = "BackToHome"
    static let itemViewSegue = "ShowItemSegue"
    static let objectDetectSegue = "BeginDetectionSegue"
    static let searchItemViewSegue = "ShowItemAfterSearchSegue"
    
    // Object Detection
    static let videoDataOutput = "VideoDataOutput"
    static let visionDomain = "VisionViewController"
    static let visionQueueLabel = "com.BeccaHallam.RecycleHelper.serialVisionQueue"
    
    // Registration
    static let deviceMoving = "Hold device still"
    static let deviceStill = "Looking for recycling label..."
    static let deviceStillObject = "Looking for object..."
    

    // Item Search
    static let cellIdentifier = "ItemTableViewCell"
    static let searchData = "SearchItemsList"
    static let itemInfoCellIdentifier = "InfoTableViewCell"
    
    // Locations
    static let delta = 0.02
    
    // Item View
    static let possibleCategories = ["Card","Paper","Box","Carton","Bag","Sleeve","Tray","Film","Lid","Pot","Metal","Aluminium","Can","Foil","Glass","Plastic"]
    //static let infoCellIdentifier = "InfoTableViewCell"
}
