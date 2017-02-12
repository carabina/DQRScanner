//
//  DQRScannerView.swift
//  Pods
//
//  Created by Carpenter, Deepak (US - Bengaluru) on 09/02/17.
//
//

import UIKit
import AVFoundation

open class DQRScannerView: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var topbar: UIView?
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var messageLabel : UILabel?
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]
    
    override open var prefersStatusBarHidden: Bool{
        return true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
            //view.bringSubview(toFront: messageLabel)
            //view.bringSubview(toFront: topbar)
            //view.bringSubview(toFront: messageTextView)
            topbar = UIView()
            messageLabel = UILabel()
            if let topbar = topbar {
                topbar.backgroundColor = UIColor.white
                topbar.alpha = 0.8
                messageLabel?.text = "No QR/barcode is detected"
                topbar.addSubview(messageLabel!)
                view.addSubview(topbar)
                view.bringSubview(toFront: topbar)
            }
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.cyan.cgColor
                qrCodeFrameView.layer.borderWidth = 3
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
           
            topbar?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
            messageLabel?.frame = CGRect(x: (topbar?.frame.origin.x)! + 10, y: 0, width:(topbar?.frame.width)!, height: 50)
            view.bringSubview(toFront: messageLabel!)
            view.bringSubview(toFront: topbar!)
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel?.text = "No QR/barcode is detected"
            //messageTextView.text = "No QR/barcode is detected"
            
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                  messageLabel?.text = metadataObj.stringValue
                //messageTextView.text = metadataObj.stringValue
                
                print(metadataObj.stringValue)
                parseQRString(qrString: metadataObj.stringValue)
                let alertCon = UIAlertController(title: nil, message: metadataObj.stringValue, preferredStyle: .actionSheet)
                let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
                alertCon.addAction(action)
                //present(alertCon, animated: true, completion: nil)
            }
        }
    }
   
    open func parseQRString(qrString : String) {
        print(qrString)
        
    }
    
   }
