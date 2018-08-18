
//
//  ViewController+Actions.swift
//  ARKitImageRecognition
//
//  Created by Nyal Sadiq on 18/08/2018.
//  Copyright © 2018 Apple. All rights reserved.
//
import ARKit
import SceneKit
import UIKit

extension ViewController {
    
    func addText(string: String, parent: SCNNode) -> SCNNode {
        let textNode = self.createTextNode(string: string)
        textNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        parent.addChildNode(textNode)
        return textNode
    }
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.2)
        text.font = UIFont.systemFont(ofSize: 16.0)
        text.flatness = 0.2
        text.firstMaterial?.diffuse.contents = UIColor.black
        
        let textNode = SCNNode(geometry: text)
        textNode.isHidden = false
        return textNode
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            ])
    }
    
}
