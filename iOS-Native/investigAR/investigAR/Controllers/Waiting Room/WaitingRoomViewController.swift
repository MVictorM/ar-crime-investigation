//
//  WaitingRoomViewController.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit

class WaitingRoomViewController: UIViewController {
    var crime: Crime!
    var connectedPlayers = 1 {
        didSet {
            self.refreshCounter()
        }
    }
    
    @IBOutlet weak var waitingCounterLabel: UILabel!
    @IBOutlet weak var crimeDetailsLabel: UILabel!
    @IBOutlet weak var turnsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var investigateButton: UIButton!
    
    @IBAction func tapCancelButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Número: \(1234)" // TODO: Add real room number
        self.crimeDetailsLabel.text = self.crime.description
        self.turnsLabel.text = "\(self.crime.numberTurns) turnos"
        self.timeLabel.text = "\(self.crime.estimatedDuration) minutos"
        self.refreshCounter()
    }
    
    func refreshCounter() {
        self.waitingCounterLabel.text = "\(self.connectedPlayers)/\(self.crime.numberInvestigators) investigadores"
        
        let investigationEnabled = self.connectedPlayers == self.crime.numberInvestigators
        self.investigateButton.alpha = investigationEnabled ? 1 : 0.5
        self.investigateButton.isEnabled = investigationEnabled
    }
}
