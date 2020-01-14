//
//  TypeExpediencyCollectionViewCell.swift
//  GoogleMap
//
//  Created by Duy Liêm on 11/15/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

final class TypeExpediencyCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var imvExpediency: UIImageView!
    
    func fillData(time: String, image: UIImage) {
        timeLabel.text = "(\(time))"
        imvExpediency.image = image
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = self.isSelected ? UIColor.orange : UIColor.white
            }
        }
    }
}
