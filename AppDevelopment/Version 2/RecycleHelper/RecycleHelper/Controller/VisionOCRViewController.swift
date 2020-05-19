//
//  VisionOCRViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 30/12/2019.
//  Copyright © 2019 Becca Hallam. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision
import Firebase
//import TesseractOCR
//import SwiftOCR

protocol OCRServiceDelegate: class {
  func ocrService(_ service: VisionOCRViewController, didDetect text: String)
}

class VisionOCRViewController: OCRViewController {
    
    // UI
    @IBOutlet weak var instructionsLabel: UILabel!
    var itemViewOpen = false // info view about detected item
    private var detectionRegion: CALayer! = nil // place label within this region
    
    // OCR
    private var requests = [VNRequest]()
    private var layers = [CALayer]()
    private var currentlyAnalysedImage: UIImage?
    private var images = [UIImage]()
    private let vision = Vision.vision()
    private var textRecognizer: VisionTextRecognizer!
    weak var delegate: OCRServiceDelegate?
//    private let tesseract = G8Tesseract(language: "eng")!
//    private let swiftOCRInstance = SwiftOCR()
//    init() {
//        tesseract.engineMode = .tesseractCubeCombined
//        tesseract.pageSegmentationMode = .singleBlock
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // Vision
    private let visionQueue = DispatchQueue(label: K.visionQueueLabel)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            removeBoxes()
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
                // Convert pixel buffer to image
                currentlyAnalysedImage = CIImage(cvPixelBuffer: currentlyAnalysedPixelBuffer!).toUIImage()
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
        let scanRect = CGRect(x: 0.16, y: 0.44, width: 0.68, height: 0.23)
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textRequest.reportCharacterBoxes = true
        textRequest.regionOfInterest = scanRect
        self.requests = [textRequest]
    }
    
    func stopTextDetection() {
        self.requests = []
        self.images = []
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no result")
            return
        }
        
            
        let result = observations.map({$0 as? VNTextObservation})
        DispatchQueue.main.async() {
            self.removeBoxes()
            if result != [] {
                // Filter so that boxes only displayed if above 0.5 confidence
                let results = result.filter({$0!.confidence > VNConfidence(K.boundingBoxConfidence)})

                self.layers = results.map({ result in // result has type VNTextObservation
                    // Create a layer that will become the bounding box
                    let layer = CALayer()
                    self.previewView.layer.addSublayer(layer)
                    layer.borderWidth = 2
                    layer.borderColor = UIColor.red.cgColor
                    
                    // Obtain bounding box
                    let boundingBox = result!.boundingBox

                    // Transform bounding box
                    let transform = CGAffineTransform(translationX: 0.5, y: 0.5)
                                .rotated(by: CGFloat.pi / 2)
                                .translatedBy(x: -0.5, y: -0.5)
                                .translatedBy(x: 1.0, y: 0)
                                .scaledBy(x: -1, y: 1)
                    let box = boundingBox.applying(transform)

                    // Create rectangle to display bounding box
                    let rect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: box)
                    
                    // Display rectangle on layer
                    layer.frame = rect

                    // Create a normalised rectangle according to differences in coordinate system - will be used for cropping
                    let normalisedRect = self.normalise(box: result!)

                    // Create a scaled up rectangle for cropping
                    //let biggerRect = rect.insetBy(dx: -rect.size.width * CGFloat(K.scaleUp), dy: -rect.size.height * CGFloat(K.scaleUp))

                    // Crop image to be used for OCR to improve accuracy
                    //if let croppedImage = self.crop(image: self.currentlyAnalysedImage!, rect: rect) {
                    if let croppedImage = self.cropImage(image: self.currentlyAnalysedImage!, normalisedRect: normalisedRect) {
                        //print(croppedImage)
                        self.images.append(croppedImage)
                    }
                
                    return layer
                })
            }
        }
    }

    func recognizeText(with image: UIImage) {
       let vision = Vision.vision()
       let textRecognizer = vision.onDeviceTextRecognizer()
       let visionImage = VisionImage(image: image)

       textRecognizer.process(visionImage) { result, error in
           if error != nil {
            print("MLKIT ERROR - \(String(describing: error))")
           } else {
            if let resultText = result?.text {
                let check = self.checkForRelevantLabel(text: resultText, categories: K.possibleCategories)
                if check != "not found" {
                    self.showItemInfo(check)
                }
            }
           }
        }
    }
    
    func checkForRelevantLabel(text: String, categories: [String]) -> String{
        for category in categories {
            if text.contains(category){
                return category
            }
        }
        return "not found"
    }

