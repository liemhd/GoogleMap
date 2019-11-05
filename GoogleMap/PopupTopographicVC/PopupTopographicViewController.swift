//
//  PopupTopographicViewController.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/25/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit
enum Topgraphic: Int {
    case terrain = 0
    case normal = 1
    case hybird = 2
}

final class PopupTopographicViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var viewPopup: UIView!
    @IBOutlet private var firstView: UIView!
    
    //MARK: - Properties
    var tag = 0;
    var topgraphicClosures: ((_ topgraphic: Topgraphic) -> Void)?
    
    //MARK: - View Lyfe Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
         viewPopup.roundCorners(corners: [.topLeft, .topRight], radius: 6)
//        showAnimate()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        firstView.addGestureRecognizer(tap)
        let views = stackView.subviews
        for view in views {
            if view is UIButton {
                let btn = view as? UIButton
                btn?.tag = tag
                btn?.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
            }
            tag += 1
        }
    }
    
    //MARK: - Function
    @objc func btnClick(_ sender: UIButton) {
        switch sender.tag {
        case Topgraphic.terrain.rawValue:
            topgraphicClosures?(.terrain)
        case Topgraphic.normal.rawValue:
            topgraphicClosures?(.normal)
        case Topgraphic.hybird.rawValue:
            topgraphicClosures?(.hybird)
        default:
            topgraphicClosures?(.normal)
        }
    }
    
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
