//
//  Extension + RoundCorners.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/25/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
