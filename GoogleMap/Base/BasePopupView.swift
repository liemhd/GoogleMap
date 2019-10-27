//
//  BasePopupView.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/21/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

class BasePopupView: UIView {
    
    private let kDuration = 0.2
    
    func show(completion: (() -> Void)? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        frame = window.bounds
        alpha = 0
        window.addSubview(self)
        UIView.animate(withDuration: kDuration, animations: { [weak self] in
            self?.alpha = 1
            }, completion: { (_: Bool) in
                completion?()
        })
    }
    
    func dismiss() {
        UIView.animate(withDuration: kDuration, animations: { [weak self] in
            self?.alpha = 0
            }, completion: { [weak self] (_) in
                self?.removeFromSuperview()
        })
    }
}
