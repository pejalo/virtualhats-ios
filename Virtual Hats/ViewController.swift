//
//  ViewController.swift
//  Virtual Hats
//
//  Created by Peter LoBue on 6/16/17.
//  Copyright © 2017 Peter LoBue. All rights reserved.
//

// For this app I chose to use Google's Mobile Vision SDK.
// Here are some resources for what Apple offers:
// https://www.codeproject.com/Articles/1097378/In-Your-Face-Figuring-Out-Apple-s-Face-Detection-A
// https://stackoverflow.com/questions/34383917/face-detection-with-avfoundation-swift-2
// http://www.icapps.com/face-detection-with-core-image-on-live-video/#comment-4587

import UIKit
import GoogleMobileVision
import GoogleMVDataOutput

class ViewController: UIViewController, UIWebViewDelegate {
    
    var imageName = "hat1"
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var hatSelectorView: HatSelectorContainerView!
    @IBOutlet weak var allowAccessView: UIView!
    
    private var captureVC: CaptureViewController?
    private var isKeyboardShown = false
    private var keyboardHeight: CGFloat = 0
    private var lastCaptureViewCenter = CGPoint.zero
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ChangeImage"), object: nil, queue: nil) { [weak self] (notification) in
            
            guard let imageName = notification.userInfo?["imageName"] as? String else {
                return
            }
            
            self?.imageName = imageName
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { [weak self] notification in
            
            self?.isKeyboardShown = true
            
            if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height {
                self?.keyboardHeight = keyboardHeight
            }
            
            self?.view.setNeedsLayout()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { [weak self] notification in
            
            self?.isKeyboardShown = false
            self?.keyboardHeight = 0
            self?.view.setNeedsLayout()
        }
        
        hatSelectorView.setUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if captureVC == nil {
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if status == .authorized {
                setUp()
            } else {
                allowAccessView.isHidden = false
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if var captureView = captureVC?.view {
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            if !webView.isHidden {
                let spacing: CGFloat = 15
                captureView.width = 80
                captureView.height = 110
                captureView.x = spacing
                if isKeyboardShown {
                    captureView.yPlusHeight = view.height - (40 + keyboardHeight) - spacing
                } else {
                    captureView.yPlusHeight = view.height - spacing
                }
            } else {
                captureView.frame = view.bounds
            }
            
            captureVC?.frameChanged()
            lastCaptureViewCenter = captureView.center
            
            CATransaction.commit()
        }
    }
    
    // MARK: - Public
    
    func setUp() {
        
        captureVC = CaptureViewController(onFeatureDetected: { [weak self] in
            let tracker = FaceTracker(imageName: self?.imageName ?? "hat1")
            tracker.delegate = self?.captureVC
            return tracker
        })
        
        captureVC!.view.frame = view.bounds
        captureVC!.view.clipsToBounds = true
        captureVC!.setUp()
        
        view.insertSubview(captureVC!.view, at: 0)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userPannedCaptureView))
        captureVC!.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - User actions
    
    @IBAction func userTappedToAllowAccess(_ sender: Any) {
        allowAccessToCamera()
    }
    
    @IBAction func userTappedToWork(_ sender: Any) {
        showWebView()
    }
    
    func userTappedToStopWorking() {
        hideWebView()
    }
    
    func userPannedCaptureView(panGestureRecognizer: UIPanGestureRecognizer) {
        
        let captureView = captureVC!.view!
        let translation = panGestureRecognizer.translation(in: captureView.superview!)
        
        captureView.center = CGPoint(x: lastCaptureViewCenter.x + translation.x, y: lastCaptureViewCenter.y + translation.y)
        
        let states: [UIGestureRecognizerState] = [.cancelled, .failed, .ended]
        if states.contains(panGestureRecognizer.state) {
            lastCaptureViewCenter = captureView.center
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        activityView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        activityView.stopAnimating()
    }
    
    // MARK: - Helpers
    
    func allowAccessToCamera() {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [weak self] (granted) in
                DispatchQueue.main.async {
                    self?.hideCameraAccessView()
                    self?.setUp()
                }
            })
        } else {
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
    
    func hideCameraAccessView() {
        allowAccessView.isHidden = true
    }
    
    func showInfo() {
        
        let alertController = UIAlertController(title: "Virtual Hats by Hurry", message: "© year of the 🐓", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Change hats", style: .default, handler: { [weak self] (action) in
            self?.userTappedToStopWorking()
        }))
        
        alertController.addAction(UIAlertAction(title: "google.com", style: .default, handler: { [weak self] (action) in
            self?.loadStartpageInWebView()
        }))
        
        alertController.addAction(UIAlertAction(title: "hurrymusic.com", style: .default, handler: { [weak self] (action) in
            self?.webView.loadRequest(URLRequest(url: URL(string: "http://www.hurrymusic.com")!))
        }))
        
        alertController.addAction(UIAlertAction(title: "Hurry on Twitter ➚", style: .default, handler: { (action) in
            let screenName =  "hurryband"
            let appURL = URL(string: "twitter://user?screen_name=\(screenName)")!
            let webURL = URL(string: "https://twitter.com/\(screenName)")!
            
            let application = UIApplication.shared
            
            if application.canOpenURL(appURL) {
                application.open(appURL, options: [:], completionHandler: nil)
            } else {
                application.open(webURL, options: [:], completionHandler: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Get back to work", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadStartpageInWebView() {
        webView.loadRequest(URLRequest(url: URL(string: "http://www.google.com")!))
    }
    
    func showWebView() {
        guard let captureView = captureVC?.view else {
            return
        }
        
        webView.isHidden = false
        
        if (!webView.canGoBack) {
            loadStartpageInWebView()
        }
        
        view.addSubview(captureView) // Moves to front
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showInfo))
        captureView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func hideWebView() {
        
        guard let captureView = captureVC?.view else {
            return
        }
        
        for gestureRecognizer in captureView.gestureRecognizers ?? [] {
            if gestureRecognizer is UITapGestureRecognizer {
                captureView.removeGestureRecognizer(gestureRecognizer)
            }
        }
        
        view.insertSubview(captureView, at: 0)
        
        webView.isHidden = true
        view.addSubview(webView)
        
        activityView.stopAnimating()
    }
}
