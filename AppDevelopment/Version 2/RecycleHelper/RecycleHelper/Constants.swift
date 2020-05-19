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
    // Text Recognition
    static let boundingBoxConfidence = 0.75
    static let scaleUp = 0.2
    static let rotationAngle = 1.5708
    // Item Search
    static let cellIdentifier = "ItemTableViewCell"
    static let searchData = "SearchItemsList"
    static let itemInfoCellIdentifier = "ItemInfoTableViewCell"
    // Item View
    static let possibleCategories = ["card","Card","CARD","cardboard","Cardboard","CARDBOARD","paper","Paper","PAPER","metal","Metal","METAL","aluminium","Aluminium","ALUMINIUM","can","Can","CAN","foil","Foil","FOIL","plastic","Plastic","PLASTIC","glass","Glass","GLASS"]
    static let infoCellIdentifier = "InfoTableViewCell"
}
