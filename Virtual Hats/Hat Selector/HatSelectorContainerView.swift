//
//  HatSelectorContainerView.swift
//  Virtual Hats
//
//  Created by Peter LoBue on 6/18/17.
//  Copyright © 2017 Peter LoBue. All rights reserved.
//

import Foundation
import UIKit

class HatSelectorContainerView: UIView {
    
    var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        view = Bundle.main.loadNibNamed("HatSelector", owner: self, options: nil)?[0] as? UIView
        
        print(view)
        
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            let width = UIScreen.main.bounds.width
            let height = (width - (5*4))/3 * 7/10 + 2*5
            return CGSize(width: width, height: height)
        }
    }
    
    func setUp() {
        (view as? HatSelectorView)?.setUpGestureRecognizers()
    }
}
