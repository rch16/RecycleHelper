//
//  ViewController.swift
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


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // initialisation of capture session
    private var setupResult: SessionSetupResult = .success
    private let session = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: K.videoDataOutput, qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    // initialise preview layers
    var rootLayer: CALayer! = nil
    var previewLayer: AVCaptureVideoPreviewLayer! = nil

    // device orientation
    var currentOrientation = UIDeviceOrientation.portrait
    
    // connection to storyboard
    @IBOutlet weak var previewView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check Authorisation
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            // Access has not yet been granted
            videoDataOutputQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.videoDataOutputQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        setupCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           videoDataOutputQueue.async {
               switch self.setupResult {
               case .success:
                   // Only setup observers and start the session if setup succeeded.
                   self.session.startRunning()
                   
               case .notAuthorized:
                   DispatchQueue.main.async {
                       let changePrivacySetting = "RecycleHelper doesn't have permission to use the camera, please change privacy settings"
                       let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                       let alertController = UIAlertController(title: "RecycleHelper", message: message, preferredStyle: .alert)
                       
                       alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                               style: .cancel,
                                                               handler: nil))
                       
                       alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                               style: .`default`,
                                                               handler: { _ in
                                                                   UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                                             options: [:],
                                                                                             completionHandler: nil)
                       }))
                       
                       self.present(alertController, animated: true, completion: nil)
                   }
                   
               case .configurationFailed:
                   DispatchQueue.main.async {
                       let alertMsg = "Alert message when something goes wrong during capture session configuration"
                       let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                       let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                       
                       alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                               style: .cancel,
                                                               handler: nil))
                       
                       self.present(alertController, animated: true, completion: nil)
                   }
               }
           }
       }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //if self.isMovingFromParent {
            stopCaptureSession()
        //}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // dispose of any resources that can be recreated.
    }
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }

    //MARK: - AVCaptureSession Methods

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }

    func setupCaptureSession() {
        
        var deviceInput: AVCaptureDeviceInput! // input device of type AVCaptureDeviceInput
        
        // Set device and session resolution
        // !! set the camera resolution to the nearest resolution that is greater than or equal to the resolution of images used in the model
        
        // if a discovery session can be created
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
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




