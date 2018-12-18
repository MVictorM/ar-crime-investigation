//
//  Crime.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import Foundation

class Crime {
    let title: String
    let description: String
    let numberTurns: Int
    let estimatedDuration: Int
    let available: Bool
    var roomNumber: Int?
    var characters: [Occupation]
    var deceased: Occupation
    var murderer: Occupation
    var sentenced: [Occupation] = []
    
    var numberInvestigators: Int {
        return self.characters.count
    }
    
    lazy var mandatoryTrialRound = {
        return self.numberTurns / (self.numberInvestigators - 2)
    }()
    
    init(title: String, description: String, numberTurns: Int,
         estimatedDuration: Int, available: Bool, roomNumber: Int? = nil,
         characters: [Occupation], deceased: Occupation, murderer: Occupation) {
        self.title = title
        self.description = description
        self.numberTurns = numberTurns
        self.estimatedDuration = estimatedDuration
        self.available = available
        self.roomNumber = roomNumber
        self.characters = characters
        self.deceased = deceased
        self.murderer = murderer
    }
    
    
    func sentence(investigator: Occupation?) -> GameResult {
        guard let investigator = investigator else {
            let innocentCharacters = self.characters.filter { (character) -> Bool in
                character != self.murderer && !self.sentenced.contains(character)
            }
            let kidnaped = innocentCharacters.first!
            self.sentenced.append(kidnaped)
            return .kidnaped(kidnaped)
        }
        
        guard investigator != self.murderer else { return .foundMurderer(investigator) }
        
        self.sentenced.append(investigator)
        
        if self.characters.count - self.sentenced.count < 3 {
            return .gameOver(self.murderer)
        }
        
        return .killedInnocent(investigator)
    }
    
}
