//
//  CrimeProvider.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 16/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import Foundation

class CrimeProvider {
    // MARK: - Singleton
    private init() {
        let mockDescription = "O corpo de um estimado membro da cidade é encontrado. Existem muitas variações das passagens do Lorem Ipsum disponíveis, mas a maior parte sofreu alterações de alguma forma, pela injecção de humor."
        
        self.playersCrimes = [
            4: [
                Crime(
                    title: "Estudo em Rosa",
                    description: mockDescription,
                    numberInvestigators: 4,
                    numberTurns: 10,
                    estimatedDuration: 10,
                    available: false
                ),
                Crime(
                    title: "Banqueiro cego",
                    description: mockDescription,
                    numberInvestigators: 4,
                    numberTurns: 12,
                    estimatedDuration: 15,
                    available: false
                )
            ],
            5: [
                Crime(
                    title: "Noite no Cinema",
                    description: mockDescription,
                    numberInvestigators: 5,
                    numberTurns: 6,
                    estimatedDuration: 8,
                    available: true
                ),
                Crime(
                    title: "Caixão vazio",
                    description: mockDescription,
                    numberInvestigators: 5,
                    numberTurns: 8,
                    estimatedDuration: 12,
                    available: false
                )
            ]
        ]
        
        
        self.minNumberPlayers = self.playersCrimes.keys.min()!
    }
    static let shared = CrimeProvider()
    
    
    // MARK: - Properties
    let playersCrimes: [Int: [Crime]]
    let minNumberPlayers: Int
}
