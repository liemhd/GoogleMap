//
//  ListSearchView.swift
//  GoogleMap
//
//  Created by Duy Liêm on 10/21/19.
//  Copyright © 2019 DuyLiem. All rights reserved.
//

import UIKit

final class ListSearchView: BasePopupView {
    
    //MARK: - Outlet
    @IBOutlet weak var listSearchTableView: UITableView!
    
    //MARK: - Properties
    var arrPlace: [PlaceModel] = []
    
    class func willShow (arrPlace: [PlaceModel]) {
        
        let view = ListSearchView.fromNib() as ListSearchView
        view.arrPlace = arrPlace
        view.congigUI()
        view.show()
    }
    
    private func getDataPlacePhoto(photoReference: String) -> String {
        let dataPhotos = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(KEY)"
        return dataPhotos
    }
    
    private func congigUI() {
        listSearchTableView.delegate = self
        listSearchTableView.dataSource = self
        listSearchTableView.register(UINib(nibName: ListSearchTableViewCell.name, bundle: nil), forCellReuseIdentifier: ListSearchTableViewCell.name)
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
//        listSearchTableView.addGestureRecognizer(pan)
        let upSwipeGesture = UISwipeGestureRecognizer(target: self,
                                                      action: #selector(self.panGestureRecognizer(_:)))
        upSwipeGesture.direction = .up
        
        let downSwipeGesture = UISwipeGestureRecognizer(target: self,
                                                        action: #selector(self.panGestureRecognizer(_:)))
        downSwipeGesture.direction = .down
        listSearchTableView.addGestureRecognizer(upSwipeGesture)
        listSearchTableView.addGestureRecognizer(downSwipeGesture)

    }
    
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
                wSelf.frame = CGRect(x: 0,
                                     y: 0,
                                     width: screenBounds.width,
                                     height: screenBounds.height)
//                wSelf.view.constant = heightPlayerView
//                wSelf.player.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: 204)
                wSelf.layoutIfNeeded()
            }
        case .down:
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let wSelf = self else {
                    return
                }
                wSelf.frame = CGRect(x: 0,
                                     y: screenBounds.height - 200,
                                     width: screenBounds.width,
                                     height: height)
                wSelf.listSearchTableView.contentSize.height = 70
//                wSelf.heightConstraintPlayerView.constant = height
//                wSelf.player.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: height)
                wSelf.layoutIfNeeded()
            }
            
        default:
            break
        }
    }
    
//    @objc func pan(_ pan: UIPanGestureRecognizer) {
//
//    }

}

//MARK: - UITableViewDelegate
extension ListSearchView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - UITableViewDataSource
extension ListSearchView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = listSearchTableView.dequeueReusableCell(withIdentifier: ListSearchTableViewCell.name, for: indexPath) as? ListSearchTableViewCell else {
            return UITableViewCell()
        }
        
        cell.fillData(placeModel: arrPlace[indexPath.row])
        if let photo = arrPlace[indexPath.row].photos?.first?.photo_reference {
            cell.dataPhotos(photo: getDataPlacePhoto(photoReference: photo))
            
        }
        
        return cell
        
    }
}
