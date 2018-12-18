//
//  TrialViewController.swift
//  investigAR
//
//  Created by Hilton Pintor on 17/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit

class TrialViewController: UIViewController {
    
    var crime: Crime!
    
    @IBOutlet weak var characterButton0: UIButton!
    @IBOutlet weak var characterButton1: UIButton!
    @IBOutlet weak var characterButton2: UIButton!
    @IBOutlet weak var characterButton3: UIButton!
    @IBOutlet weak var characterButton4: UIButton!
    @IBOutlet weak var noConsensusButton: UIButton!
    
    lazy var buttons = [characterButton0, characterButton1, characterButton2, characterButton3, characterButton4]
    
    
    @IBAction func tapCharacterButton(_ sender: UIButton) {
        let characterIndex = self.buttons.firstIndex(of: sender)!
        let sentencedCharacter = self.crime.characters[characterIndex]
        let roundResult = self.crime.sentence(investigator: sentencedCharacter)
        self.process(result: roundResult)
    }
    
    @IBAction func tapNoConsensusButton(_ sender: Any?) {
        self.process(result: self.crime.sentence(investigator: nil))
        
    }
    
    func process(result: GameResult) {
        switch result {
        case .foundMurderer:
            self.performSegue(withIdentifier: "toVictory", sender: nil)
        case .gameOver:
            self.performSegue(withIdentifier: "toGameOver", sender: nil)
        case .killedInnocent:
            self.performSegue(withIdentifier: "toKilledInnocent", sender: nil)
        case .kidnaped:
            self.performSegue(withIdentifier: "toKidnap", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        zip(self.crime.characters, self.buttons).forEach { character, button in
            button?.setTitle(character.rawValue, for: .normal)
            
            button?.isEnabled = !self.crime.sentenced.contains(character)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let innocent = segue.destination as? InnocentExecutedViewController {
            innocent.crime = self.crime
        }
        
        if let kidnap = segue.destination as? KidnappingViewController {
            kidnap.crime = self.crime
        }
    }

}
