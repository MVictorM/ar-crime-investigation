//
//  JoinInvestigationViewController.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit
import Firebase

class JoinInvestigationViewController: UIViewController {
    
    var firebaseReference: DatabaseReference?
    var anchorID: String?

    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func tapEnterButton(_ sender: Any) {
        guard let roomNumber = self.roomNumberTextField.text, roomNumber != "" else {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "Digite um número válido"
            return
        }
        
        self.resolveAnchor(roomCode: roomNumber)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.roomNumberTextField.becomeFirstResponder()
        self.firebaseReference = Database.database().reference()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resolveVC = segue.destination as? ResolveViewController {
            resolveVC.anchorID = self.anchorID!
        }
    }

    
    // MARK: - Resolving Anchor
    func resolveAnchor(roomCode: String) {
        self.activityIndicator.startAnimating()
        
        weak var weakSelf: JoinInvestigationViewController? = self
        
        self.firebaseReference!.child("hotspot_list").child(roomCode)
            .observe(DataEventType.value) { (snapshot) in
                DispatchQueue.main.async {
                    let strongSelf: JoinInvestigationViewController? = weakSelf
                    
                    strongSelf?.activityIndicator.stopAnimating()
                    
                    if let sanpshotValue = snapshot.value as? [String: Any],
                        let anchorID = sanpshotValue["hosted_anchor_id"] as? String {
                        strongSelf?.firebaseReference?.child("hotspot_list").child(roomCode).removeAllObservers()
                        strongSelf?.anchorID = anchorID
                        self.performSegue(withIdentifier: "toResolve", sender: nil)
                    } else {
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = "Cena não encontrada"
                    }
                }
        }
    }
}
