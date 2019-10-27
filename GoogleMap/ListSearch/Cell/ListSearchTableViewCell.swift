//
//  ListSearchTableViewCell.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/18/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit
import Cosmos

class ListSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var totalRating: UILabel!
    @IBOutlet weak var imvPhoto: UIImageView!
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cosmosView.settings.updateOnTouch = false
        
    }
    
    func fillData(placeModel: PlaceModel) {
        nameLabel.text = placeModel.name
        typeLabel.text = placeModel.types![0]
        totalRating.text = "(\(placeModel.user_ratings_total ?? 0))"
        cosmosView.rating = placeModel.rating ?? 0
    }
    
    func dataPhotos(photo: String) {
        let url = URL(string: photo)
        imvPhoto.kf.setImage(with: url)
    }
    
}
