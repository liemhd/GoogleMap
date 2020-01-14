//
//  SearchTableViewCell.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/30/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

final class SearchTableViewCell: UITableViewCell {

    @IBOutlet private weak var searchLabel: UILabel!
    var deleteClouse: (() -> Void)?
    
    func fillData(textSearch: String) {
        searchLabel.text = textSearch
    }
    
    @IBAction private func btnActionDelete(_ sender: Any) {
        deleteClouse?()
    }
}
