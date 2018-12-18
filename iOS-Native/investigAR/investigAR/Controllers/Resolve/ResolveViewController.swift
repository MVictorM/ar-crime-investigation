//
//  ResolveViewController.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit
import ARKit
import ARCore
import Firebase

class ResolveViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var resolveButton: UIButton!
    
    
    // MARK: - Properties
    var gSession: GARSession?
    var firebaseReference: DatabaseReference?
    var arAnchor: ARAnchor?
    var garAnchor: GARAnchor?
    var anchorID: String!
    
    @IBAction func tapResolveButton(_ sender: Any) {
        self.resolveAnchor(identifier: self.anchorID)
    }
    
    // Mark - Overriding UIViewController
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firebaseReference = Database.database().reference()
        
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        
        
        try! self.gSession = GARSession(
            apiKey: "AIzaSyCNZauBaRRYPXzY-4Q3e7xS90EVei9IcxM",
            bundleIdentifier: nil
        )
        self.gSession!.delegate = self
        self.gSession!.delegateQueue = DispatchQueue.main
        
        self.resolveAnchor(identifier: self.anchorID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuarion = ARWorldTrackingConfiguration()
        configuarion.worldAlignment = .gravity
        configuarion.planeDetection = .horizontal
        
        self.sceneView.session.run(configuarion)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    
    // MARK: - Resolving anchor
    func resolveAnchor(identifier: String) {
        // Now that we have the anchor ID from firebase, we resolve the anchor.
        // Success and failure of this call is handled by the delegate methods
        // session:didResolveAnchor and session:didFailToResolveAnchor appropriately.
        do {
            self.garAnchor = try self.gSession!.resolveCloudAnchor(withIdentifier: identifier)
        } catch {
            print(error)
            self.resolveButton.isHidden = false
            self.statusLabel.isHidden = false
        }
    }
    
    
    // MARK: - Helper Methods
//    func updateMessageLabel() {
//        self.messageLabel.text = self.message
//        self.roomCodeLabel.text = "Room: \(self.roomCode!)"
//    }


}


// MARK: - ARSCNViewDelegate
extension ResolveViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARPlaneAnchor {
            return SCNNode()
        } else {
            let scene = SCNScene(named: "example.scnassets/andy.scn")
            return scene?.rootNode.childNode(withName: "lumberJack", recursively: false)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            plane.materials.first?.diffuse.contents = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            
            let planeNode = SCNNode(geometry: plane)
            
            let x = planeAnchor.center.x
            let y = planeAnchor.center.y
            let z = planeAnchor.center.z
            planeNode.position = SCNVector3Make(x, y, z);
            planeNode.eulerAngles = SCNVector3Make(-Float.pi / 2, 0, 0);
            
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let planeNode = node.childNodes.first
            let plane = planeNode?.geometry as? SCNPlane
            
            let width = planeAnchor.extent.x
            let height = planeAnchor.extent.z
            plane?.width = CGFloat(width)
            plane?.height = CGFloat(height)
            
            let x = planeAnchor.center.x;
            let y = planeAnchor.center.y;
            let z = planeAnchor.center.z;
            planeNode?.position = SCNVector3Make(x, y, z);
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeNode = node.childNodes.first
            planeNode?.removeFromParentNode()
        }
    }
    
}



// MARK: - ARSessionDelegate
extension ResolveViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Forward ARKit's update to ARCore session
        try! self.gSession?.update(frame)
    }
}


// MARK: - GARSessionDelegate
extension ResolveViewController: GARSessionDelegate {
    func session(_ session: GARSession, didResolve anchor: GARAnchor) {
        if (anchor != self.garAnchor) { return }
        self.garAnchor = anchor;
        self.arAnchor = ARAnchor(transform: anchor.transform)
        self.sceneView.session.add(anchor: self.arAnchor!)
        
        self.resolveButton.isHidden = true
        self.statusLabel.isHidden = true
    }
    
    func session(_ session: GARSession, didFailToResolve anchor: GARAnchor) {
        if (anchor != self.garAnchor) { return }
        self.garAnchor = anchor
    }
}
