//
//  HatSelectorView.swift
//  Virtual Hats
//
//  Created by Peter LoBue on 6/19/17.
//  Copyright © 2017 Peter LoBue. All rights reserved.
//

import Foundation
import UIKit

class HatSelectorView: UIView, UIGestureRecognizerDelegate {

    @IBOutlet var hatImageViews: [UIImageView]!
    let imageNames = ["hat1", "hat2", "hat3"]
    
    func setUpGestureRecognizers() {
        for imageView in hatImageViews {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userTappedImageView))
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.delegate = self
            imageView.addGestureRecognizer(tapGestureRecognizer)
            
            print(imageView)
            print(imageView.isUserInteractionEnabled)
            print("set one up")
        }
        
        self.makeImageViewLookSelected(imageView: hatImageViews.first!)
    }
    
    func userTappedImageView(gestureRecognizer: UIGestureRecognizer) {
        print("tapped")
        
        guard let imageView = gestureRecognizer.view as? UIImageView,
            let index = hatImageViews.index(of: imageView)
        else {
            return
        }
        
        makeImageViewLookSelected(imageView: imageView)
        
        let imageName = imageNames[index]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ChangeImage"), object: nil, userInfo: ["imageName" :imageName])
    }
    
    func makeImageViewLookSelected(imageView: UIView) {
        for iv in hatImageViews {
            iv.alpha = 1
        }
        imageView.alpha = 0.4
    }
}
