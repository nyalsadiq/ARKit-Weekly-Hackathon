//
//  ViewController+TapGesture.swift
//  ARKitImageRecognition
//
//  Created by Nyal Sadiq on 18/08/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

extension ViewController {
    
    @objc func tapBox(rec gestureRecognizer : UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .ended {
            let location: CGPoint = gestureRecognizer.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                let tappedNode = hits.first?.node
                statusViewController.scheduleMessage((tappedNode?.name)!, inSeconds: 0.1, messageType: .contentPlacement)
            }
        }
    }
    
}
