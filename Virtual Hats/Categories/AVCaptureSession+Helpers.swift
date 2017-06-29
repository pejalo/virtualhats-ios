//
//  AVCaptureSession+Helpers.swift
//  Virtual Hats
//
//  Created by Peter LoBue on 6/20/17.
//  Copyright © 2017 Peter LoBue. All rights reserved.
//

import AVFoundation

extension AVCaptureSession {
    
    func removeAllInputs() {
        
        for oldInput in self.inputs {
            if let input = oldInput as? AVCaptureInput {
                self.removeInput(input)
            }
        }
    }
}
