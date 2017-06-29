//
//  CaptureViewController.swift
//  Virtual Hats
//
//  Created by Peter LoBue on 6/19/17.
//  Copyright © 2017 Peter LoBue. All rights reserved.
//

import UIKit
import GoogleMobileVision
import GoogleMVDataOutput

class CaptureViewController: UIViewController, GMVMultiDataOutputDelegate, TrackerDelegate {
    
    var onFeatureDetected: () -> GMVOutputTrackerDelegate
    
    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var dataOutput: GMVMultiDataOutput?
    
    // MARK: - UIViewController Lifecycle
    
    init(onFeatureDetected: @escaping () -> GMVOutputTrackerDelegate) {
        self.onFeatureDetected = onFeatureDetected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        session?.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        session?.stopRunning()
    }
    
    // MARK: - Public
    
    func setUp() {
        
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSessionPresetMedium
        session?.beginConfiguration()
        session?.removeAllInputs()
        let device = AVCaptureDevice.defaultDevice(
            withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
            mediaType: AVMediaTypeVideo,
            position: AVCaptureDevicePosition.front
        )
        let input = try! AVCaptureDeviceInput(device: device)
        session?.addInput(input)
        session?.commitConfiguration()
        
        let options: [AnyHashable : Any] = [
            GMVDetectorFaceTrackingEnabled: NSNumber.init(value: true),
            GMVDetectorFaceMode: NSNumber.init(value: GMVDetectorFaceModeOption.fastMode.rawValue),
            GMVDetectorFaceLandmarkType: NSNumber.init(value: GMVDetectorFaceLandmark.all.rawValue),
            GMVDetectorFaceClassificationType: NSNumber.init(value: GMVDetectorFaceClassification.all.rawValue),
            GMVDetectorFaceMinSize: NSNumber.init(value: 0.15)
        ]
        let faceDetector = GMVDetector(ofType: GMVDetectorTypeFace, options: options)
        
        dataOutput = GMVMultiDataOutput(detector: faceDetector)
        dataOutput?.multiDataDelegate = self
        session?.addOutput(dataOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        
        frameChanged()
        
        self.view.layer.insertSublayer(previewLayer!, at: 0)
        debugPrint("Inserted preview layer")
    }
    
    // The consumer of this class should call this method after changing the view's frame.
    
    func frameChanged() {
        previewLayer?.frame = previewLayerFrame()
        dataOutput?.previewFrameSize = previewLayer!.frame.size
    }
    
    // MARK: - GMVMultiDataOutputDelegate
    
    func dataOutput(_ dataOutput: GMVDataOutput!, trackerFor feature: GMVFeature!) -> GMVOutputTrackerDelegate! {
        return onFeatureDetected()
    }
    
    // MARK: - TrackerDelegate
    
    var trackerView: UIView {
        get { return view }
    }
    
    var trackerOffset: CGPoint {
        get {
            let previewLayerFrame = self.previewLayerFrame()
            let viewSize = view.bounds.size
            
            let previewLayerRatio = previewLayerFrame.width / previewLayerFrame.height
            let screenRatio = viewSize.width / viewSize.height
            
            if previewLayerRatio > screenRatio {
                return CGPoint(x: (previewLayerFrame.width - viewSize.width)/2 * -1, y: 0)
            } else {
                return CGPoint(x: 0, y: (previewLayerFrame.height - viewSize.height)/2 * -1)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func previewLayerFrame() -> CGRect {
        
        // GMVDataOutput assumes that the previewLayer's videoGravity is set to AVLayerVideoGravityResizeAspect
        // This means the camera output is shrunk down to "fit" inside the layer's frame,
        // leaving empty bars on the sides if the frame does not have the proper ratio.
        // Ideally, we want to be able to control the previewLayer's size such that the camera output
        // always fills it entirely. To achieve this, the consumer of this method can simply change
        // this object's view frame, and then should call frameChanged(). frameChanged in turn calls this method
        // which returns the proper frame for this object's previewlayer, such that
        // it will completely fill this object's view.
        
        let cameraAspectRatio: CGFloat = 3/4
        let viewSize = view.bounds.size
        
        var frame = CGRect.zero
        
        if viewSize.height > viewSize.width {
            let height = viewSize.height
            let width = height * cameraAspectRatio
            
            frame = CGRect(
                x: (width - viewSize.width)/2 * -1,
                y: 0,
                width: width,
                height: height
            )
        } else {
            let width = viewSize.width
            let height = width / cameraAspectRatio
            
            frame = CGRect(
                x: 0,
                y: (height - viewSize.height)/2 * -1,
                width: width,
                height: height
            )
        }
        
        return frame
    }
}
