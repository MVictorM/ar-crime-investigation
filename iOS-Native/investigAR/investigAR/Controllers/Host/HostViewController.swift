//
//  HostViewController.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit
import ARKit
import ARCore
import Firebase

enum HostARState: Int {
    case start
    case creatingRoom
    case roomCreated
    case hosting
    case hostingFinished
}

class HostViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    // MARK: - Properties
    var gSession: GARSession?
    var firebaseReference: DatabaseReference?
    var arAnchor: ARAnchor?
    var garAnchor: GARAnchor?
    var state: HostARState?
    var roomCode: String?
    var statusMessage: String?
    var crime: Crime!
    
    
    // Mark - Overriding UIViewController
    fileprivate func transparentNavBar() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

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
        self.enterState(.start)
        
        self.createRoom()
        
        self.transparentNavBar()
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (touches.count < 1 || self.state != .roomCreated) {
            return
        }
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self.sceneView)
        
        let hitTestResults = self.sceneView.hitTest(
            touchLocation,
            types: [.existingPlane, .existingPlaneUsingExtent, .estimatedHorizontalPlane]
        )
        
        
        if (hitTestResults.count > 0) {
            let result = hitTestResults.first!
            self.addAnchor(transform: result.worldTransform)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let waitingRoom = segue.destination as? WaitingRoomViewController {
            waitingRoom.crime = self.crime
        }
    }
    
    
    // MARK: - Anchor Hosting
    func addAnchor(transform: matrix_float4x4) {
        self.arAnchor = ARAnchor(transform: transform)
        self.sceneView.session.add(anchor: self.arAnchor!)
        
        // To share an anchor, we call host anchor here on the ARCore session.
        // session:disHostAnchor: session:didFailToHostAnchor: will get called appropriately.
        do {
            self.garAnchor = try self.gSession!.hostCloudAnchor(self.arAnchor!)
            self.enterState(.hosting)
        } catch {
            print(error)
        }
    }
    
    
    // MARK: - Helper Methods
    func updateStatusLabel() {
        self.statusLabel.text = self.statusMessage
    }
    
    
    func enterState(_ state: HostARState) {
        switch (state) {
        case .start:
            if let anchor = self.arAnchor {
                self.sceneView.session.remove(anchor: anchor)
                self.arAnchor = nil
            }
            if let anchor = self.garAnchor {
                self.gSession?.remove(anchor)
                self.garAnchor = nil
            }
            if (self.state == .creatingRoom) {
                self.statusMessage = "Falha na criação da investigação, tente novamente."
            } else {
                self.statusMessage = "Tap HOST or RESOLVE to begin."
            }
            self.roomCode = ""
            
        case .creatingRoom:
            self.statusMessage = "Criando investigação..."
            
        case .roomCreated:
            self.statusMessage = "Toque em um plano para fixar a cena do crime."
            
        case .hosting:
            self.statusMessage = "Fixando cena..."
            
        case .hostingFinished:
            self.statusMessage = "Cena fixada: \(self.garAnchor!.cloudState.message)"
            self.crime.roomNumber = Int(self.roomCode!)!
            self.performSegue(withIdentifier: "toWaitingRoom", sender: nil)
        }
        
        self.state = state
        self.updateStatusLabel()
    }
    
    
    func createRoom() {
        self.enterState(.creatingRoom)
        weak var weakSelf = self
        self.firebaseReference?.child("last_room_code")
            .runTransactionBlock({ (currentData) -> TransactionResult in
                let strongSelf = weakSelf
                
                
                let roomNumber = currentData.value as? NSNumber ?? 0
                
                var roomNumberInt = roomNumber.intValue
                roomNumberInt += 1
                let newRoomNumber = NSNumber(value: roomNumberInt)
                
                
                let timestampInteger = Date().timeIntervalSince1970 * 1000
                let timestamp = NSNumber(value: timestampInteger)
                
                
                let room: [String : Any] = [
                    "display_name" : newRoomNumber.stringValue,
                    "updated_at_timestamp" : timestamp,
                    ]
                
                strongSelf?.firebaseReference?.child("hotspot_list")
                    .child(newRoomNumber.stringValue)
                    .setValue(room)
                
                currentData.value = newRoomNumber
                
                return TransactionResult.success(withValue: currentData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                DispatchQueue.main.async {
                    if error != nil {
                        weakSelf?.roomCreationFailed()
                    } else {
                        let roomNumber = snapshot!.value! as! NSNumber
                        weakSelf?.roomCreated(roomCode: roomNumber.stringValue)
                    }
                }
            })
    }
    
    func roomCreated(roomCode: String) {
        self.roomCode = roomCode
        self.enterState(.roomCreated)
    }
    
    func roomCreationFailed() {
        self.enterState(.start)
    }
}


// MARK: - ARSCNViewDelegate
extension HostViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARPlaneAnchor {
            return SCNNode()
        } else {
            let scene = SCNScene(named: "example.scnassets/andy.scn")!
            let node = scene.rootNode.childNode(withName: "cone", recursively: false)!
            return node
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
extension HostViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Forward ARKit's update to ARCore session
        try! self.gSession?.update(frame)
    }
}


// MARK: - GARSessionDelegate
extension HostViewController: GARSessionDelegate {
    func session(_ session: GARSession, didHostAnchor anchor: GARAnchor) {
        if (self.state != .hosting || anchor != self.garAnchor) { return }
        self.garAnchor = anchor
        
        self.enterState(.hostingFinished)
        
        self.firebaseReference?.child("hotspot_list").child(self.roomCode!).child("hosted_anchor_id")
            .setValue(anchor.cloudIdentifier)
        
        let timestampInteger = Date().timeIntervalSince1970 * 1000
        let timestamp = NSNumber(value: timestampInteger)
        
        self.firebaseReference!.child("hotspot_list")
            .child(self.roomCode!)
            .child("updated_at_timestamp")
            .setValue(timestamp)
    }
    
    func session(_ session: GARSession, didFailToHostAnchor anchor: GARAnchor) {
        if (self.state != .hosting || anchor != self.garAnchor) { return }
        self.garAnchor = anchor
        self.enterState(.hostingFinished)
    }
}
