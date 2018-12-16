//
//  JoinInvestigationViewController.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit

class JoinInvestigationViewController: UIViewController {

    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func tapEnterButton(_ sender: Any) {
        self.searchRoom(number: self.roomNumberTextField.text ?? "")
    }
    
    override func viewDidLoad() {
        self.roomNumberTextField.becomeFirstResponder()
    }
    
    func searchRoom(number: String) {
        print("Procurando \(number)")
    }
}
