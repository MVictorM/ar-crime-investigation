//
//  ARViewController.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit
import ARKit
import ARCore
import Firebase

enum HelloARState: Int {
    case HelloARStateDefault
    case HelloARStateCreatingRoom
    case HelloARStateRoomCreated
    case HelloARStateHosting
    case HelloARStateHostingFinished
    case HelloARStateEnterRoomCode
    case HelloARStateResolving
    case HelloARStateResolvingFinished
}

class ARViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var resolveButton: UIButton!
    @IBOutlet weak var roomCodeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    // MARK: - Properties
    var gSession: GARSession?
    var firebaseReference: DatabaseReference?
    var arAnchor: ARAnchor?
    var garAnchor: GARAnchor?
    var state: HelloARState?
    var roomCode: String?
    var message: String?
    
    
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
        self.enterState(HelloARState.HelloARStateDefault)
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
        if (touches.count < 1 || self.state != .HelloARStateRoomCreated) {
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
    
    
    // MARK: - Anchor Hosting / Resolving
    func resolveAnchor(roomCode: String) {
        self.roomCode = roomCode
        
        self.enterState(HelloARState.HelloARStateResolving)
        
        weak var weakSelf: ARViewController? = self
        
        self.firebaseReference!.child("hotspot_list").child(roomCode)
            .observe(DataEventType.value) { (snapshot) in
                DispatchQueue.main.async {
                    let strongSelf: ARViewController? = weakSelf
                    
                    if strongSelf == nil ||
                        strongSelf?.state != .HelloARStateResolving ||
                        !(strongSelf?.roomCode == roomCode) {
                        return
                    }
                    
                    var anchorId: String? = nil
                    if (snapshot.value is [AnyHashable : Any]) {
                        let value = snapshot.value as? [AnyHashable : Any]
                        anchorId = value?["hosted_anchor_id"] as? String
                    }
                    
                    if let anchorId = anchorId {
                        strongSelf?.firebaseReference?.child("hotspot_list").child(roomCode)
                            .removeAllObservers()
                        strongSelf?.resolveAnchor(identifier: anchorId)
                    }
                }
        }
    }
    
    func resolveAnchor(identifier: String) {
        // Now that we have the anchor ID from firebase, we resolve the anchor.
        // Success and failure of this call is handled by the delegate methods
        // session:didResolveAnchor and session:didFailToResolveAnchor appropriately.
        self.garAnchor = try! self.gSession!.resolveCloudAnchor(withIdentifier: identifier)
    }
    
    func addAnchor(transform: matrix_float4x4) {
        self.arAnchor = ARAnchor(transform: transform)
        self.sceneView.session.add(anchor: self.arAnchor!)
        
        // To share an anchor, we call host anchor here on the ARCore session.
        // session:disHostAnchor: session:didFailToHostAnchor: will get called appropriately.
        do {
            self.garAnchor = try self.gSession!.hostCloudAnchor(self.arAnchor!)
            self.enterState(.HelloARStateHosting)
        } catch {
            print(error)
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func hostButtonPressed(_ sender: Any?) {
        if (self.state == .HelloARStateDefault) {
            self.enterState(.HelloARStateCreatingRoom)
            self.createRoom()
        } else {
            self.enterState(.HelloARStateDefault)
        }
    }
    
    @IBAction func resolveButtonPressed(_ sender: Any?) {
        if (self.state == .HelloARStateDefault) {
            self.enterState(.HelloARStateEnterRoomCode)
        } else {
            self.enterState(.HelloARStateDefault)
        }
    }
    
    
    // MARK: - Helper Methods
    func updateMessageLabel() {
        self.messageLabel.text = self.message
        self.roomCodeLabel.text = "Room: \(self.roomCode!)"
    }
    
    func toggle(button: UIButton, enabled: Bool, title: String) {
        button.isEnabled = enabled
        button.setTitle(title, for: .normal)
    }
    
    func showRoomCodeDialog() {
        let alertController = UIAlertController(
            title: "ENTER ROOM CODE",
            message: "",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default) { action in
                let roomCode = alertController.textFields![0].text ?? ""
                if (roomCode.isEmpty) {
                    self.enterState(.HelloARStateDefault)
                } else {
                    self.resolveAnchor(roomCode: roomCode)
                }
        }
        
        let cancelAction = UIAlertAction(
            title: "CANCEL",
            style: .default) { (action) in
                self.enterState(.HelloARStateDefault)
        }
            
        alertController.addTextField { (textField) in
            textField.keyboardType = UIKeyboardType.numberPad
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: false)
    }
    
    
    func enterState(_ state: HelloARState) {
        switch (state) {
        case .HelloARStateDefault:
            if let anchor = self.arAnchor {
                self.sceneView.session.remove(anchor: anchor)
                self.arAnchor = nil
            }
            if let anchor = self.garAnchor {
                self.gSession?.remove(anchor)
                self.garAnchor = nil
            }
            if (self.state == .HelloARStateCreatingRoom) {
                self.message = "Failed to create room. Tap HOST or RESOLVE to begin."
            } else {
                self.message = "Tap HOST or RESOLVE to begin."
            }
            if (self.state == .HelloARStateEnterRoomCode) {
//                self.dismiss(animated: false)
            } else if (self.state == .HelloARStateResolving) {
                self.firebaseReference!.child("hotspot_list").child(self.roomCode!)
                    .removeAllObservers()
            }
            self.toggle(button: self.hostButton, enabled: true, title: "HOST")
            self.toggle(button: self.resolveButton, enabled: true, title: "RESOLVE")
            self.roomCode = ""
            
        case .HelloARStateCreatingRoom:
            self.message = "Creating room..."
            self.toggle(button: self.hostButton, enabled: false, title: "HOST")
            self.toggle(button: self.resolveButton, enabled: false, title: "RESOLVE")

        case .HelloARStateRoomCreated:
            self.message = "Tap on a plane to create anchor and host."
            self.toggle(button: self.hostButton, enabled: true, title: "CANCEL")
            self.toggle(button: self.resolveButton, enabled: false, title: "RESOLVE")
            
        case .HelloARStateHosting:
            self.message = "Hosting anchor..."
            
        case .HelloARStateHostingFinished:
            self.message = "Finished hosting: \(self.garAnchor!.cloudState.message))"
            
        case .HelloARStateEnterRoomCode:
            self.showRoomCodeDialog()
            
        case .HelloARStateResolving:
//            self.dismiss(animated: false)
            self.message = "Resolving anchor..."
            self.toggle(button: self.hostButton, enabled: false, title: "HOST")
            self.toggle(button: self.resolveButton, enabled: true, title: "CANCEL")
            
        case .HelloARStateResolvingFinished:
            self.message = "Finished resolving: \(self.garAnchor!.cloudState.message)"
        }
        
        self.state = state
        self.updateMessageLabel()
    }
    
    
    func createRoom() {
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
        self.enterState(.HelloARStateRoomCreated)
    }
    
    func roomCreationFailed() {
        self.enterState(.HelloARStateDefault)
    }
}


// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARPlaneAnchor {
            return SCNNode()
        } else {
            let scene = SCNScene(named: "example.scnassets/andy.scn")
            return scene?.rootNode.childNode(withName: "andy", recursively: false)
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
extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Forward ARKit's update to ARCore session
        try! self.gSession?.update(frame)
    }
}


