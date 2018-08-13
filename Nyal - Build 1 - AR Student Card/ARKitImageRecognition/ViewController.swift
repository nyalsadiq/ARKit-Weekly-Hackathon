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
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: #selector(tapBox(rec:)))
        sceneView.addGestureRecognizer(tapRecognizer)
        
        sceneView.autoenablesDefaultLighting = true
        
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
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
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.2)
        text.font = UIFont.systemFont(ofSize: 16.0)
        text.flatness = 0.2
        text.firstMaterial?.diffuse.contents = UIColor.cyan
        
        let textNode = SCNNode(geometry: text)
        let fontSize = Float(0.1)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        textNode.eulerAngles.x = -.pi / 2
        textNode.isHidden = false
        return textNode
    }
    
    func addText(string: String, parent: SCNNode) -> SCNNode {
        let textNode = self.createTextNode(string: string)
        textNode.position = SCNVector3Zero
        parent.addChildNode(textNode)
        return textNode
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
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
	}

    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            
            let sid = self.addText(string: "S1642131", parent: node)
            sid.runAction(SCNAction.moveBy(x: 4, y: 0.0, z: 0.0, duration: 1))
            
            let sname = self.addText(string: "NT Sadiq", parent: node)
            sname.runAction(SCNAction.moveBy(x: 4, y: 0.0, z: 2.0, duration: 1))

            // Create a plane to visualize the initial position of the detected image.
            let card = SCNScene(named: "Edi.scn")!
            
            //card.rootNode.eulerAngles.x = -.pi / 2
            let rotation = SCNAction.rotateBy(x: 0, y: 360, z: 0, duration: 100)
            let scale = SCNAction.scale(by: 2.0, duration: 5)
            
            card.rootNode.runAction(scale, forKey: "edi_scale")
            card.rootNode.runAction(rotation, forKey: "edi_rotate")
            
            // Add the plane visualization to the scene.
            node.addChildNode(card.rootNode)
        }

        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
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
