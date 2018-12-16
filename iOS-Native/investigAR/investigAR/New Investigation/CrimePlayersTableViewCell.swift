//
//  CrimePlayersTableViewCell.swift
//  investigAR
//
//  Created by Hilton Pintor Bezerra Leite on 15/12/18.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit

class CrimePlayersTableViewCell: UITableViewCell {

    var crimes: [String] = []
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var crimeCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.crimeCollectionView.dataSource = self
    }
}

extension CrimePlayersTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.crimes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "CrimeCollectionViewCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                            for: indexPath) as? CrimeCollectionViewCell else {
            fatalError("Unexpected cell type/identifier")
        }
        
        cell.titleLabel.text = self.crimes[indexPath.row].uppercased()
        
        return cell
    }
}
