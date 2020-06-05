//
//  Constants.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 05/01/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation

struct K {
    // Colour Theme
    static let firstColour = "EFFCEF"
    static let secondColour = "CCEDD2"
    static let thirdColour = "94D3AC"
    static let fourthColour = "655C56"
    
    // Segues
    static let scanLabelSegue = "BeginScanSegue"
    static let cancelScanLabelSegue = "CancelScanSegue"
    static let unwindLabelScanSegue = "BackToHome"
    static let itemViewSegue = "ShowItemSegue"
    static let objectDetectSegue = "BeginDetectionSegue"
    static let searchItemViewSegue = "ShowItemAfterSearchSegue"
    static let locationInfoSegue = "ShowLocationInfoSegue"
    static let symbolInfoSegue = "ShowSymbolInfoSegue"
    static let editCollectionSegue = "EditCollectionSegue"
    static let addCollectionSegue = "AddCollectionSegue"
    
    // Home View
    static let collectionCellIdentifier = "CollectionTableViewCell"
    static let eventCellIdentifier = "EventCell"
    static let datePickerCellIdentifier = "DatePickerCell"
    static let titleCellIdentifier = "TitleCell"
    static let binCollections = "BinCollections"
    static let repeatsCellIdentifier = "SetsRepeatCell"
    
    // Object Detection
    static let videoDataOutput = "VideoDataOutput"
    static let visionDomain = "VisionViewController"
    static let visionQueueLabel = "com.BeccaHallam.RecycleHelper.serialVisionQueue"
    
    // Registration
    static let deviceMoving = "Hold device still"
    static let deviceStill = "Looking for recycling label..."
    static let deviceStillObject = "Looking for object..."
    
    // Recycling Symbols
    static let symbolData = "RecyclingSymbols"
    static let symbolCellIdentifier = "SymbolTableViewCell"
    static let cellSpacingHeight = 15
    
    // Item Search
    static let cellIdentifier = "ItemTableViewCell"
    static let searchData = "SearchItemsList"
    static let itemInfoCellIdentifier = "InfoTableViewCell"
    static let saveItemKey = "SearchFavourites"
    static let showFavourites = "ShowFavourites"
    
    // Locations
    static let delta = 0.03
    static let searchQuery = "Household Waste Recycling Centres"
    
    // Item View
    static let possibleCategories = ["Card","Paper","Box","Carton","Bag","Sleeve","Tray","Film","Lid","Pot","Metal","Aluminium","Can","Foil","Glass","Plastic"]
    //static let infoCellIdentifier = "InfoTableViewCell"
}
