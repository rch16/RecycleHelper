//
//  VisionViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 01/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreML
import Vision

class VisionViewController: ViewController {

    // Attach UI
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var scanBtn: UIButton!
    @IBAction func scanWasPressed(_ sender: UIButton) {
    }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Rounded corners
        self.instructionsLabel.clipsToBounds = true
        self.instructionsLabel.layer.cornerRadius = 15
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            super.stopCaptureSession()
            // stop detection too
        }
    }

    //MARK: - AVCaptureSession Methods
    
    override func setupCaptureSession() {
        super.setupCaptureSession()
        
        // setup Vision parts
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
            toggleView(true)
            if currentlyAnalysedPixelBuffer == nil {
                // if a pixel buffer not currently being analysed -> retain current image buffer for processing
                currentlyAnalysedPixelBuffer = pixelBuffer
                // analyse image
                analyseCurrentImage()
            }
        } else {
            // hide overlay as object not being detected due to lack of stability
            toggleView(false)
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
    
    
    private func toggleView(_ visible: Bool) {
        DispatchQueue.main.async(execute: {
            // perform all the UI updates on the main queue
            if(visible == true){
                // Enable camera button
                self.scanBtn.isEnabled = true
                // Hide instructions
                self.instructionsLabel.isHidden = true
            }
            else{
                // Disable camera button
                self.scanBtn.isEnabled = false
                // Show instructions
                self.instructionsLabel.isHidden = false
            }
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
        super.stopCaptureSession()
        if let itemVC = segue.destination as? ObjectViewController, segue.identifier == K.itemViewSegue {
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
        //let orientation = deviceOrientation()

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentlyAnalysedPixelBuffer!, orientation: .up)
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
    
    // MARK: - Wind Down

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
