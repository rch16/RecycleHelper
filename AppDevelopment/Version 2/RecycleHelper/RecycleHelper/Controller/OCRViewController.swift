//
//  OCRViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 12/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class OCRViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    override func viewDidLoad() {
           super.viewDidLoad()
           setupCaptureSession()
       }

       var bufferSize: CGSize = .zero
       var rootLayer: CALayer! = nil
       
       // Attach UI
       @IBOutlet weak private var previewView: UIView!
       
       // Configure the camera
       private let session = AVCaptureSession()

       private var previewLayer: AVCaptureVideoPreviewLayer! = nil
       private let videoDataOutput = AVCaptureVideoDataOutput()
       
       private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
          
       func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {}
       
       // MARK: setupCaptureSession
       func setupCaptureSession(){
           
           var deviceInput: AVCaptureDeviceInput!
           
           // Select a video device
           let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
           do {
               // Assign input
               deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
           } catch {
               print("Could not find a video input: \(error)")
               return
           }
           
           session.beginConfiguration()
           session.sessionPreset = .vga640x480
           
           // Add video input
           guard session.canAddInput(deviceInput) else {
               print("Could not add video input to the session")
               session.commitConfiguration()
               return
           }
           
           session.addInput(deviceInput)
           
           // Add video output
           if session.canAddOutput(videoDataOutput) {
               session.addOutput(videoDataOutput)
               // Add a video data output
               videoDataOutput.alwaysDiscardsLateVideoFrames = true
               videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
               videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
           } else {
               print("Could not add video data output to the session")
               session.commitConfiguration()
               return
           }
           
           let captureConnection = videoDataOutput.connection(with: .video)
           
           // Always process the frames
           captureConnection?.isEnabled = true
           do {
               // Prevent more than one request at a time
               try  videoDevice!.lockForConfiguration()
               let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
               bufferSize.width = CGFloat(dimensions.width)
               bufferSize.height = CGFloat(dimensions.height)
               videoDevice!.unlockForConfiguration()
           } catch {
               print(error)
           }
           session.commitConfiguration()
           previewLayer = AVCaptureVideoPreviewLayer(session: session)
           previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
           rootLayer = previewView.layer
           previewLayer.frame = rootLayer.bounds
           rootLayer.addSublayer(previewLayer)
       }
       
       // MARK: startCaptureSession
       func startCaptureSession() {
           session.startRunning()
       }
       
       // MARK: stop Capture Session
       // Clean up capture setup
       func teardownCaptureSession() {
           previewLayer.removeFromSuperlayer()
           previewLayer = nil
       }
       
       func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
           // print("frame dropped")
       }
       
       public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
           let curDeviceOrientation = UIDevice.current.orientation
           let exifOrientation: CGImagePropertyOrientation
           
           switch curDeviceOrientation {
           case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
               exifOrientation = .left
           case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
               exifOrientation = .upMirrored
           case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
               exifOrientation = .down
           case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
               exifOrientation = .up
           default:
               exifOrientation = .up
           }
           return exifOrientation
       }
}
