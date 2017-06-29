//
//  UIView+FrameHelpers.swift
//  Goose
//
//  Created by Peter LoBue on 8/28/16.
//  Copyright © 2016 pejalo. All rights reserved.
//

import UIKit

extension UIView: ViewFrame {}
extension CALayer: ViewFrame {}

protocol ViewFrame {
    var frame: CGRect { get set }
}

extension ViewFrame
{
    var x: CGFloat {
        get { return self.frame.x }
        set(x) { self.frame.x = x }
    }
    
    var width: CGFloat {
        get { return self.frame.width }
        set(width) { self.frame.width = width }
    }
    
    var xPlusWidth: CGFloat {
        get { return self.x + self.width }
        set(xPlusWidth) { self.x = xPlusWidth - self.width }
    }
    
    var y: CGFloat {
        get { return self.frame.y }
        set(y) { self.frame.y = y }
    }
    
    var height: CGFloat {
        get { return self.frame.height }
        set(height) { self.frame.height = height }
    }
    
    var yPlusHeight: CGFloat {
        get { return self.y + self.height }
        set(yPlusHeight) { self.y = yPlusHeight - self.height }
    }
    
    var centerX: CGFloat {
        get { return self.frame.center.x }
        set(centerX) { self.frame.centerX = centerX }
    }
    
    var centerY: CGFloat {
        get { return self.frame.center.y }
        set(centerY) { self.frame.centerY = centerY }
    }
    
    var center: CGPoint {
        get { return self.frame.center }
        set(center) { self.frame.center = center }
    }
}
