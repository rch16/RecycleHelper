//
//  VisionViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 30/12/2019.
//  Copyright © 2019 Becca Hallam. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class VisionObjectRecognitionViewController: OCRViewController {
    
    // Views
    var itemViewOpen = false // info view about detected item
    private var detectionOverlay: CALayer! = nil // layer showing detection
    
    // Vision
    private let visionQueue = DispatchQueue(label: "com.BeccaHallam.RecycleHelper.serialVisionQueue")
    private var analysisRequests = [VNRequest]() // array of observations, each with a set of labels and bounding boxes
    private let sequenceRequestHandler = VNSequenceRequestHandler()
    private var currentlyAnalysedPixelBuffer: CVPixelBuffer? // buffer under analysis
    
    // Registration
    private let maximumHistoryLength = 15
    private var transpositionHistoryPoints: [CGPoint] = [ ]
    private var previousPixelBuffer: CVPixelBuffer?
    

    //MARK: - AVCaptureSession Methods
    
    override func setupCaptureSession() {
        super.setupCaptureSession()
        
        // setup Vision parts
        setupLayers()
        setupVision()
        
        // start the capture
        startCaptureSession()
        
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard previousPixelBuffer != nil else {
            previousPixelBuffer = pixelBuffer
            self.resetTranspositionHistory()
            return
        }
        
        if itemViewOpen {
            // another object had previously been detected and information being shown - don't show a new one
            return
        }
        
        let registrationRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: pixelBuffer)
        do {
            try sequenceRequestHandler.perform([ registrationRequest ], on: previousPixelBuffer!)
        } catch let error as NSError {
            print("Failed to process request: \(error.localizedDescription).")
            return
        }
        
        // update pixel buffer
        previousPixelBuffer = pixelBuffer
        
        // send a registration request to check if scene stability has been achieved
        if let results = registrationRequest.results {
            if let alignmentObservation = results.first as? VNImageTranslationAlignmentObservation {
                let alignmentTransform = alignmentObservation.alignmentTransform
                self.recordTransposition(CGPoint(x: alignmentTransform.tx, y: alignmentTransform.ty))
            }
        }
        if self.sceneStabilityAchieved() {
            // show overlay where object has been detected
            showDetectionOverlay(true)
            if currentlyAnalysedPixelBuffer == nil {
                // if a pixel buffer not currently being analysed -> retain current image buffer for processing
                currentlyAnalysedPixelBuffer = pixelBuffer
                // analyse image
                analyseCurrentImage()
            }
        } else {
            // hide overlay as object not being detected due to lack of stability
            showDetectionOverlay(false)
        }
    }
    
    //MARK: - Vision Methods
    
    func setupVision() -> NSError? {
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "WasteClassifier", withExtension: "mlmodelc") else {
            return NSError(domain: K.visionDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The model file cannot be found."])
        }
        guard let objectRecognition = createClassificationRequest(with: modelURL) else {
            return NSError(domain: K.visionDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The classification request failed."])
        }
        self.analysisRequests.append(objectRecognition)
        return error
    }
    
    func createClassificationRequest(with modelURL: URL) -> VNCoreMLRequest? {
        do {
            let model = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let classificationRequest = VNCoreMLRequest(model: model, completionHandler: {(request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    print("\(results.first!.identifier) : \(results.first!.confidence)")
                    if results.first!.confidence > 0.98 { // choose result with confidence > 98%
                        self.showItemInfo(results.first!.identifier)
                    }
                }
            })
            return classificationRequest
        } catch {
            print("Model failed to load: \(error).")
            return nil
        }
    }
    

    //MARK: - View Setup
    
    func setupLayers() {
        detectionOverlay = CALayer()
        detectionOverlay.bounds = self.view.bounds.insetBy(dx: 20, dy: 20)
        detectionOverlay.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        detectionOverlay.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.7])
        detectionOverlay.borderWidth = 8
        detectionOverlay.cornerRadius = 20
        detectionOverlay.isHidden = true
        rootLayer.addSublayer(detectionOverlay)
    }
    
    private func showDetectionOverlay(_ visible: Bool) {
        DispatchQueue.main.async(execute: {
            // perform all the UI updates on the main queue
            self.detectionOverlay.isHidden = !visible // toggle
        })
    }
    
    fileprivate func showItemInfo(_ identifier: String) {
        // Perform all UI updates on the main queue.
        DispatchQueue.main.async(execute: {
            if self.itemViewOpen {
                // nothing required if view already open - don't want to overwrite
                return
            }
            // segue to item view
            self.itemViewOpen = true
            self.performSegue(withIdentifier: K.itemViewSegue, sender: identifier)
        })
    }
    
    @IBAction func unwindToScanning(unwindSegue: UIStoryboardSegue) {
        itemViewOpen = false
        self.resetTranspositionHistory() // reset scene stability
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let itemVC = segue.destination as? ItemViewController, segue.identifier == K.itemViewSegue {
            if let itemID = sender as? String {
                itemVC.itemID = itemID
            }
        }
    }
    
    //MARK: - Check Scene Stability via Registration
    
    fileprivate func sceneStabilityAchieved() -> Bool {
        // Determine if we have enough evidence of stability.
        if transpositionHistoryPoints.count == maximumHistoryLength {
            // Calculate the moving average.
            var movingAverage: CGPoint = CGPoint.zero
            for currentPoint in transpositionHistoryPoints {
                movingAverage.x += currentPoint.x
                movingAverage.y += currentPoint.y
            }
            let distance = abs(movingAverage.x) + abs(movingAverage.y)
            if distance < 20 {
                // manhattan distance < 20, conclude that device is being held still as if to scan an item
                return true
            }
        }
        return false
    }
    
    //MARK: - Image Analysis
    
    private func analyseCurrentImage() {
        // computer vision task is not rotation-agnostic
        // check device orientation
        let orientation = deviceOrientation()
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentlyAnalysedPixelBuffer!, orientation: orientation)
        visionQueue.async { // resource heavy operation so perform in background
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentlyAnalysedPixelBuffer = nil }
                try requestHandler.perform(self.analysisRequests)
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
    
    fileprivate func resetTranspositionHistory() {
        transpositionHistoryPoints.removeAll()
    }
    
    fileprivate func recordTransposition(_ point: CGPoint) {
        transpositionHistoryPoints.append(point)
        
        if transpositionHistoryPoints.count > maximumHistoryLength {
            transpositionHistoryPoints.removeFirst()
        }
    }

}
