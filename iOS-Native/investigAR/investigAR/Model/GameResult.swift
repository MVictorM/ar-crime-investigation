//
//  GameResult.swift
//  investigAR
//
//  Created by Hilton Pintor on 17/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import Foundation

enum GameResult {
    case foundMurderer(_ murderer: Occupation)
    case killedInnocent(_ innocent: Occupation)
    case gameOver(_ murderer: Occupation)
    case kidnaped(_ innocent: Occupation)
}