// MARK: - GARSessionDelegate
extension ARViewController: GARSessionDelegate {
    func session(_ session: GARSession, didHostAnchor anchor: GARAnchor) {
        if (self.state != .HelloARStateHosting || anchor != self.garAnchor) { return }
        self.garAnchor = anchor
        
        self.enterState(.HelloARStateHostingFinished)
        
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
        if (self.state != .HelloARStateHosting || anchor != self.garAnchor) { return }
        self.garAnchor = anchor
        self.enterState(.HelloARStateHostingFinished)
    }
    
    func session(_ session: GARSession, didResolve anchor: GARAnchor) {
        if (self.state != .HelloARStateResolving || anchor != self.garAnchor) { return }
        self.garAnchor = anchor;
        self.arAnchor = ARAnchor(transform: anchor.transform)
        self.sceneView.session.add(anchor: self.arAnchor!)
        self.enterState(.HelloARStateResolvingFinished)
    }
    
    func session(_ session: GARSession, didFailToResolve anchor: GARAnchor) {
        if (self.state != .HelloARStateResolving || anchor != self.garAnchor) { return }
        self.garAnchor = anchor
        self.enterState(.HelloARStateResolvingFinished)
    }
}

extension GARCloudAnchorState {
    var message: String {
        switch self {
        case .none:
            return "None"
        case .success:
            return "Success"
        case .errorInternal:
            return "ErrorInternal"
        case .taskInProgress:
            return "TaskInProgress"
        case .errorNotAuthorized:
            return "ErrorNotAuthorized"
        case .errorResourceExhausted:
            return "ErrorResourceExhausted"
        case .errorServiceUnavailable:
            return "ErrorServiceUnavailable"
        case .errorHostingDatasetProcessingFailed:
            return "ErrorHostingDatasetProcessingFailed"
        case .errorCloudIdNotFound:
            return "ErrorCloudIdNotFound"
        case .errorResolvingSdkVersionTooNew:
            return "ErrorResolvingSdkVersionTooNew"
        case .errorResolvingSdkVersionTooOld:
            return "ErrorResolvingSdkVersionTooOld"
        case .errorResolvingLocalizationNoMatch:
            return "ErrorResolvingLocalizationNoMatch"
        }
    }
}
