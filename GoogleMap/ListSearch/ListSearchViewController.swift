//
//  ListSearchViewController.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/18/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

class ListSearchViewController: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var placeTableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    
    //MARK: - Properties
    var arrPlace: [PlaceModel] = []
    let height: CGFloat = 555
    
    //MARK: - View Lyfe Cyle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGes(_:)))
        _ = UIPanGestureRecognizer(target: self, action: #selector(panGes(_:)))
        
        self.view.addGestureRecognizer(tapGes)
//        placeTableView.addGestureRecognizer(panGes)
        
        placeTableView.delegate = self
        placeTableView.dataSource = self
        placeTableView.register(UINib(nibName: ListSearchTableViewCell.name, bundle: nil), forCellReuseIdentifier: ListSearchTableViewCell.name)
        
//        let upSwipeGesture = UISwipeGestureRecognizer(target: self,
//                                                      action: #selector(self.panGestureRecognizer(_:)))
//        upSwipeGesture.direction = .up
//
//        let downSwipeGesture = UISwipeGestureRecognizer(target: self,
//                                                        action: #selector(self.panGestureRecognizer(_:)))
//        downSwipeGesture.direction = .down
//        self.view.addGestureRecognizer(upSwipeGesture)
//        self.view.addGestureRecognizer(downSwipeGesture)
    }
    
    //MARK: - Function
    @objc func panGestureRecognizer(_ gesture: UISwipeGestureRecognizer) {
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        let screenBounds = window.bounds
        let height: CGFloat = 80
        let _: CGFloat = 204
        switch gesture.direction {
        case .up:
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let wSelf = self else {
                    return
                }
                wSelf.view.frame = CGRect(x: 0,
                                     y: 0,
                                     width: screenBounds.width,
                                     height: screenBounds.height)
                //                wSelf.view.constant = heightPlayerView
                //                wSelf.player.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: 204)
                wSelf.view.layoutIfNeeded()
            }
        case .down:
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let wSelf = self else {
                    return
                }
                wSelf.view.frame = CGRect(x: 0,
                                     y: screenBounds.height - 200,
                                     width: screenBounds.width,
                                     height: height)
                wSelf.view.frame.size.height = 400
//                wSelf.listSearchTableView.contentSize.height = 70
                //                wSelf.heightConstraintPlayerView.constant = height
                //                wSelf.player.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: height)
                wSelf.view.layoutIfNeeded()
            }
            
        default:
            break
        }
    }
    
    @objc func tapGes(_ tap: UITapGestureRecognizer) {
//        dismiss(animated: true, completion: nil)
    }
    
    
    
    private func getDataPlacePhoto(photoReference: String) -> String {
        let dataPhotos = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(KEY)"
        return dataPhotos
    }
    
    @objc func panGes(_ pan: UIPanGestureRecognizer) {
        guard placeTableView.contentOffset.y < 0 else {
            return
        }
        
        let translation = pan.translation(in: self.view)
        switch pan.state {
        case .began, .changed:
//            placeTableView.center = CGPoint(x: placeTableView.center.x, y: placeTableView.center.y + translation.y)
//            pan.setTranslation(CGPoint.zero, in: view)
            placeTableView.contentSize.height = 200
            break
        case .ended:
            break
        default:
            break
        }
//        if pan.state == .began || pan.state == .changed {
////            let translation = pan.translation(in: self.view)
//
//            if ((pan.view?.center.y)! < height) {
////                pan.view?.center = CGPoint(x: (pan.view?.center.x)!, y: (pan.view?.center.y)! + translation.y)
//
//                UIView.animate(withDuration: 0.3) {
//                    self.view.frame = CGRect(x: 0, y: 0, width: width, height: 80)
//                }
//                self.view.layoutIfNeeded()
//
//            } else {
////                pan.view?.center = CGPoint(x: (pan.view?.center.x)!, y: height)
//                UIView.animate(withDuration: 0.3) {
//                    self.view.frame = CGRect(x: 0, y: 0, width: width, height: 200)
//                }
//                self.view.layoutIfNeeded()
//
//            }
//
//            pan.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
//        }
    }

}

//MARK: - UITableViewDelegate
extension ListSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - UITableViewDataSource
extension ListSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = placeTableView.dequeueReusableCell(withIdentifier: ListSearchTableViewCell.name, for: indexPath) as? ListSearchTableViewCell else {
            return UITableViewCell()
        }
        
        cell.fillData(placeModel: arrPlace[indexPath.row])
        if let photo = arrPlace[indexPath.row].photos?.first?.photo_reference {
            cell.dataPhotos(photo: getDataPlacePhoto(photoReference: photo))

        }
        
        return cell
        
    }
}
