//
//  TitleTableViewCell.swift
//  GoogleMap
//
//  Created by Duy Liêm on 11/1/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit
import Cosmos

final class TitleTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var rateLabel: UILabel!
    @IBOutlet private weak var cosmosView: CosmosView!
    @IBOutlet private weak var countRateLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var timeOpenLabel: UILabel!
    
    func fillData(placeData: PlaceModel) {
        nameLabel.text = placeData.name
        rateLabel.text = "\(placeData.rating ?? 0)"
        cosmosView.rating = placeData.rating ?? 0
        countRateLabel.text = "(\(placeData.user_ratings_total ?? 0))"
        
    }
}
