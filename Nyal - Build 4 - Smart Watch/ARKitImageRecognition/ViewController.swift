/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed to avoid interuppting the AR experience.
		UIApplication.shared.isIdleTimerDisabled = true

        // Start the AR experience
        resetTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

        session.pause()
	}

    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true

    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
	func resetTracking() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
	}

    func createTextNode(string: String, size: Float) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.2)
        text.font = UIFont.systemFont(ofSize: 16.0)
        text.flatness = 0.2
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        let fontSize = size
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        textNode.eulerAngles.x = -.pi / 2
        textNode.isHidden = false
        return textNode
    }
    
    func addText(string: String, size: Float, parent: SCNNode) -> SCNNode {
        let textNode = self.createTextNode(string: string, size: size)
        textNode.position = SCNVector3Zero
        parent.addChildNode(textNode)
        return textNode
    }
    
    func addSKScene(skScene: SKScene, toPlane plane: SCNPlane) {
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 1)
        plane.materials = [material]
    }
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width * 2,
                                 height: referenceImage.physicalSize.height)
            plane.cornerRadius = 0.01
         
            let title = self.addText(string: "Shopping List:", size: 0.001, parent: node)
            let milk = self.addText(string: "+ Milk", size: 0.0008 ,parent: node)
            let eggs = self.addText(string: "+ Eggs", size: 0.0008 ,parent: node)
            let kitkat = self.addText(string: "+ KitKat", size: 0.0008, parent: node)
            let internship = self.addText(string: "+ Summer Internship", size: 0.0008, parent: node)
            
            milk.isHidden = true
            eggs.isHidden = true
            kitkat.isHidden = true
            internship.isHidden = true
            
            node.addChildNode(title)
            node.addChildNode(milk)
            node.addChildNode(eggs)
            node.addChildNode(kitkat)
            node.addChildNode(internship)
            
            title.runAction(SCNAction.moveBy(x: 0.02, y: 0.0, z: 0.0, duration: 1))
            milk.runAction(SCNAction.moveBy(x: 0.02, y: 0.0, z: 0.0, duration: 1))
            eggs.runAction(SCNAction.moveBy(x: 0.02, y: 0.0, z: 0.0, duration: 1))
            kitkat.runAction(SCNAction.moveBy(x: 0.02, y: 0.0, z: 0.0, duration: 1))
            internship.runAction(SCNAction.moveBy(x: 0.02, y: 0.0, z: 0.0, duration: 1))
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                milk.isHidden = false
                milk.runAction(SCNAction.moveBy(x: 0.0, y: 0.0, z: 0.015, duration: 1))
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                eggs.isHidden = false
                eggs.runAction(SCNAction.moveBy(x: 0.0, y: 0.0, z: 0.030, duration: 1))
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                kitkat.isHidden = false
                kitkat.runAction(SCNAction.moveBy(x: 0.0, y: 0.0, z: 0.045, duration: 1))
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                internship.isHidden = false
                internship.runAction(SCNAction.moveBy(x: 0.0, y: 0.0, z: 0.060, duration: 1))
            })
            
        }

    }

    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
        ])
    }
}
