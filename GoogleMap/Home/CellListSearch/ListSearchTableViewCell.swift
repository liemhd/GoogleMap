//
//  ListSearchTableViewCell.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/18/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit
import Cosmos

final class ListSearchTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var totalRating: UILabel!
    @IBOutlet private weak var imvPhoto: UIImageView!
    @IBOutlet private weak var cosmosView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cosmosView.settings.updateOnTouch = false
        
    }
    
    func fillData(placeModel: PlaceModel, photo: String) {
        if let type = placeModel.types?[0] {
            typeLabel.text = type
        }
        nameLabel.text = placeModel.name
        totalRating.text = "(\(placeModel.user_ratings_total ?? 0))"
        cosmosView.rating = placeModel.rating ?? 0
        let url = URL(string: photo)
        imvPhoto.kf.setImage(with: url)
    }
    
}