//    func handle(image: UIImage) {
//        handleWithTesseract(image: image)
//    }
//
//    private func handleWithTesseract(image: UIImage) {
//        //tesseract.image = image.g8_blackAndWhite()
//        tesseract.image = image
//        tesseract.recognize()
//        let text = tesseract.recognizedText!
//        print(text)
//        delegate?.ocrService(self, didDetect: text)
//    }
    

    //MARK: - User Interface
    
    // Remove all drawn boxes. Must be called on main queue.
    func removeBoxes() {
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll()
    }
    
    private func normalise(box: VNTextObservation) -> CGRect {
      return CGRect(
        x: box.boundingBox.origin.x,
        y: 1 - box.boundingBox.origin.y - box.boundingBox.height,
        width: box.boundingBox.size.width,
        height: box.boundingBox.size.height
      )
    }
    
    private func cropImage(image: UIImage, normalisedRect: CGRect) -> UIImage? {
      let x = normalisedRect.origin.x * image.size.width
      let y = normalisedRect.origin.y * image.size.height
      let width = normalisedRect.width * image.size.width
      let height = normalisedRect.height * image.size.height

      let rect = CGRect(x: x, y: y, width: width, height: height).scaleUp(scaleUp: 0.1)

      guard let cropped = image.cgImage?.cropping(to: rect) else {
        return nil
      }

      let croppedImage = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
      return croppedImage
    }
    
    
    func setupLayers() {
        detectionRegion = CALayer()
        detectionRegion.bounds = self.view.bounds.insetBy(dx: 50, dy: 300)
        detectionRegion.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        detectionRegion.borderColor = .init(genericGrayGamma2_2Gray: 0.5, alpha: 1)
        detectionRegion.borderWidth = 8
        detectionRegion.cornerRadius = 20
        rootLayer.addSublayer(detectionRegion)
    }
    
    private func showDetectionOverlay(_ visible: Bool) {
        DispatchQueue.main.async(execute: {
            // perform all the UI updates on the main queue
            //self.detectionOverlay.isHidden = !visible // toggle
            if(visible == true){
                self.instructionsLabel.text = K.deviceStill
                self.instructionsLabel.backgroundColor = UIColor(red: 0.58, green: 0.83, blue: 0.68, alpha: 0.5)
                self.detectionRegion.borderColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.58, 0.83, 0.68, 0.5])
            }
            else{
                self.instructionsLabel.text = K.deviceMoving
                self.instructionsLabel.backgroundColor = UIColor(cgColor: .init(genericGrayGamma2_2Gray: 0.5, alpha: 0.5))
                self.detectionRegion.borderColor = .init(genericGrayGamma2_2Gray: 0.5, alpha: 0.5)
                self.removeBoxes() // remove detection rectangles if device not still
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
    
    // MARK: - Region of Interest
 



    
    //MARK: - Image Analysis
    
    private func analyseCurrentImage() {
        
        // computer vision task is not rotation-agnostic
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentlyAnalysedPixelBuffer!, orientation: .up)

        visionQueue.async { // resource heavy operation so perform in background
            do {
                
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentlyAnalysedPixelBuffer = nil }
                
                if self.requests != [] {

                    try requestHandler.perform(self.requests) // Detect text
                    
                    guard let biggestImage = self.images.sorted(by: {
                        $0.size.width > $1.size.width && $0.size.height > $1.size.height
                    }).first else {
                      return
                    }
                    self.recognizeText(with: biggestImage)
                }
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
            
            
            
            //self.handle(image: biggestImage) // TesseractOCR
//            self.swiftOCRInstance.recognize(biggestImage) { recognizedString in // SwiftOCR
//                DispatchQueue.main.async {
//                    print(recognizedString)
//                }
//            }
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

