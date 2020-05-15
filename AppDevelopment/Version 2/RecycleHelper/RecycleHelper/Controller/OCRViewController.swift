//
//  OCRViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 12/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//
//  See License.txt for information about license for sample code
//

import UIKit
import AVFoundation
import Vision
import CoreML


class OCRViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // initialisation of capture session
    private let session = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: K.videoDataOutput, qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    // initialise preview layers
    var rootLayer: CALayer! = nil
    var previewLayer: AVCaptureVideoPreviewLayer! = nil

    // connection to storyboard
    @IBOutlet weak var previewView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession() // capture session setup
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            stopCaptureSession()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // dispose of any resources that can be recreated.
    }

    //MARK: - AVCaptureSession Methods

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }

    func setupCaptureSession() {
        
        var deviceInput: AVCaptureDeviceInput! // input device of type AVCaptureDeviceInput
        
        // Set device and session resolution
        // !! set the camera resolution to the nearest resolution that is greater than or equal to the resolution of images used in the model
        
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first // if a discovery session can be created
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!) // assign the video device
        } catch {
            print("Unable to access rear camera: \(error)")
            return
        }
        
        // ---------- Session configuration ----------
        session.beginConfiguration() // start to configure the session
        session.sessionPreset = .vga640x480 // Model image size is smaller
        
        // ---------- Add a video input ----------
        if session.canAddInput(deviceInput){
            // can add input
            session.addInput(deviceInput)
        } else {
            // can't add input
            print("Could not add input video device to the session")
            session.commitConfiguration()
            return
        }
        
        
        // ---------- Add a video output ----------
        if session.canAddOutput(videoDataOutput) {
            // can add output
            session.addOutput(videoDataOutput)
            // set properties
            videoDataOutput.alwaysDiscardsLateVideoFrames = true // so as not to block processing
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)] // two 8 bit components: 1st byte -> luna, 2nd -> chroma
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue) // processing to be done in background
        } else {
            // can't add output
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true // always process the frames
        captureConnection?.videoOrientation = .portrait
        
        session.commitConfiguration() // commit session configuration
        
        // ---------- Preview frames ----------
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.insertSublayer(previewLayer, at: 0)

    }

    func startCaptureSession() {
        session.startRunning()
    }

    func stopCaptureSession() {
        //previewLayer.removeFromSuperLayer()
        previewLayer = nil
    }

    //MARK: - Device Orientation

    public func deviceOrientation() -> CGImagePropertyOrientation {
        let currentOrientation = UIDevice.current.orientation
        let orientation: CGImagePropertyOrientation

        switch currentOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            orientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            orientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            orientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            orientation = .up
        default:
            orientation = .up
        }
        
        return orientation
    }
}




