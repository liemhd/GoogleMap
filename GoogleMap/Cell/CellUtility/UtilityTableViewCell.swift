//
//  UtilityTableViewCell.swift
//  GoogleMap
//
//  Created by Duy Liêm on 11/1/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

enum Callback: Int {
    case direction = 0
    case gps = 1
    case call = 2
    case save = 3
}

final class UtilityTableViewCell: UITableViewCell {

    //MARK: - Outlet
    @IBOutlet private weak var stackView: UIStackView!
    
    //MARK: - Properties
    var callBack: ((_ type: Callback) ->Void)?
    var index = 0
    
    //MARK: - View Lyfe Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for view in stackView.subviews {
            for btn in view.subviews {
                if btn is UIButton {
                    let btn = btn as? UIButton
                    btn?.addTarget(self, action: #selector(btnActionClick(_:)), for: .touchUpInside)
                    btn?.tag = index
                }
            }
            index += 1
        }
    }
    
    //MARK: - Function
    @objc func btnActionClick(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("1")
            callBack?(.direction)
        case 1:
            print("2")
            callBack?(.gps)
        case 2:
            print("3")
            callBack?(.call)
        default:
            print("4")
            callBack?(.save)
        }
    }
}
