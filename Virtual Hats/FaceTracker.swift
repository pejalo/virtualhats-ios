//
//  FaceTracker.swift
//  Virtual Hats
//
//  Created by Peter LoBue on 6/16/17.
//  Copyright © 2017 Peter LoBue. All rights reserved.
//

import Foundation
import GoogleMVDataOutput

protocol TrackerDelegate {
    var trackerView: UIView { get }
    var trackerOffset: CGPoint { get }
}

class FaceTracker: NSObject, GMVOutputTrackerDelegate {
    
    var delegate: TrackerDelegate?
    var imageName: String
    var hatView: UIImageView?
    
    private let isShowingHelpers = false
    var leftEyeLayer: CALayer?
    var rightEyeLayer: CALayer?
    var anotherPointLayer: CALayer?
    
    init(imageName: String) {
        self.imageName = imageName
        
        super.init()
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ChangeImage"), object: nil, queue: nil) { [weak self] (notification) in
            guard let imageName = notification.userInfo?["imageName"] as? String else {
                return
            }
            self?.imageName = imageName
            self?.replaceHat()
        }
    }
    
    // MARK: - GMVOutputTrackerDelegate
    
    func dataOutput(_ dataOutput: GMVDataOutput!, detectedFeature feature: GMVFeature!) {
        addHat()
    }
    
    func dataOutput(_ dataOutput: GMVDataOutput!, updateFocusing feature: GMVFeature!, forResultSet features: [GMVFeature]!) {
        
        guard let face = feature as? GMVFaceFeature
            else { return }
        
        let leftEyePosition = correctPoint(dataOutput, face.leftEyePosition)
        let rightEyePosition = correctPoint(dataOutput, face.rightEyePosition)
        
        moveHat(leftEyePosition: leftEyePosition, rightEyePosition: rightEyePosition, eulerAngleZ: face.headEulerAngleZ)
    }
    
    func dataOutput(_ dataOutput: GMVDataOutput!, updateMissing features: [GMVFeature]!) {
        // Commented out because it makes the hat flash more often
        // hatView?.isHidden = true
    }
    
    func dataOutputCompleted(withFocusingFeature dataOutput: GMVDataOutput!) {
        removeHat()
    }
    
    func correctPoint(_ dataOutput: GMVDataOutput, _ point: CGPoint) -> CGPoint {
        
        var x = point.x * dataOutput.xScale + dataOutput.offset.x
        var y = point.y * dataOutput.yScale + dataOutput.offset.y
        
        if let trackerOffset = delegate?.trackerOffset {
            x += trackerOffset.x
            y += trackerOffset.y
        }
        
        return CGPoint(x: x, y: y)
    }
    
    // MARK: - Operations
    
    func addHat() {
        
        hatView = UIImageView(image: UIImage(named: imageName))
        hatView?.isHidden = true // Will be revealed when moved
        delegate?.trackerView.addSubview(hatView!);
        
        if isShowingHelpers {
            leftEyeLayer = CALayer()
            rightEyeLayer = CALayer()
            anotherPointLayer = CALayer()
            leftEyeLayer?.width = 5
            leftEyeLayer?.height = 5
            rightEyeLayer?.width = 5
            rightEyeLayer?.height = 5
            anotherPointLayer?.width = 5
            anotherPointLayer?.height = 5
            delegate?.trackerView.layer.addSublayer(rightEyeLayer!)
            delegate?.trackerView.layer.addSublayer(leftEyeLayer!)
            delegate?.trackerView.layer.addSublayer(anotherPointLayer!)
        }
    }
    
    // Returns true if a hat actually existed to remove
    @discardableResult
    func removeHat() -> Bool {
        
        let hatExisted = hatView != nil
        
        hatView?.removeFromSuperview()
        hatView = nil
        
        if isShowingHelpers {
            leftEyeLayer?.removeFromSuperlayer()
            leftEyeLayer = nil
            rightEyeLayer?.removeFromSuperlayer()
            rightEyeLayer = nil
            anotherPointLayer?.removeFromSuperlayer()
            anotherPointLayer = nil
        }
        
        return hatExisted
    }
    
    func moveHat(leftEyePosition: CGPoint, rightEyePosition: CGPoint, eulerAngleZ: CGFloat) {
        
        guard var hatView = self.hatView,
            let hatViewImage = hatView.image
        else { return }
        
        let hatViewRatio = hatViewImage.size.width / hatViewImage.size.height
        
        let distanceBetweenEyes = hypot(leftEyePosition.x - rightEyePosition.x, leftEyePosition.y - rightEyePosition.y)
        
        let newWidth = (distanceBetweenEyes * 3.5)
        let newHeight = (newWidth / hatViewRatio)
        
        let pointBetweenEyes = CGPoint(
            x: leftEyePosition.x + (rightEyePosition.x - leftEyePosition.x)/2,
            y: leftEyePosition.y + (rightEyePosition.y - leftEyePosition.y)/2
        )
        let hatAnchorDistanceFromPointBetweenEyes = newHeight/2
        
        // hatAnchorPoint is the desired center of the hatImage
        // https://stackoverflow.com/questions/2887513/find-the-point-with-radius-and-angle
        let angle = (eulerAngleZ - 90) * CGFloat(Double.pi/180)
        let hatAnchorPoint = CGPoint(
            x: (pointBetweenEyes.x - hatAnchorDistanceFromPointBetweenEyes*cos(angle)).rounded(),
            y: (pointBetweenEyes.y + hatAnchorDistanceFromPointBetweenEyes*sin(angle)).rounded()
        )
        
        // By default we move the hat with an animation so it's smoother,
        // but if the hat needs to move too far, we don't want to animate it
        // because it feels too much like the hat is lagging/trailing behind
        
        let animated = !( abs(newWidth - hatView.width) > 20 || abs(newHeight - hatView.height) > 20 )
        
        // Try to keep the hat from jerking around so much by only moving it if the distance is significant
        
        let shouldApplyTransformation = animated
            || abs(newWidth - hatView.width) > 5
            || abs(newHeight - hatView.height) > 5
            || abs(hatAnchorPoint.x - hatView.center.x) > 5
            || abs(hatAnchorPoint.y - hatView.center.y) > 5
        
        guard shouldApplyTransformation else {
            return
        }
        
        let transformations: () -> Void = {
            // Must set this before changing frame to avoid stretching image
            // https://stackoverflow.com/a/12054239/4621566
            hatView.transform = CGAffineTransform.identity
            hatView.width = newWidth
            hatView.height = newHeight
            hatView.center = hatAnchorPoint
            hatView.transform = CGAffineTransform(rotationAngle: (angle + CGFloat(Double.pi/2)) * -1)
        }
        
        if animated {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .beginFromCurrentState, animations: {
                transformations()
            }, completion: nil)
        } else {
            transformations()
        }
        
        hatView.isHidden = false
        
        if isShowingHelpers {
            leftEyeLayer?.backgroundColor = UIColor.red.cgColor
            leftEyeLayer?.center = leftEyePosition
            rightEyeLayer?.backgroundColor = UIColor.blue.cgColor
            rightEyeLayer?.center = rightEyePosition
            anotherPointLayer?.backgroundColor = UIColor.green.cgColor
            anotherPointLayer?.center = hatAnchorPoint
            leftEyeLayer?.isHidden = false
            rightEyeLayer?.isHidden = false
            anotherPointLayer?.isHidden = false
        }
    }
    
    func replaceHat() {
        
        let removed = removeHat()
        
        if removed {
            hatView = UIImageView(image: UIImage(named: imageName))
            addHat()
        }
    }
}
