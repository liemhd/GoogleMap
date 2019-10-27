//
//  PopupTopographicViewController.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/25/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

class PopupTopographicViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet var firstView: UIView!
    
    //MARK: - Properties
    
    //MARK: - View Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
         viewPopup.roundCorners(corners: [.topLeft, .topRight], radius: 6)
//        showAnimate()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        firstView.addGestureRecognizer(tap)
    }
    
    //MARK: - Function
    @objc func tapGesture(_ tap: UITapGestureRecognizer) {
//        removeAnimate()
        dismiss(animated: true, completion: nil)
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        })
    }
    
    //MARK: - Action
    @IBAction func btnActionDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
//        removeAnimate()
    }
    
    
    
}
