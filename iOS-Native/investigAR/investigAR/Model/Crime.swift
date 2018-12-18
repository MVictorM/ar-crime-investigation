//
//  Crime.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import Foundation

struct Crime {
    let title: String
    let description: String
    let numberInvestigators: Int
    let numberTurns: Int
    let estimatedDuration: Int
    let available: Bool
    var roomNumber: Int?
    lazy var mandatoryTrialRound = {
        return self.numberTurns / self.numberInvestigators
    }()
    
    init(title: String, description: String, numberInvestigators: Int, numberTurns: Int,
         estimatedDuration: Int, available: Bool, roomNumber: Int? = nil) {
        self.title = title
        self.description = description
        self.numberInvestigators = numberInvestigators
        self.numberTurns = numberTurns
        self.estimatedDuration = estimatedDuration
        self.available = available
        self.roomNumber = roomNumber
    }
}
