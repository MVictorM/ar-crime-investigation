//
//  CrimeDetailsViewController.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 15/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit

class CrimeDetailsViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var investigatorsLabel: UILabel!
    @IBOutlet weak var turnsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var crime: Crime!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.crime.title
        self.descriptionLabel.text = self.crime.description
        self.investigatorsLabel.text = "\(self.crime.numberInvestigators) investigadores"
        self.turnsLabel.text = "\(self.crime.numberTurns) turnos"
        self.timeLabel.text = "\(self.crime.estimatedDuration) minutos"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let waitingRoom = segue.destination as? WaitingRoomViewController {
            waitingRoom.crime = self.crime
        }
    }

}
