//
//  ViewController+LabelRender.swift
//  ARKitImageRecognition
//
//  Created by Nyal Sadiq on 18/08/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

extension ViewController {
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            
            let label = SKScene(fileNamed: "label.sks")!;
            let material = SCNMaterial();
            let plane = SCNPlane(width: 3.0, height: 2.0);
            
            plane.cornerRadius = 0.2;

            material.diffuse.contents = label;
            material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            
            let label_node = SCNNode(geometry: plane);
            label_node.geometry?.firstMaterial = material;
            label_node.scale.x = 3;
            label_node.scale.y = 3;
            label_node.eulerAngles.x = -.pi / 2;
            
            
            label_node.runAction(SCNAction.move(to: SCNVector3(x:0.0, y: 0.0, z: -4.0), duration: 1.0))
            
            node.addChildNode(label_node);
        }
        
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }    
    
}
