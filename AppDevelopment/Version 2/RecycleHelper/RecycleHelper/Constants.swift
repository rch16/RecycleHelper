//
//  Constants.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 05/01/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation

struct K {
    static let scanLabelSegue = "BeginScanSegue"
    static let cancelScanLabelSegue = "CancelScanSegue"
    static let itemViewSegue = "ShowItemSegue"
    static let videoDataOutput = "VideoDataOutput"
    static let visionDomain = "VisionViewController"
    static let deviceMoving = "Hold device still"
    static let deviceStill = "Looking for recycling label..."
    static let visionQueueLabel = "com.BeccaHallam.RecycleHelper.serialVisionQueue"
    static let boundingBoxConfidence = 0.75
    static let scaleUp = 0.2
    static let rotationAngle = 1.5708
}