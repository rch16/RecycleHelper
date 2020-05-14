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

extension CIImage {
  func toUIImage() -> UIImage? {
    let context: CIContext = CIContext.init(options: nil)

    if let cgImage: CGImage = context.createCGImage(self, from: self.extent) {
      return UIImage(cgImage: cgImage)
    } else {
      return nil
    }
  }
}

class VisionOCRViewController: OCRViewController {
    
    @IBOutlet weak var instructionsLabel: UILabel!
    // Views
    var itemViewOpen = false // info view about detected item
    private var detectionOverlay: CALayer! = nil // layer showing detection
    
    // OCR
    var requests = [VNRequest]()
    private var layers = [CALayer]()
    let scaleUp: CGFloat = 0.2
    
    // Vision
    private let visionQueue = DispatchQueue(label: K.visionQueueLabel)
    private var analysisRequests = [VNRequest]() // array of observations, each with a set of labels and bounding boxes
    private let sequenceRequestHandler = VNSequenceRequestHandler()
    private var currentlyAnalysedPixelBuffer: CVPixelBuffer? // buffer under analysis
    
    // Registration
    private let maximumHistoryLength = 15
    private var transpositionHistoryPoints: [CGPoint] = [ ]
    private var previousPixelBuffer: CVPixelBuffer?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            stopTextDetection()
            super.stopCaptureSession()
        }
    }

    //MARK: - AVCaptureSession Methods
    
    override func setupCaptureSession() {
        super.setupCaptureSession()
        
        // Adjust label appearance
        instructionsLabel.clipsToBounds = true
        instructionsLabel.layer.cornerRadius = 15
        
        // setup Vision parts
        setupLayers()
        //setupVision()
        
        // start the capture
        startCaptureSession()
        startTextDetection()
        
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
    
    //MARK: - Text Recognition
    
    func startTextDetection() {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textRequest.reportCharacterBoxes = true
        self.requests = [textRequest]
    }
    
    func stopTextDetection() {
        self.requests = []

    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no result")
            return
        }
        
            
        let result = observations.map({$0 as? VNTextObservation})
        //print(result)
        DispatchQueue.main.async() {
            self.removeBoxes()
            // Filter so that boxes only displayed if above 0.5 confidence
            //var images = [UIImage]()
            let results = result.filter({$0!.confidence > VNConfidence(K.boundingBoxConfidence)})
            
            self.layers = results.map({ result in // result has type VNTextObservation
                // Create a layer that will become the bounding box
                let layer = CALayer()
                self.previewView.layer.addSublayer(layer)
                layer.borderWidth = 2
                layer.borderColor = UIColor.red.cgColor
            
                // Obtain bounding box
                var box = result!.boundingBox
                
                // Transform bounding box
                let transform = CGAffineTransform(translationX: 0.5, y: 0.5)
                            .rotated(by: CGFloat.pi / 2)
                            .translatedBy(x: -0.5, y: -0.5)
                            .translatedBy(x: 1.0, y: 0)
                            .scaledBy(x: -1, y: 1)
                box = box.applying(transform)
                
                // Create rectangle to display bounding box
                let rect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: box)
                
                // Create a scaled up rectangle for cropping
                let biggerRect = rect.insetBy(dx: -rect.size.width * self.scaleUp, dy: -rect.size.height * self.scaleUp)
                
                layer.frame = rect
                
                return layer
            })
        }
    }

    
    // Remove all drawn boxes. Must be called on main queue.
    func removeBoxes() {
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll()
    }
    
    //MARK: - Vision Methods
    
//    func setupVision() -> NSError? {
//        let error: NSError! = nil
//
//        request.recognitionLevel = .fast // scanning a live feed
//
//        guard let modelURL = Bundle.main.url(forResource: "WasteClassifier", withExtension: "mlmodelc") else {
//            return NSError(domain: K.visionDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The model file cannot be found."])
//        }
//        guard let objectRecognition = createClassificationRequest(with: modelURL) else {
//            return NSError(domain: K.visionDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "The classification request failed."])
//        }
//
//        self.analysisRequests.append(objectRecognition)
//        return error
//    }
//
//    func createClassificationRequest(with modelURL: URL) -> VNCoreMLRequest? {
//        do {
//            let model = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
//            let classificationRequest = VNCoreMLRequest(model: model, completionHandler: {(request, error) in
//                if let results = request.results as? [VNClassificationObservation] {
//                    print("\(results.first!.identifier) : \(results.first!.confidence)")
//                    if results.first!.confidence > 0.98 { // choose result with confidence > 98%
//                        //self.showItemInfo(results.first!.identifier)
//                    }
//                }
//            })
//            return classificationRequest
//        } catch {
//            print("Model failed to load: \(error).")
//            return nil
//        }
//    }
    

    //MARK: - View Setup
    
    func setupLayers() {
        detectionOverlay = CALayer()
        detectionOverlay.bounds = self.view.bounds.insetBy(dx: 30, dy: 50)
        detectionOverlay.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        detectionOverlay.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.58, 0.83, 0.68, 0.5])
        detectionOverlay.borderWidth = 8
        detectionOverlay.cornerRadius = 20
        detectionOverlay.isHidden = true
        rootLayer.addSublayer(detectionOverlay)
    }
    
    private func showDetectionOverlay(_ visible: Bool) {
        DispatchQueue.main.async(execute: {
            // perform all the UI updates on the main queue
            self.detectionOverlay.isHidden = !visible // toggle
            if(visible == true){
                self.instructionsLabel.text = K.deviceStill
            }
            else{
                self.instructionsLabel.text = K.deviceMoving
                self.removeBoxes() // remove detection rectangles if device not still
            }
        })
    }
    
//    fileprivate func showItemInfo(_ identifier: String) {
//        // Perform all UI updates on the main queue.
//        DispatchQueue.main.async(execute: {
//            if self.itemViewOpen {
//                // nothing required if view already open - don't want to overwrite
//                return
//            }
//            // segue to item view
//            self.itemViewOpen = true
//            self.performSegue(withIdentifier: K.itemViewSegue, sender: identifier)
//        })
//    }
    
    @IBAction func unwindToScanning(unwindSegue: UIStoryboardSegue) {
        itemViewOpen = false
        self.resetTranspositionHistory() // reset scene stability
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let itemVC = segue.destination as? ItemViewController, segue.identifier == K.itemViewSegue {
//            if let itemID = sender as? String {
//                itemVC.itemID = itemID
//            }
//        }
//    }
    
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
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentlyAnalysedPixelBuffer!, orientation: .right)//, orientation: orientation)

        visionQueue.async { // resource heavy operation so perform in background
            do {
                
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentlyAnalysedPixelBuffer = nil }
                
                try requestHandler.perform(self.requests) // Detect text 
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
            
            // TODO: Text recognition
            // VNRecognizeTextRequest.recognitionLevel = VNRequestTextRecognitionLevel.fast // fast vs accurate -> fast suitable due to live capture
            // VNRecognizeTextRequest.recognitionLanguages = ["en_GB"]
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

