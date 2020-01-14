//
//  ListSearchTableViewCell.swift
//  GoogleMap
//
//  Created by Duy Liêm on 11/12/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit
import Cosmos

class ListSearchTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var imvImage: UIImageView!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var cosmosRate: CosmosView!
    @IBOutlet private weak var countRateLabel: UILabel!
    
    func fillData(placeModel: PlaceModel, photo: String) {
        nameLabel.text = placeModel.name
        guard let url = URL(string: photo),
            let type = placeModel.types?[0] else {
            return
        }
        
        if placeModel.opening_hours?.open_now == true {
            typeLabel.text = "\(type) - Opening Soon"
        } else {
            typeLabel.text = "\(type) - Closed Now"
        }
        
        imvImage.kf.setImage(with: url)
        cosmosRate.rating = placeModel.rating ?? 0
        countRateLabel.text = "(\(placeModel.user_ratings_total ?? 0))"
    }
}
