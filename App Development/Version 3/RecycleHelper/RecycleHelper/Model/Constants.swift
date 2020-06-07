//
//  Constants.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 05/01/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation

struct K {
    // Initial launch
    static let launchedBefore = "LaunchedBefore"
    
    // Colour Theme
    static let firstColour = "EFFCEF"
    static let secondColour = "CCEDD2"
    static let thirdColour = "94D3AC"
    static let fourthColour = "655C56"
    
    // Segues
    static let itemViewSegue = "ShowItemSegue"
    static let objectDetectSegue = "BeginDetectionSegue"
    static let searchItemViewSegue = "ShowItemAfterSearchSegue"
    static let locationInfoSegue = "ShowLocationInfoSegue"
    static let symbolInfoSegue = "ShowSymbolInfoSegue"
    static let editCollectionSegue = "EditCollectionSegue"
    static let addCollectionSegue = "AddCollectionSegue"
    static let selectWeekdaySegue = "SelectWeekdaySegue"
    static let addDaySegue = "AddDaySegue"
    static let cancelAddDaySegue = "CancelAddDaySegue"
    static let showOnboardingSegue = "ShowOnboarding"
    
    // Home View
    static let hasPersonalised = "HasPersonalised"
    static let personalisation = "Personalisation"
    static let collectionCellIdentifier = "CollectionTableViewCell"
    static let eventCellIdentifier = "EventCell"
    static let datePickerCellIdentifier = "DatePickerCell"
    static let titleCellIdentifier = "TitleCell"
    static let settingsCellIdentifier = "SettingsCell"
    static let binCollections = "BinCollections"
    static let repeatsCellIdentifier = "SetsRepeatCell"
    static let weekdayCellIdentifier = "WeekdayCell"
    static let buttonCellIdentifier = "ButtonCell"
    static let aboutCellIdentifier = "TableCell"
    static let onboardingBtnTitle = "Show onboarding"
    static let clearCollectionsBtnTitle = "Clear bin collections"
    static let clearFavouritesBtnTitle = "Clear search favourites"
    static let weekdaysFromDateComponent = ["",
                                            "Sunday",
                                            "Monday",
                                            "Tuesday",
                                            "Wednesday",
                                            "Thursday",
                                            "Friday",
                                            "Saturday"]
    static let weekdayValues = [2,3,4,5,6,7,1]
    static let weekdayStrings = ["Monday",
                                 "Tuesday",
                                 "Wednesday",
                                 "Thursday",
                                 "Friday",
                                 "Saturday",
                                 "Sunday"]
    
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
    static let infoCellIdentifier = "InfoTableViewCell"
}
