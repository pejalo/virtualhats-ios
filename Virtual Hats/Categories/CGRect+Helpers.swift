//
//  CGRect+Helpers.swift
//  Goose
//
//  Created by Peter LoBue on 8/28/16.
//  Copyright © 2016 pejalo. All rights reserved.
//

import CoreGraphics

extension CGRect
{
    var x: CGFloat
    {
        get { return self.origin.x }
        set(x) { self.origin.x = x }
    }
    
    var y: CGFloat
    {
        get { return self.origin.y }
        set(y) { self.origin.y = y }
    }
    
    var width: CGFloat
    {
        get { return self.size.width }
        set(width) { self.size.width = width }
    }
    
    var height: CGFloat
    {
        get { return self.size.height }
        set(height) { self.size.height = height }
    }
    
    var xPlusWidth: CGFloat
    {
        get { return self.x + self.width }
        set(xPlusWidth) { self.x = xPlusWidth - self.width }
    }
    
    var yPlusHeight: CGFloat
    {
        get { return self.y + self.height }
        set(yPlusHeight) { self.y = yPlusHeight - self.height }
    }
    
    var center: CGPoint
    {
        get { return CGPoint(x: self.x + self.width/2, y: self.y + self.height/2) }
        set(center)
        {
            self.centerX = center.x
            self.centerY = center.y
        }
    }
    
    var centerX: CGFloat
    {
        get { return self.x + self.width/2 }
        set(centerX) { self.x = (centerX - self.width/2) }
    }
    
    var centerY: CGFloat
    {
        get { return self.y + self.height/2 }
        set(centerY) { self.y = (centerY - self.height/2) }
    }
}
