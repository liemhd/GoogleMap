//
//  InfoRoadView.swift
//  GoogleMap
//
//  Created by Duy Liêm on 1/6/20.
//  Copyright © 2020 DuyLiem. All rights reserved.
//

import UIKit

class InfoRoadView: UIView {
    @IBOutlet weak var timeAndDistanceLabel: UILabel!
    
    override func awakeFromNib() {
        dropShadow(view: self)
    }
    
    func fillData(data: String) {
        timeAndDistanceLabel.text = data
    }
    
    @IBAction func optionalBtnAction(_ sender: UIButton) {
    }
    
    @IBAction func startBtnAction(_ sender: UIButton) {
    }
}
