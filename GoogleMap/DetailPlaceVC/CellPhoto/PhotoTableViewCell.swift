//
//  PhotoTableViewCell.swift
//  GoogleMap
//
//  Created by Duy Liêm on 11/1/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

final class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var imvPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func image(imageStr: String) {
        let url = URL(string: imageStr)
        imvPhoto.kf.setImage(with: url)
    }
    
}
