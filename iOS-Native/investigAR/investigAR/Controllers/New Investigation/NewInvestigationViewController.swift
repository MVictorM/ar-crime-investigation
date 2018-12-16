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
    lazy var playersCrimes = CrimeProvider.shared.playersCrimes
    
    @IBOutlet weak var crimePlayersTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.crimePlayersTableView.dataSource = self
        self.crimePlayersTableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let detailsVC = segue.destination as? CrimeDetailsViewController {
            detailsVC.crime = sender as? Crime
        }
    }
}

extension NewInvestigationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playersCrimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CrimePlayersTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CrimePlayersTableViewCell else {
            fatalError("Unexpected cell type/identifier combination")
        }
        
        let numPlayers = self.minPlayers + indexPath.row
        cell.titleLabel.text = "\(numPlayers) jogadores"

        guard let crimes = self.playersCrimes[numPlayers] else {
            fatalError("unexpected numPlayers \(numPlayers)")
        }
        cell.crimes = crimes
        
        cell.crimeCollectionView.delegate = self
        cell.crimeCollectionView.tag = numPlayers
        
        return cell
    }
}

extension NewInvestigationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCrime = self.playersCrimes[collectionView.tag]![indexPath.row]
        self.performSegue(withIdentifier: "toCrimeDetails", sender: selectedCrime)
    }
}
