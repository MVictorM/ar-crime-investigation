//
//  NewInvestigationViewController.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 15/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit

class NewInvestigationViewController: UIViewController {
    
    let minPlayers = 4
    lazy var crimePlayers = [
        self.minPlayers: ["Estudo em Rosa", "Banqueiro cego"],
        self.minPlayers + 1: ["Noite no Cinema", "Caixão vazio"]
    ]
    
    @IBOutlet weak var crimePlayersTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.crimePlayersTableView.dataSource = self
        self.crimePlayersTableView.tableFooterView = UIView()
    }
}

extension NewInvestigationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.crimePlayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CrimePlayersTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CrimePlayersTableViewCell else {
            fatalError("Unexpected cell type/identifier combination")
        }
        
        let numPlayers = self.minPlayers + indexPath.row
        cell.titleLabel.text = "\(numPlayers) jogadores"

        guard let crimes = self.crimePlayers[numPlayers] else {
            fatalError("unexpected numPlayers \(numPlayers)")
        }
        cell.crimes = crimes
        
        return cell
    }
}
